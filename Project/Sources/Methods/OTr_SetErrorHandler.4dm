//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SetErrorHandler (inNewHandler) --> Text

// Sets the current OTr error handler and returns the previous value.

// **ORIGINAL DOCUMENTATION**

// *OT SetErrorHandler* sets the action to perform when ObjectTools encounters an error.
// The previous error handler is returned.

// If you pass the name of an existing 4D method in *inHandler*, that method will be
// called when an error occurs. The handler method must accept four parameters:
// - *message* (Text): a description of the error
// - *method* (Text): the name of the ObjectTools method that was called
// - *object* (LongInt): the object handle involved, or zero if none
// - *tag* (Text): the tag being referenced, or empty if none

// Whether or not an error handler is set, *OK* is set to zero whenever an error occurs.
// *OT SetErrorHandler* returns the old handler so that you may dynamically change error
// handling within your code.

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
