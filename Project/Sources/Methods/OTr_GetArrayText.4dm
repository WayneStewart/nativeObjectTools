//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayText (inObject; inTag; inIndex) --> Text

// Retrieves a single element from a Text or String array item.
// Alias for OTr_GetArrayString — Text and String arrays
// are interchangeable in OTr storage.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_t : Text : Element value, or "" on any failure

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_t : Text

$result_t:=OTr_GetArrayString($inObject_i; $inTag_t; $inIndex_i)
