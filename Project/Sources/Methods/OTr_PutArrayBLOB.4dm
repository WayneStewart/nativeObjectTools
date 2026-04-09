//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayBLOB (inObject; inTag; inIndex; inValue)

// Sets a single element of a Blob array item.
// The BLOB is encoded to base64 text via OTr_uBlobToText for storage.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i   : Integer : OTr inObject
//   $inTag_t      : Text    : Tag path to the array item (inTag)
//   $inIndex_i    : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_blob : Blob    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_blob : Blob)

OTr_zAddToCallStack(Current method name:C684)

var $encoded_t : Text

$encoded_t:=OTr_uBlobToText($inValue_blob)
OTr_zLock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Blob array:K8:30; $encoded_t)
OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name:C684)
