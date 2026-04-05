//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayBLOB_New (inObject; inTag; inIndex) --> Blob

// Retrieves a single element from a Blob array item.
// The stored base64 text is decoded via OTr_uTextToBlob.
// Returns an empty BLOB on any error or out-of-range index.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_blob : Blob : Element value, or empty BLOB on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_blob : Blob

var $raw_v : Variant

$raw_v := OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Blob array)
If (Value type($raw_v) # Is undefined)
	$result_blob := OTr_uTextToBlob($raw_v)
End if
