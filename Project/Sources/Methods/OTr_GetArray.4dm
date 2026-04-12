//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArray (inObject; inTag; outArray)

// Retrieves an array from an OTr object and populates
// the 4D array pointed to by $outArray_ptr. The target
// array must already be declared with an appropriate
// type. Elements are converted from stored text/values
// via the OTr_u utility methods as required.

// **ORIGINAL DOCUMENTATION**

// OT GetArray gets an array value in *inObject* from the item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and

// *outArray* is cleared.

// If no item in the object has the given tag, *outArray* is cleared. If the
// *FailOnNoItem* option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has a compatible type, the array’s contents
// are replaced.

// If an item with the given tag exists and has any other type, an error is generated,
// *OK* is set to zero, and array is cleared.

// Array Type Compatibility

// Except for * *String and Text *array* s, you must put and get *array* s into the same
// type of *array* variable. String and Text *array* s, however, may be mixed and
// matched, because ObjectTools stores both types of *array* with an item type of *OT
// Character array (113)*.

// Note: If you retrieve into a fixed width string array and your database is running in
// compatibility mode, the elements will be truncated to the width of the array.

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
// Wayne Stewart, 2026-04-11 - OB Get now uses Is object type argument
//     to avoid "Argument types are incompatible" crash when the tag
//     holds a scalar. OTr_zArrayType handles Null by returning -1.
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
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
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
