//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_IsObject (inObject) --> Longint

// Returns 1 when a handle is valid and in use, otherwise 0.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject

// Returns:
//   $isObject_i : Integer : 1 when handle is valid, otherwise 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)->$isObject_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	$isObject_i:=1
Else
	$isObject_i:=0
End if

OTr_zUnlock
