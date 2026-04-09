//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT PutArrayLong_New (inObject; inTag; inIndex; inValue)

// Sets a single element of a LongInt or Integer array item.
// The tag must reference an existing LongInt or Integer array
// and $inIndex_i must be in range 0..numElements.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_i  : Integer : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_i : Integer)

OTr_zAddToCallStack(Current method name)

OTr_zLock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; LongInt array; $inValue_i)
OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
