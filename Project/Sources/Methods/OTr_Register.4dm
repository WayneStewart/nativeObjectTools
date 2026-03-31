//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_Register ($serial_t : Text) --> $result_i : Integer

// Compatibility no-op for OT Register; always succeeds.

// Access: Shared

// Parameters:
//   $serial_t : Text : Legacy registration string (ignored)

// Returns:
//   $result_i : Integer : 1 for success

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($serial_t : Text)->$result_i : Integer

$result_i:=1
