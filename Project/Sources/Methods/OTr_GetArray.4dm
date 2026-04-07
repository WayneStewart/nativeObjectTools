//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArray (inObject; inTag; outArray)

// Retrieves an array from an OTr object and populates
// the 4D array pointed to by $outArray_ptr. The target
// array must already be declared with an appropriate
// type. Elements are converted from stored text/values
// via the OTr_u utility methods as required.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $outArray_ptr : Pointer : Pointer to the destination 4D array (outArray)

// Returns: Nothing

// Wayne Stewart, 2026-04-02 - Restructured to resolve handle/path
//   once; now calls OTr_ArrayType directly on the retrieved object
//   instead of going through OTr_zArrayType a second time.

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $outArray_ptr : Pointer)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $storedType_i : Integer

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			$storedType_i:=OTr_zArrayType($arrayObj_o)
			If ($storedType_i=-1)
				OTr_zError("Tag does not reference an array"; Current method name:C684)
			Else 
				If ($storedType_i#Type:C295($outArray_ptr->))
					OTr_zError("Array type mismatch"; Current method name:C684)
				Else 
					OTr_zArrayFromObject($arrayObj_o; $outArray_ptr)
				End if 
			End if 
		End if 
	End if 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if

OTr_zRemoveFromCallStack(Current method name)
