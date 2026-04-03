//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayBLOB ($handle_i : Integer; \
//   $tag_t : Text; $index_i : Integer; $value_blob : Blob)

// Sets a single element of a Blob array item.
// The BLOB is stored via OTr_uBlobToText which allocates
// a slot in the parallel <>OTR_Blobs_ablob array and
// returns a "blob:N" reference text. If the element
// already holds a blob reference, the old slot is
// released before the new one is allocated.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $index_i  : Integer : Element index (0 = default element)
//   $value_blob : Blob    : Value to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Removed release call; branches on
//     Storage.OTr.nativeBlobInObject for native or base64 storage.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_blob : Blob)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $arrayType_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			$arrayType_i:=OTr_zArrayType($arrayObj_o)
			If ($arrayType_i=Blob array:K8:30)
				If (($index_i>=0) & ($index_i<=$arrayObj_o.numElements))
						If (Storage.OTr.nativeBlobInObject)
							$arrayObj_o[String:C10($index_i)]:=$value_blob
						Else
							$arrayObj_o[String:C10($index_i)]:=OTr_uBlobToText($value_blob)
						End if
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
