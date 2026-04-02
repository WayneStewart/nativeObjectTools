//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ItemCount ($handle_i : Integer \
//   {; $tag_t : Text}) --> $count_i : Integer

// Returns the number of top-level items in the referenced object.
// When the optional $tag_t is provided, counts items in that embedded
// object instead. Internal __otr_ properties are excluded.

// Access: Shared

// Parameters:
//   $handle_i : Integer : A handle to an object
//   $tag_t    : Text    : Tag of an embedded object (optional)

// Returns:
//   $count_i : Integer : Item count, or 0 on error

// Wayne Stewart, 2026-04-01 - Updated OB Keys usage for collection return.
// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$count_i : Integer

var $target_o : Object
var $parent_o : Object
var $leafKey_t : Text
var $keys_c : Collection
var $useTag_b : Boolean
var $thisKey_t : Text

$keys_c:=New collection

$count_i:=0

OTr_zLock

If (OTr_zIsValidHandle($handle_i))

	$useTag_b:=(Count parameters>=2) & ($tag_t#"")

	If ($useTag_b)

		If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
			->$parent_o; ->$leafKey_t))
			If (OB Is defined($parent_o; $leafKey_t))
				$target_o:=OB Get($parent_o; $leafKey_t; Is object)
				If ($target_o#Null)
					$keys_c:=OB Keys($target_o)
					For each ($thisKey_t; $keys_c)
						If (Substring($thisKey_t; 1; 7)#"__otr_")
							$count_i:=$count_i+1
						End if
					End for each
				Else
					OTr_zError( \
						"Tag does not reference an embedded object"; \
						Current method name)
				End if
			Else
				OTr_zError("Item not found: "+$tag_t; Current method name)
			End if
		Else
			OTr_zError("Invalid path: "+$tag_t; Current method name)
		End if

	Else

		$keys_c:=OB Keys(<>OTR_Objects_ao{$handle_i})
		For each ($thisKey_t; $keys_c)
			If (Substring($thisKey_t; 1; 7)#"__otr_")
				$count_i:=$count_i+1
			End if
		End for each

	End if

Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock
