//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uBlobToText ($theBlob_blob : Blob) --> Text

// Base64-encodes a BLOB to a plain Text string for inline storage
// in an OTr Object property on 4D versions prior to v19 R2 (that is,
// where Storage.OTr.nativeBlobInObject is False). Returns empty text
// if the BLOB is empty. No sentinel prefix is produced.

// Access: Private

// Parameters:
//   $theBlob_blob : Blob : The BLOB to encode

// Returns:
//   $blobRef_t : Text : Base64-encoded representation

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Rewritten: pure base64 encoder;
//     no parallel array slot management.
// ----------------------------------------------------

#DECLARE($theBlob_blob : Blob)->$blobRef_t : Text

If (BLOB size:C605($theBlob_blob)>0)
	BASE64 ENCODE:C895($theBlob_blob)
	$blobRef_t:=Convert to text:C1012($theBlob_blob; "US-ASCII")
End if 

