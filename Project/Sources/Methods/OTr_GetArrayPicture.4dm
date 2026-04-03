//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayPicture (inObject; inTag; inIndex) --> Picture

// Retrieves a single element from a Picture array item.
// The stored "pic:N" reference is decoded via
// OTr_uTextToPicture. Returns an empty Picture on any
// error or out-of-range index.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_pic : Picture : Element value, or empty Picture on any failure

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Removed proxy string; Picture now
//     retrieved natively from collection element.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_pic : Picture

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $arrayType_i : Integer

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			$arrayType_i:=OTr_zArrayType($arrayObj_o)
			If ($arrayType_i=Picture array:K8:22)
				If (($inIndex_i>=0) & ($inIndex_i<=$arrayObj_o.numElements))
					If (OB Is defined:C1231($arrayObj_o; String:C10($inIndex_i)))
						$result_pic:=$arrayObj_o[String:C10($inIndex_i)]
						OTr_zSetOK  // (1)
					Else 
						OTr_zSetOK  // (0)
					End if 
				Else 
					OTr_zSetOK  // (0)
				End if 
			Else 
				OTr_zError("Tag does not reference a Picture array"; Current method name:C684)
				OTr_zSetOK  // (0)
			End if 
		Else 
			OTr_zSetOK  // (0)
		End if 
	End if 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK  // (0)
End if 
