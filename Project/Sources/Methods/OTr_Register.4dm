//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_Register (inSerialNum) --> Longint

// Compatibility no-op for OTr_Register; always succeeds.

// Access: Shared

// Parameters:
//   $inSerialNum_t : Text : Registration serial number string (inSerialNum)

// Returns:
//   $result_i : Integer : 1 for success

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inSerialNum_t : Text)->$result_i : Integer

OTr_zAddToCallStack(Current method name)

$result_i:=1

OTr_zLogWrite("info"; "plugin"; "successfully registered ObjectTools")

OTr_zRemoveFromCallStack(Current method name)
