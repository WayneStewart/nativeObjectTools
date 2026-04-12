//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SetErrorHandler (inNewHandler) --> Text

// Sets the current OTr error handler and returns the previous value.

// **ORIGINAL DOCUMENTATION**
// *OT* *SetErrorHandler** *sets the action to perform when ObjectTools encounters an error.
// The previous error handler is returned. By default, action is taken when an error occurs.
// If you pass the name of an existing 4D method in *inHandler*, that method will get called
// when an error occurs. The method must take four parameters: 3 message (C_TEXT): A
// description of the error that occurred. 3 method (C_TEXT): The name of the ObjectTools
// method that was called when the error occurred. 3 object (C_LONGINT): The longint
// reference of the object being operated on when the error occurred. If the error does not
// involve an object, this will be zero. 3 tag (C_TEXT): The tag of the object item being
// referenced when the error occurred. If the error does not involve a tag, this will be
// empty. Warning: If you are upgrading to ObjectTools 5 from a previous version, you must be
// sure to add the extra two parameters to your error handler methods. Note: If you put a
// TRACE statement at the end of your error handler method, when an error occurs the 4D
// debugger will come up. If you then step one line, you will be at the line after the one
// that caused the error. Whether or not an error handler is set, whenever an error occurs
// the *OK** *variable is set to zero. *OT* *SetErrorHandler** *returns the old handler so
// that you may dynamically change the error handling within your code.

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
