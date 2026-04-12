//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetOptions () --> Longint

// Returns the current OTr options bit field.

// **ORIGINAL DOCUMENTATION**

// *OT GetVersion* returns a textual representation of the current numeric version of
// ObjectTools, along with information about the platform and build type.

// INDEX OF COMMANDS

// .............................................................

// Access: Shared

// Returns:
//   $options_i : Integer : Current OTr options bit field

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE()->$options_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

OTr_z_Init

$options_i:=<>OTR_Options_i

OTr_z_RemoveFromCallStack(Current method name:C684)
