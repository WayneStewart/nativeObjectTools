//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ItemCount (inObject {; inTag}) --> Longint

// Returns the number of top-level items in the referenced object.
// When the optional $inTag_t is provided, counts items in that embedded
// object instead. Internal __otr_ properties are excluded.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag of an embedded object (optional) (inTag)

// Returns:
//   $count_i : Integer : Item count (excluding internal __otr_ properties), or 0

// Wayne Stewart, 2026-04-01 - Updated OB Keys usage for collection return.
// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$count_i : Integer

var $target_o : Object
var $parent_o : Object
var $leafKey_t : Text
var $keys_c : Collection
var $useTag_b : Boolean
var $thisKey_t : Text

$keys_c:=New collection

$count_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))

	$useTag_b:=(Count parameters>=2) & ($inTag_t#"")

	If ($useTag_b)

		If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
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
				OTr_zError("Item not found: "+$inTag_t; Current method name)
			End if
		Else
			OTr_zError("Invalid path: "+$inTag_t; Current method name)
		End if

	Else

		$keys_c:=OB Keys(<>OTR_Objects_ao{$inObject_i})
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
