//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_IsEmbedded (inObject; inTag) --> Longint

// Tests whether the item referenced by $inTag_t is an embedded object.
// Returns 1 if the item exists and has OT Object type, 0 otherwise.

// **ORIGINAL DOCUMENTATION**

// *OT IsEmbedded* tests the item referenced by *inTag* to see if it is an embedded
// object.

// If *inObject* is not a valid object handle or if no item in object has the given tag,
// an error is generated, *OK* is set to zero, and zero is returned.

// If an item with the given tag exists and has the type *OT Is Object*, 1 is returned.
// If an item with the given tag exists and has any other type, zero is returned.



// Access: Shared

// Parameters:
//   $inObject_i    : Integer : OTr inObject
//   $inTag_t       : Text    : Tag of the item to query (inTag)

// Returns:
//   $isEmbedded_i : Integer : 1 if item is an embedded object, 0 if not

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$isEmbedded_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text

$isEmbedded_i:=0

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			If (OB Get type:C1230($parent_o; $leafKey_t)=Is object:K8:27)
				$isEmbedded_i:=1
			End if 
		Else 
			OTr_z_Error("Item not found: "+$inTag_t; Current method name:C684)
		End if 
	Else 
		OTr_z_Error("Invalid path: "+$inTag_t; Current method name:C684)
	End if 
	
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
