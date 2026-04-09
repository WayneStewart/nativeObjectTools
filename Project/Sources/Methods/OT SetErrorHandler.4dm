//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT SetErrorHandler (inNewHandler) --> Text

// Sets the current OTr error handler and returns the previous value.

// Access: Shared

// Parameters:
//   $inNewHandler_t : Text : Method name to use as error handler (inNewHandler)

// Returns:
//   $previousHandler_t : Text : Previously registered handler method name

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inNewHandler_t : Text)->$previousHandler_t : Text

OTr_zAddToCallStack(Current method name)

OTr_zLock

$previousHandler_t:=<>OTR_ErrorHandler_t
<>OTR_ErrorHandler_t:=$inNewHandler_t

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
