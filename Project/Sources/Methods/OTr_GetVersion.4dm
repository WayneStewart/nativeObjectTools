//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetVersion () --> Text

// Returns the OTr implementation version string.

// Access: Shared

// Returns:
//   $version_t : Text : OTr version string

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE()->$version_t : Text

OTr_zAddToCallStack(Current method name)

$version_t:="OTr 0.5.0"

OTr_zRemoveFromCallStack(Current method name)
