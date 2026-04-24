//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT CompiledApplication () --> Longint

// Returns 1 when running in compiled mode; otherwise 0.

// **NOTE:** this is just running the 4D command: Is compiled mode(*)

// Access: Shared

// Returns:
//   $isCompiled_i : Integer : 1 when compiled, otherwise 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE()->$isCompiled_i : Integer

var $compiled_b : Boolean

OTr_z_AddToCallStack(Current method name:C684)

$compiled_b:=Is compiled mode:C492(*)

$isCompiled_i:=Num:C11($compiled_b)

OTr_z_RemoveFromCallStack(Current method name:C684)

