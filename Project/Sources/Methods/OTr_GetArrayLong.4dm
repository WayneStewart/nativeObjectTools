//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayLong (inObject; inTag; inIndex) --> Longint

// Retrieves a single Integer element from a LongInt or
// Integer array item at the specified 1-based index.
// Returns 0 if the handle is invalid, the tag does not
// exist, the item is not a LongInt/Integer array, or the
// index is out of range.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_i : Integer : Element value, or 0 on any failure

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_i : Integer

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $arrayType_i : Integer

$result_i:=0

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			$arrayType_i:=OTr_zArrayType($arrayObj_o)
			If (($arrayType_i=LongInt array:K8:19) | ($arrayType_i=Integer array:K8:18))
				If (($inIndex_i>=0) & ($inIndex_i<=$arrayObj_o.numElements))
					If (OB Is defined:C1231($arrayObj_o; String:C10($inIndex_i)))
						$result_i:=Num:C11(OB Get:C1224($arrayObj_o; String:C10($inIndex_i)))
						OTr_zSetOK(1)
					Else 
						OTr_zSetOK(0)
					End if 
				Else 
					OTr_zSetOK(0)
				End if 
			Else 
				OTr_zError("Tag does not reference a LongInt or Integer array"; Current method name:C684)
				OTr_zSetOK(0)
			End if 
		Else 
			OTr_zSetOK(0)
		End if 
	End if 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK(0)
End if 
