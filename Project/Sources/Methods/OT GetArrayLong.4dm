//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetArrayLong_New (inObject; inTag; inIndex) --> Longint

// Retrieves a single Integer element from a LongInt or
// Integer array item at the specified 1-based index.
// Returns 0 if the handle is invalid, the tag does not
// exist, the item is not a LongInt/Integer array, or the
// index is out of range.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_i : Integer : Element value, or 0 on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_i : Integer

OTr_zAddToCallStack(Current method name)

$result_i := OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; LongInt array)

OTr_zRemoveFromCallStack(Current method name)
