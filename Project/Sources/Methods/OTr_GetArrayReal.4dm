//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayReal (inObject; inTag; inIndex) --> Real

// Retrieves a single element from a Real array item.
// Returns 0 on any error or out-of-range index.
// OK is unchanged on success; set to 0 on any failure.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_r : Real : Element value, or 0 on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_r : Real

OTr_zAddToCallStack(Current method name:C684)

$result_r:=OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Real array:K8:17)

OTr_zRemoveFromCallStack(Current method name:C684)
