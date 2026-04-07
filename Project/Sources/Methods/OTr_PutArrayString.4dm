//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayString_New (inObject; inTag; inIndex; inValue)

// Sets a single element of a Text or String array item.
// Text array and String array are interchangeable.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_t  : Text    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_t : Text)

OTr_zAddToCallStack(Current method name)

OTr_zLock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Text array; $inValue_t)
OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
