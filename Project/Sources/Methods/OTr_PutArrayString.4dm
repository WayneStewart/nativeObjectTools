//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayString (inObject; inTag; inIndex; inValue)

// Sets a single element of a Text or String array item.
// Text array and String array are interchangeable.
// The tag must reference an existing Text/String array
// and $inIndex_i must be in range 0..numElements.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_t  : Text    : Value to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_t : Text)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $arrayType_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			$arrayType_i:=OTr_zArrayType($arrayObj_o)
			If (($arrayType_i=Text array:K8:16) | ($arrayType_i=String array:K8:15))
				If (($inIndex_i>=0) & ($inIndex_i<=$arrayObj_o.numElements))
					$arrayObj_o[String:C10($inIndex_i)]:=$inValue_t
					OTr_zSetOK  // (1)
				Else 
					OTr_zError("Index out of range"; Current method name:C684)
					OTr_zSetOK  // (0)
				End if 
			Else 
				OTr_zError("Tag does not reference a Text or String array"; Current method name:C684)
				OTr_zSetOK  // (0)
			End if 
		Else 
			OTr_zError("Tag not found"; Current method name:C684)
			OTr_zSetOK  // (0)
		End if 
	End if 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK  // (0)
End if 

OTr_zUnlock
