//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutText (inObject; inTag; inValue)

// Stores a Text value at the specified tag path.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_t  : Text    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_t : Text)

OTr_zAddToCallStack(Current method name)

OTr_PutString($inObject_i; $inTag_t; $inValue_t)

OTr_zRemoveFromCallStack(Current method name)
