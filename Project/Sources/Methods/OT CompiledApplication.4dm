//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT CompiledApplication () --> Longint

// Returns 1 when running in compiled mode; otherwise 0.

// Access: Shared

// Returns:
//   $isCompiled_i : Integer : 1 when compiled, otherwise 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE()->$isCompiled_i : Integer

OTr_zAddToCallStack(Current method name)

If (Is compiled mode)
	$isCompiled_i:=1
Else
	$isCompiled_i:=0
End if

OTr_zRemoveFromCallStack(Current method name)
