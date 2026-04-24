//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT SizeOfArray (inObject; inTag) --> Longint

// Returns the number of elements in an array item. Does not count element 0.
// Returns 0 if the handle is invalid, the tag does not exist, or the tag does
// not reference an array item.

// **ORIGINAL DOCUMENTATION**

// *OT SizeOfArray* returns the number of elements in an array item within an object.

// If *inObject* is not a valid object handle, if no item in the object has the given
// tag, or if the item’s type is not an array type, an error is generated, *OK* is set
// to zero, and zero is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)

// Returns:
//   $size_i : Integer : Number of elements (not counting element 0), or 0

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is object type argument
//     to prevent crash when tag holds a scalar rather than an array.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$size_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text

$size_i:=0

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
				$size_i:=$arrayObj_o.numElements
			End if 
		End if 
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
