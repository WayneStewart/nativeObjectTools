//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutBLOB (inObject; inTag; inValue)

// Stores a BLOB value at the specified tag path. On 4D v19 R2
// and later (where Storage.OTr.nativeBlobInObject is True) the
// BLOB is stored natively via OB SET. On earlier versions the
// BLOB is encoded as plain base64 text via OTr_uBlobToText. Both
// representations survive VARIABLE TO BLOB serialisation and are
// recognised by OTr_zMapType.

// **ORIGINAL DOCUMENTATION**

// OT PutBLOB puts *inValue* into *inObject*.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to
// zero. If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type Is BLOB, its value is replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

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
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Actually honours
//   Storage.OTr.nativeBlobInObject (previously only claimed to in
//   the changelog; the body always stored base64 text).
// Wayne Stewart, 2026-04-10 - Under the fallback path, writes a
//   shadow-type key (leafKey$type := Is BLOB = 30) so OTr_zMapType can
//   distinguish an encoded BLOB from ordinary user text. The
//   native-storage path removes any lingering shadow.
// Wayne Stewart, 2026-04-12 - Native path now also writes the shadow
//   key (leafKey$type := Is BLOB = 30). OB Get type misreports native BLOBs
//   as Is object (38) in 4D v20-v21 (same issue as Pictures); the shadow
//   key lets OTr_zMapType return the correct type (Is BLOB = 30) regardless
//   of the misreport.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_blob : Blob)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True; ->$parent_o; ->$leafKey_t))
		If (Storage.OTr.nativeBlobInObject)
			OB SET($parent_o; $leafKey_t; $inValue_blob)
			OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is BLOB:K8:12)
		Else
			OB SET($parent_o; $leafKey_t; OTr_uBlobToText($inValue_blob))
			OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is BLOB:K8:12)
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
	OTr_zSetOK(0)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
