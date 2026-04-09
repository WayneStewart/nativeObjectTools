//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetText (inObject; inTag) --> Text

// Retrieves a Text value from the specified tag path.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_t : Text : Stored value, or empty text on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_t : Text

OTr_zAddToCallStack(Current method name)

$result_t:=OTr_GetString($inObject_i; $inTag_t)

OTr_zRemoveFromCallStack(Current method name)
