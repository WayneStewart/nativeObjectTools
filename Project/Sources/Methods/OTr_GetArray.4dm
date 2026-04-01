//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArray ($handle_i : Integer; $tag_t : Text; $arrayPtr : Pointer)

// Retrieves an array from an OTr object and populates
// the 4D array pointed to by $arrayPtr. The target
// array must already be declared with an appropriate
// type. Elements are converted from stored text/values
// via the OTr_u utility methods as required.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $arrayPtr : Pointer : Pointer to target 4D array

// Returns: Nothing

// Wayne Stewart, 2026-04-02 - Restructured to resolve handle/path
//   once; now calls OTr_ArrayType directly on the retrieved object
//   instead of going through OTr__ArrayType a second time.

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $arrayPtr : Pointer)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $storedType_i : Integer

If (OTr__IsValidHandle($handle_i))
	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			$storedType_i:=OTr__ArrayType($arrayObj_o)
			If ($storedType_i=-1)
				OTr__Error("Tag does not reference an array"; Current method name:C684)
			Else 
				If ($storedType_i#Type:C295($arrayPtr->))
					OTr__Error("Array type mismatch"; Current method name:C684)
				Else 
					OTr__ArrayFromObject($arrayObj_o; $arrayPtr)
				End if 
			End if 
		End if 
	End if 
Else 
	OTr__Error("Invalid handle"; Current method name:C684)
End if 
