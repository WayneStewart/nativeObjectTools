//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SetErrorHandler ($handler_t : Text) --> \
//   $previousHandler_t : Text

// Sets the current OTr error handler and returns the previous value.

// Access: Shared

// Parameters:
//   $handler_t : Text : Method name to execute for OTr errors

// Returns:
//   $previousHandler_t : Text : Previously configured handler method name

// Created by Wayne Stewart, 2026-03-31
// ----------------------------------------------------

#DECLARE($handler_t : Text)->$previousHandler_t : Text

OTr__Lock

$previousHandler_t:=<>OTR_ErrorHandler_t
<>OTR_ErrorHandler_t:=$handler_t

OTr__Unlock
