//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_CompiledApplication () --> $isCompiled_i : Integer

// Returns 1 when running in compiled mode; otherwise 0.

// Access: Shared

// Returns:
//   $isCompiled_i : Integer : 1 when compiled, otherwise 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE()->$isCompiled_i : Integer

If (Is compiled mode)
	$isCompiled_i:=1
Else
	$isCompiled_i:=0
End if
