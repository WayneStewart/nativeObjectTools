//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayPicture_New (inObject; inTag; inIndex) --> Picture

// Retrieves a single element from a Picture array item.
// Pictures are stored natively in the object property.
// Returns an empty Picture on any error or out-of-range index.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_pic : Picture : Element value, or empty Picture on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_pic : Picture

$result_pic := OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Picture array)
