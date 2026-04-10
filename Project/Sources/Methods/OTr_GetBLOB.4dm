//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetBLOB (inObject; inTag; outBLOB)

// Retrieves a BLOB value from the specified tag path and
// writes it back to the caller's variable via the outBLOB
// pointer parameter. When Storage.OTr.nativeBlobInObject is
// True (4D v19 R2 and later), the property is read as a
// native BLOB via OB Get; otherwise it is read as plain
// base64 text and decoded via OTr_uTextToBlob. Writes an
// empty BLOB on any error or missing tag.

// **IMPLEMENTATION NOTE**
// In native 4D, BLOB parameters are passed by value, so a
// plain Blob parameter cannot be written back to the caller.
// The outBLOB parameter is therefore a Pointer, and callers
// must pass ->myBlobVar (pointer-to-BLOB syntax). The method
// writes the result back via $outBLOB_ptr->:=.
//
// This matches the idiom used by OTr_GetPointer.
// The legacy plugin command accepted a plain BLOB variable
// because it operated at C level; native 4D callers must
// use the -> syntax instead.
//
// Correct usage:
// ```
//   var myBlob : Blob
//   OTr_GetBLOB(handle; "tag"; ->myBlob)
// ```
//
// Alternatively, use OTr_GetNewBLOB which returns the BLOB
// as a function result and requires no pointer syntax.

// **ORIGINAL DOCUMENTATION**
//
// *OTr_GetBLOB* retrieves a BLOB value from *inObject*
// into the *outBLOB* parameter.
//
// If *inObject* is not a valid object handle, an error
// is generated, OK is set to zero, and an empty BLOB
// is written to outBLOB.
//
// If no item in the object has the given inTag, an empty
// BLOB is written to outBLOB. If the FailOnItemNotFound
// option is set, an error is generated and OK is set to zero.
//
// If an item with the given inTag exists and has the type
// *Is BLOB*, the value of the requested item is written
// to outBLOB.
//
// If an item with the given inTag exists and has any other
// type, an error is generated, OK is set to zero, and an
// empty BLOB is written to outBLOB.
//
// Warning: Do not attempt to pass a pointer to a BLOB field
// in the outBLOB parameter. Use OTr_GetNewBLOB in preference
// when retrieving into a field.

// Access: Shared

// Parameters:
//   $inObject_i  : Integer : OTr inObject
//   $inTag_t     : Text    : Tag path (inTag)
//   $outBLOB_ptr : Pointer : Pointer to caller's Blob variable (->outBLOB)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Implemented using Pointer parameter
//     (replaces stub). Mirrors OTr_GetNewBLOB logic; writes result
//     back via $outBLOB_ptr->:= dereference.
// Wayne Stewart, 2026-04-10 - Honours Storage.OTr.nativeBlobInObject.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $outBLOB_ptr : Pointer)

OTr_zAddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $result_blob : Blob

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			If (Storage:C1525.OTr.nativeBlobInObject)
				$result_blob:=OB Get:C1224($parent_o; $leafKey_t; Is BLOB:K8:12)
			Else
				$result_blob:=OTr_uTextToBlob(OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3))
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name:C684)
End if

$outBLOB_ptr->:=$result_blob

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name:C684)
