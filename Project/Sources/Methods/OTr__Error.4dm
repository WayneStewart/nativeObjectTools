//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr__Error ($message_t : Text; $source_t : Text) --> \
//   $handled_b : Boolean

// Sends an OTr error to the configured handler when available.

// Access: Private

// Parameters:
//   $message_t : Text : Error message
//   $source_t  : Text : Source method name or context

// Returns:
//   $handled_b : Boolean : True if a custom handler was called

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($message_t : Text; $source_t : Text)->$handled_b : Boolean

var $handler_t : Text

$handled_b:=False

$handler_t:=<>OTR_ErrorHandler_t
If ($handler_t#"")
	EXECUTE METHOD($handler_t)
	$handled_b:=True
End if
