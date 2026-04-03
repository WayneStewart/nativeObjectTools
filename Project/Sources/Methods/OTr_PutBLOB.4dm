//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutBLOB (inObject; inTag; inValue)

// Stores a BLOB value at the specified tag path.
// On v19R2+, the BLOB is stored natively in the object.
// On earlier versions, it is Base64-encoded via OTr_uBlobToText.

// **ORIGINAL DOCUMENTATION**
// 
// *OT PutBLOB* puts *inValue* into *inObject*.
// 
// If *inObject* is not a valid object handle, an error
// is generated and OK is set to zero.
// 
// If no item in the object has the given inTag, a new
// item is created.
// 
// If an item with the given inTag exists and has the
// type *Is BLOB*, its value is replaced. The previous
// BLOB data in the parallel array is released and a
// new slot is allocated.
// 
// If an item with the given inTag exists and has any
// other type, an error is generated and OK is set to
// zero if the _OT VariantItems_ option is not set,
// otherwise the existing item is deleted and a new
// item is created.

// Access: Shared

// Parameters:
//   $inObject_i   : Integer : OTr inObject
//   $inTag_t      : Text    : Tag path (inTag)
//   $inValue_blob : Blob    : BLOB to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Removed release call; branches on
//     Storage.OTr.nativeBlobInObject for native or base64 storage.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_blob : Blob)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True; ->$parent_o; ->$leafKey_t))
		If (Storage.OTr.nativeBlobInObject)
			OB SET($parent_o; $leafKey_t; $inValue_blob)
		Else
			OB SET($parent_o; $leafKey_t; OTr_uBlobToText($inValue_blob))
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
	OTr_zSetOK(0)
End if

OTr_zUnlock
