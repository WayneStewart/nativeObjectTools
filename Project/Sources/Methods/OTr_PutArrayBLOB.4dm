//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayBLOB (inObject; inTag; inIndex; inValue)

// Sets a single element of a Blob array item.
// The BLOB is stored as inline base64 text with a "blob:"
// prefix via OTr_uBlobToText.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_blob : Blob    : Value to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Removed release call; branches on
//     Storage.OTr.nativeBlobInObject for native or base64 storage.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_blob : Blob)

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
			If ($arrayType_i=Blob array:K8:30)
				If (($inIndex_i>=0) & ($inIndex_i<=$arrayObj_o.numElements))
						$arrayObj_o[String:C10($inIndex_i)]:=OTr_uBlobToText($inValue_blob)
					OTr_zSetOK  // (1)
				Else 
					OTr_zError("Index out of range"; Current method name:C684)
					OTr_zSetOK  // (0)
				End if 
			Else 
				OTr_zError("Tag does not reference a Blob array"; Current method name:C684)
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
