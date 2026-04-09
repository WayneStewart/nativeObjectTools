//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT ItemCount (inObject {; inTag}) --> Longint

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
// Guy Algot, 2026-04-03 - Zoom session. Changed optional param init
//   to Choose pattern. Added :Cxxx command codes throughout.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$count_i : Integer

OTr_zAddToCallStack(Current method name)

var $target_o : Object
var $parent_o : Object
var $leafKey_t : Text
var $keys_c : Collection
var $useTag_b : Boolean
var $thisKey_t : Text

$keys_c:=New collection:C1472

$count_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	
	$inTag_t:=Choose:C955(Count parameters:C259=2; $inTag_t; "")
	$useTag_b:=($inTag_t#"")
	
	If ($useTag_b)
		
		If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
			->$parent_o; ->$leafKey_t))
			If (OB Is defined:C1231($parent_o; $leafKey_t))
				$target_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
				If ($target_o#Null:C1517)
					$keys_c:=OB Keys:C1719($target_o)
					For each ($thisKey_t; $keys_c)
						If (Substring:C12($thisKey_t; 1; 7)#"__otr_")
							$count_i:=$count_i+1
						End if 
					End for each 
				Else 
					OTr_zError(\
						"Tag does not reference an embedded object"; \
						Current method name:C684)
				End if 
			Else 
				OTr_zError("Item not found: "+$inTag_t; Current method name:C684)
			End if 
		Else 
			OTr_zError("Invalid path: "+$inTag_t; Current method name:C684)
		End if 
		
	Else 
		
		$keys_c:=OB Keys:C1719(<>OTR_Objects_ao{$inObject_i})
		For each ($thisKey_t; $keys_c)
			If (Substring:C12($thisKey_t; 1; 7)#"__otr_")
				$count_i:=$count_i+1
			End if 
		End for each 
		
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
