//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetOptions () --> Longint

// Returns the current OTr options bit field.

// Access: Shared

// Returns:
//   $options_i : Integer : Current OTr options bit field

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE()->$options_i : Integer

OTr_zAddToCallStack(Current method name)

OTr_zInit

$options_i:=<>OTR_Options_i

OTr_zRemoveFromCallStack(Current method name)
