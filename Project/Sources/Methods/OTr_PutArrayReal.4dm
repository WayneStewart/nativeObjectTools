//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayReal_New (inObject; inTag; inIndex; inValue)

// Sets a single element of a Real array item.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_r  : Real    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_r : Real)

OTr_zAddToCallStack(Current method name)

OTr_zLock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Real array; $inValue_r)
OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
