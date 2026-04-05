//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_RenameItem (inObject; inTag; inNewTag)

// Renames the item referenced by $inTag_t. $inTag_t must be the full dotted
// path; $inNewTag_t is the new leaf name only. For example, renaming
// "foo.bar.old_name" to "new_name" gives access via "foo.bar.new_name".
// BLOB and Picture references are moved, not copied (no new slot).

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Full tag path of the item to rename (inTag)
//   $inNewTag_t : Text    : New leaf name (inNewTag)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-04 - Added OTr_zSetOK(1) on success.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inNewTag_t : Text)

OK:=1
var $dotPos_i : Integer
var $scanPos_i : Integer
var $parentPath_t : Text
var $leafKey_t : Text
var $parentObj_o : Object
var $parentLeaf_t : Text
var $nativeType_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))

	// Split $inTag_t into parent path and leaf name
	$dotPos_i:=0
	$scanPos_i:=Length($inTag_t)
	While ($scanPos_i>0)
		If (Substring($inTag_t; $scanPos_i; 1)=".")
			$dotPos_i:=$scanPos_i
			$scanPos_i:=0
		Else
			$scanPos_i:=$scanPos_i-1
		End if
	End while

	If ($dotPos_i>0)
		// Item is nested — navigate to parent container
		$parentPath_t:=Substring($inTag_t; 1; $dotPos_i-1)
		$leafKey_t:=Substring($inTag_t; $dotPos_i+1)

		var $resolvedParent_o : Object
		var $resolvedParentLeaf_t : Text

		If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; \
			$parentPath_t; False; ->$resolvedParent_o; \
			->$resolvedParentLeaf_t))
			If (OB Is defined($resolvedParent_o; $resolvedParentLeaf_t))
				$parentObj_o:=OB Get( \
					$resolvedParent_o; $resolvedParentLeaf_t; Is object)
			End if
		End if
	Else
		// Top-level item
		$leafKey_t:=$inTag_t
		$parentObj_o:=<>OTR_Objects_ao{$inObject_i}
	End if

	If ($parentObj_o=Null)
		OTr_zError("Cannot resolve parent for: "+$inTag_t; Current method name)

	Else

		If (OB Is defined($parentObj_o; $leafKey_t))

			If (OB Is defined($parentObj_o; $inNewTag_t))
				OTr_zError("Target name already exists: "+$inNewTag_t; \
					Current method name)

			Else

				$nativeType_i:=OB Get type($parentObj_o; $leafKey_t)

				Case of

					: ($nativeType_i=Is real)
						OB SET($parentObj_o; $inNewTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is real))

					: (($nativeType_i=Is longint) \
						| ($nativeType_i=Is integer))
						OB SET($parentObj_o; $inNewTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is longint))

					: ($nativeType_i=Is Boolean)
						OB SET($parentObj_o; $inNewTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is Boolean))

					: ($nativeType_i=Is object)
						OB SET($parentObj_o; $inNewTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is object))

					: ($nativeType_i=Is collection)
						OB SET($parentObj_o; $inNewTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is collection))

					: ($nativeType_i=Is text)
						// Plain copy — BLOB/Picture slots stay assigned
						OB SET($parentObj_o; $inNewTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is text))

				End case

				OB REMOVE($parentObj_o; $leafKey_t)
				OTr_zSetOK(1)

			End if

		Else
			OTr_zError("Item not found: "+$inTag_t; Current method name)
		End if

	End if

Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock
