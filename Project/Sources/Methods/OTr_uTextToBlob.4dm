//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uTextToBlob ($encoded_t : Text) --> Blob

// Decodes a "blob:<base64>" Text string back to a BLOB.
// Returns an empty BLOB if the input is empty.

// Access: Private

// Parameters:
//   $encoded_t : Text : Base64-encoded text

// Returns:
//   $theBlob_x : Blob : Decoded BLOB, or empty BLOB on failure

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Rewritten: pure base64 decoder;
//     no parallel array slot management.
// ----------------------------------------------------

#DECLARE($encoded_t : Text)->$theBlob_x : Blob

If (Length($encoded_t) > 5)
        BASE64 DECODE(Substring($encoded_t; 6); $theBlob_x)
End if
