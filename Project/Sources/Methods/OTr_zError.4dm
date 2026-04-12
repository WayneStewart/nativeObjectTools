//%attributes = {"invisible":true,"shared":false}


// ----------------------------------------------------
// Project Method: OTr_zError ($message_t : Text; $source_t : Text) --> \
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
var $logMessage_t : Text

$handled_b:=False:C215

OTr_zInit

$logMessage_t:=$message_t

OTr_zLogWrite("error"; $source_t; $logMessage_t)

// Honour the legacy ObjectTools contract: OK is always set to zero on error.
// The legacy documentation specifies "OK is set to zero" 146 times and never
// specifies OK=1. Setting it here centrally ensures all error paths comply
// regardless of whether the calling method sets it explicitly.
OTr_zSetOK(0)

$handler_t:=<>OTR_ErrorHandler_t
If ($handler_t#"")
	EXECUTE METHOD:C1007($handler_t)
	$handled_b:=True:C214
End if 

