//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayDate_New (inObject; inTag; inIndex) --> Date

// Retrieves a single element from a Date array item.
// Stored text is decoded via OTr_uTextToDate.
// Returns !00/00/00! on any error or out-of-range index.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_d : Date : Element value, or !00/00/00! on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_d : Date

OTr_zAddToCallStack(Current method name)

var $raw_v : Variant

$raw_v := OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Date array)
If (Value type($raw_v) # Is undefined)
	$result_d := OTr_uTextToDate($raw_v)
End if

OTr_zRemoveFromCallStack(Current method name)
