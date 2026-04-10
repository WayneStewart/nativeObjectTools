//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetNewBLOB (inObject; inTag) --> Blob

// Retrieves a BLOB value from the specified tag path as
// a function result. When Storage.OTr.nativeBlobInObject is
// True (4D v19 R2 and later), the property is read as a
// native BLOB via OB Get; otherwise it is read as plain
// base64 text and decoded via OTr_uTextToBlob. Returns an
// empty BLOB on any error or missing tag.

// **ORIGINAL DOCUMENTATION**
// 
// *OTr_GetNewBLOB* retrieves a BLOB value from *inObject*
// as a function result.
// 
// If *inObject* is not a valid object handle, an error
// is generated, OK is set to zero, and an empty BLOB
// is returned.
// 
// If no item in the object has the given inTag, an empty
// BLOB is returned. If the FailOnItemNotFound option is
// set, an error is generated and OK is set to zero.
// 
// If an item with the given inTag exists and has the type
// *Is BLOB*, the value of the requested item is returned.
// 
// If an item with the given inTag exists and has any other
// type, an error is generated, OK is set to zero, and an
// empty BLOB is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_blob : Blob : Stored BLOB, or empty BLOB on failure

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Branches on Storage.OTr.nativeBlobInObject;
//     native OB Get used when True, else base64 decode.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Actually honours
//   Storage.OTr.nativeBlobInObject (previously only claimed to in
//   the changelog; the body always decoded base64 text).
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_blob : Blob

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; ->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			If (Storage:C1525.OTr.nativeBlobInObject)
				$result_blob:=OB Get($parent_o; $leafKey_t; Is BLOB)
			Else
				$result_blob:=OTr_uTextToBlob(OB Get($parent_o; $leafKey_t; Is text))
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
	OTr_zSetOK(0)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
