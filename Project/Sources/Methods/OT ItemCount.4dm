//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT ItemCount (inObject {; inTag}) --> Longint

// Returns the number of top-level items in the referenced object.
// When the optional $inTag_t is provided, counts items in that embedded
// object instead. Internal __otr_ properties and shadow keys (keys ending
// in the $type suffix) are excluded from the count.

// **ORIGINAL DOCUMENTATION**

// *OT ItemCount* returns the number of top level items in the referenced object. Items
// in embedded objects are not included in the count.

// If *inObject* is not a valid object handle, an error is generated, *OK* is set to
// zero, and zero is returned.

// If the tag is not passed or is empty, the count of top level items in the object is
// returned.

// If the tag is passed, is not empty, and is a valid item reference for an embedded
// object, the count of top level items in the embedded object is returned.

// Otherwise an error is generated, *OK* is set to zero, and zero is returned.



// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag of an embedded object (optional) (inTag)

// Returns:
//   $count_i : Integer : Item count (excluding internal __otr_ properties and shadow keys), or 0

// Wayne Stewart, 2026-04-01 - Updated OB Keys usage for collection return.
// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Guy Algot, 2026-04-03 - Zoom session. Changed optional param init
//   to Choose pattern. Added :Cxxx command codes throughout.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Exclude shadow keys ($type suffix) from count.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$count_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $target_o : Object
var $parent_o : Object
var $leafKey_t : Text
var $keys_c : Collection
var $useTag_b : Boolean
var $thisKey_t : Text
var $tag_t : Text

$keys_c:=New collection:C1472

$count_i:=0

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	
	If (Count parameters:C259<2)
		$tag_t:=""
	Else 
		$tag_t:=$inTag_t
	End if 
	$useTag_b:=($tag_t#"")
	
	If ($useTag_b)
		
		If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $tag_t; False:C215; \
			->$parent_o; ->$leafKey_t))
			If (OB Is defined:C1231($parent_o; $leafKey_t))
				$target_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
				If ($target_o#Null:C1517)
					$keys_c:=OB Keys:C1719($target_o)
					For each ($thisKey_t; $keys_c)
						If (Substring:C12($thisKey_t; 1; 7)#"__otr_") & (Not:C34(OTr_z_IsShadowKey($thisKey_t)))
							$count_i:=$count_i+1
						End if 
					End for each 
				Else 
					OTr_z_Error(\
						"Tag does not reference an embedded object"; \
						Current method name:C684)
				End if 
			Else 
				OTr_z_Error("Item not found: "+$tag_t; Current method name:C684)
			End if 
		Else 
			OTr_z_Error("Invalid path: "+$tag_t; Current method name:C684)
		End if 
		
	Else 
		
		$keys_c:=OB Keys:C1719(<>OTR_Objects_ao{$inObject_i})
		For each ($thisKey_t; $keys_c)
			If (Substring:C12($thisKey_t; 1; 7)#"__otr_") & (Not:C34(OTr_z_IsShadowKey($thisKey_t)))
				$count_i:=$count_i+1
			End if 
		End for each 
		
	End if 
	
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
