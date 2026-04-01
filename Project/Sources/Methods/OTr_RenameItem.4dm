//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_RenameItem ($handle_i : Integer; \
//   $tag_t : Text; $newTag_t : Text)

// Renames the item referenced by $tag_t. $tag_t must be the full dotted
// path; $newTag_t is the new leaf name only. For example, renaming
// "foo.bar.old_name" to "new_name" gives access via "foo.bar.new_name".
// BLOB and Picture references are moved, not copied (no new slot).

// Access: Shared

// Parameters:
//   $handle_i : Integer : A handle to an object
//   $tag_t    : Text    : Full tag of the item to rename
//   $newTag_t : Text    : New leaf name for the item

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $newTag_t : Text)

var $dotPos_i : Integer
var $scanPos_i : Integer
var $parentPath_t : Text
var $leafKey_t : Text
var $parentObj_o : Object
var $parentLeaf_t : Text
var $nativeType_i : Integer

OTr__Lock

If (OTr__IsValidHandle($handle_i))

	// Split $tag_t into parent path and leaf name
	$dotPos_i:=0
	$scanPos_i:=Length($tag_t)
	While ($scanPos_i>0)
		If (Substring($tag_t; $scanPos_i; 1)=".")
			$dotPos_i:=$scanPos_i
			$scanPos_i:=0
		Else
			$scanPos_i:=$scanPos_i-1
		End if
	End while

	If ($dotPos_i>0)
		// Item is nested — navigate to parent container
		$parentPath_t:=Substring($tag_t; 1; $dotPos_i-1)
		$leafKey_t:=Substring($tag_t; $dotPos_i+1)

		var $resolvedParent_o : Object
		var $resolvedParentLeaf_t : Text

		If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; \
			$parentPath_t; False; ->$resolvedParent_o; \
			->$resolvedParentLeaf_t))
			If (OB Is defined($resolvedParent_o; $resolvedParentLeaf_t))
				$parentObj_o:=OB Get( \
					$resolvedParent_o; $resolvedParentLeaf_t; Is object)
			End if
		End if
	Else
		// Top-level item
		$leafKey_t:=$tag_t
		$parentObj_o:=<>OTR_Objects_ao{$handle_i}
	End if

	If ($parentObj_o=Null)
		OTr__Error("Cannot resolve parent for: "+$tag_t; Current method name)

	Else

		If (OB Is defined($parentObj_o; $leafKey_t))

			If (OB Is defined($parentObj_o; $newTag_t))
				OTr__Error("Target name already exists: "+$newTag_t; \
					Current method name)

			Else

				$nativeType_i:=OB Get type($parentObj_o; $leafKey_t)

				Case of

					: ($nativeType_i=Is real)
						OB SET($parentObj_o; $newTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is real))

					: (($nativeType_i=Is longint) \
						| ($nativeType_i=Is integer))
						OB SET($parentObj_o; $newTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is longint))

					: ($nativeType_i=Is Boolean)
						OB SET($parentObj_o; $newTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is Boolean))

					: ($nativeType_i=Is object)
						OB SET($parentObj_o; $newTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is object))

					: ($nativeType_i=Is collection)
						OB SET($parentObj_o; $newTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is collection))

					: ($nativeType_i=Is text)
						// Plain copy — BLOB/Picture slots stay assigned
						OB SET($parentObj_o; $newTag_t; \
							OB Get($parentObj_o; $leafKey_t; Is text))

				End case

				OB REMOVE($parentObj_o; $leafKey_t)

			End if

		Else
			OTr__Error("Item not found: "+$tag_t; Current method name)
		End if

	End if

Else
	OTr__Error("Invalid handle"; Current method name)
End if

OTr__Unlock
