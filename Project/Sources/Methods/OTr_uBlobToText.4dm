//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uBlobToText ($theBlob_x : Blob) --> Text

// Base64-encodes a BLOB to a Text string for inline storage
// in an OTr Object property. Used only when
// Storage.OTr.nativeBlobInObject is False (v19 or v19R1).
// Returns empty text if the BLOB is empty.

// Access: Private

// Parameters:
//   $theBlob_x : Blob : The BLOB to encode

// Returns:
//   $blobRef_t : Text : Base64-encoded representation

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Rewritten: pure base64 encoder;
//     no parallel array slot management.
// ----------------------------------------------------

#DECLARE($theBlob_x : Blob)->$blobRef_t : Text

If (BLOB SIZE($theBlob_x) > 0)
	BASE64 ENCODE($theBlob_x; $blobRef_t; *)
End if
