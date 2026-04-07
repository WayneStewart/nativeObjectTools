//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SetOptions (inOptions)

// Sets the current OTr options bit field.

// Access: Shared

// Parameters:
//   $inOptions_i : Integer : New OTr options bit field (inOptions)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inOptions_i : Integer)

OTr_zAddToCallStack(Current method name)

OTr_zLock

<>OTR_Options_i:=$inOptions_i

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
