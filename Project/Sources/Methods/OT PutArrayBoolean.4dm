//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT PutArrayBoolean_New (inObject; inTag; inIndex; inValue)

// Sets a single element of a Boolean array item.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_b  : Boolean : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_b : Boolean)

OTr_zAddToCallStack(Current method name)

OTr_zLock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Boolean array; $inValue_b)
OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
