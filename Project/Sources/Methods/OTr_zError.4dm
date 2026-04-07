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
var $stack_t : Text
var $stackSize_i : Integer
var $index_i : Integer

$handled_b:=False:C215

OTr_zInit

$logMessage_t:=$message_t
$stack_t:=""
$stackSize_i:=Size of array(OTR_callStack_at)
If ($source_t#"")
	$stack_t:=$source_t
End if

For ($index_i; $stackSize_i; 1; -1)
	If (OTR_callStack_at{$index_i}#$source_t)
		If ($stack_t="")
			$stack_t:=OTR_callStack_at{$index_i}
		Else 
			$stack_t:=$stack_t+" < "+OTR_callStack_at{$index_i}
		End if
	End if
End for 

If ($stack_t#"")
	$logMessage_t:=$logMessage_t+" ["+$stack_t+"]"
End if

OTr_zLogWrite("error"; $source_t; $logMessage_t)

$handler_t:=<>OTR_ErrorHandler_t
If ($handler_t#"")
	EXECUTE METHOD:C1007($handler_t)
	$handled_b:=True:C214
End if 

