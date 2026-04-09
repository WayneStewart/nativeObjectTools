//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_LoadFromGZIP (inBlob) --> Longint

// Loads an object from a GZIPed JSON blob (written by
// OTr_SaveToGZIP) into a new OTr handle. The blob is
// expanded and decoded as UTF-8 text before being parsed
// as JSON. Delegates parsing to OTr_LoadFromText.
// Returns 0 if the blob is empty or cannot be decoded.

// Access: Shared

// Parameters:
//   $inBlob_blob : Blob : GZIPed JSON blob \
//                         (from OTr_SaveToGZIP)

// Returns:
//   $handle_i : Integer : New OTr handle, \
//                         or 0 if loading failed

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob)->$handle_i : Integer

OTr_zAddToCallStack(Current method name)

var $json_t : Text

$handle_i:=0

If (BLOB size($inBlob_blob)>0)
	EXPAND BLOB($inBlob_blob)
	$json_t:=Convert to text($inBlob_blob; UTF8 text without length)
	$handle_i:=OTr_LoadFromText($json_t)
End if

OTr_zRemoveFromCallStack(Current method name)
