//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ResizeArray (inObject; inTag; inSize)

// Resizes an array item to the specified number of
// elements (not counting element 0). If growing,
// new elements are appended with the array type's default value. If
// shrinking, excess elements are removed from the end.

// **ORIGINAL DOCUMENTATION**

// *OT ResizeArray* resizes an array in *inObject*.

// If *inObject* is not a valid object handle, if no item in the object
// has the given tag, or if the item's type is not an array type, an error
// is generated and *OK* is set to zero.

// If *inSize* is greater than the current size of the array, empty
// elements are added to the end of the array. If *inSize* is less than
// the current size of the array, elements from *inSize* + 1 to the end of
// the array are deleted.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inSize_i   : Integer : New number of elements (inSize)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_z_SetOK(1) on
//   success path (see OTr-OK0-Conditions specification).
// Wayne Stewart, 2026-04-11 - OB Get now uses Is object type argument
//     to prevent crash when tag holds a scalar rather than an array.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inSize_i : Integer)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $currentSize_i; $index_i; $arrayType_i : Integer

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
				$currentSize_i:=$arrayObj_o.numElements
				$arrayType_i:=OTr_z_ArrayType($arrayObj_o)
				
				If ($inSize_i>$currentSize_i)
					// Grow: append type-appropriate default values
					For ($index_i; $currentSize_i+1; $inSize_i)
						$arrayObj_o[String:C10($index_i)]:=OTr_u_NewValueForEmbeddedType($arrayType_i)
					End for 
					
				Else 
					If ($inSize_i<$currentSize_i)
						// Shrink: remove entries
						For ($index_i; $inSize_i+1; $currentSize_i)
							OB REMOVE:C1226($arrayObj_o; String:C10($index_i))
						End for 
					End if 
				End if 
				
				$arrayObj_o.numElements:=$inSize_i
			End if 
		End if 
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
	OTr_z_SetOK(0)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
