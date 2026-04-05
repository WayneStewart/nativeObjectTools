//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayPointer_New (inObject; inTag; inIndex) --> Pointer

// Retrieves a single element from a Pointer array item.
// The stored text is deserialised via OTr_uTextToPointer.
// Returns a Null pointer on any error or out-of-range index.
// Note: Pointer values are process-local. A pointer stored
// from one process may not resolve correctly in another.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_ptr : Pointer : Element value, or Null on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_ptr : Pointer

OK:=1
var $raw_v : Variant

$result_ptr := Null
$raw_v := OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Pointer array)
If (Value type($raw_v) # Is undefined)
	$result_ptr := OTr_uTextToPointer($raw_v)
End if
