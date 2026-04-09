//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayText (inObject; inTag; inIndex) --> Text

// Retrieves a single element from a Text or String array item.
// Alias for OTr_GetArrayString.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_t : Text : Element value, or "" on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_t : Text

OTr_zAddToCallStack(Current method name)

$result_t := OTr_GetArrayString($inObject_i; $inTag_t; $inIndex_i)

OTr_zRemoveFromCallStack(Current method name)
