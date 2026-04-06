//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayPointer_New (inObject; inTag; inIndex; inValue)

// Sets a single element of a Pointer array item.
// Pointers are serialised via OTr_uPointerToText for storage.
// Note: Pointer values are process-local. A pointer stored
// from one process may not resolve correctly in another.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i  : Integer : OTr inObject
//   $inTag_t     : Text    : Tag path to the array item (inTag)
//   $inIndex_i   : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_ptr : Pointer : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_ptr : Pointer)

var $encoded_t : Text

$encoded_t := OTr_uPointerToText($inValue_ptr)
OTr_zLock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Pointer array; $encoded_t)
OTr_zUnlock