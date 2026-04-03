//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayBLOB (inObject; inTag; inIndex) --> Blob

// Retrieves a single element from a Blob array item.
// The element is expected to be inline base64 text with
// a "blob:" prefix; decoded via OTr_uTextToBlob.
// Returns an empty BLOB on any error or out-of-range index.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_blob : Blob : Element value, or empty BLOB on any failure

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Branches on Storage.OTr.nativeBlobInObject;
//     native retrieval used when True, else base64 decode.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_blob : Blob

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
			If ($arrayType_i=Blob array:K8:30)
				If (($inIndex_i>=0) & ($inIndex_i<=$arrayObj_o.numElements))
					If (OB Is defined:C1231($arrayObj_o; String:C10($inIndex_i)))
							$result_blob:=OTr_uTextToBlob($arrayObj_o[String:C10($inIndex_i)])
						OTr_zSetOK  // (1)
					Else 
						OTr_zSetOK  // (0)
					End if 
				Else 
					OTr_zSetOK  // (0)
				End if 
			Else 
				OTr_zError("Tag does not reference a Blob array"; Current method name:C684)
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
