//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zLogGetCallStack (inSource) -> outCallStack

// Builds the error call stack text for log column C5.

// Access: Private

// Parameters:
//   $inSource_t : Text : Source method/context for the log entry

// Returns:
//   $outCallStack_t : Text : Stack text (outermost -> innermost)

// Created by Wayne Stewart, 2026-04-10
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inSource_t : Text) -> $outCallStack_t : Text

var $arrow_t : Text
var $frame_t : Text
var $index_i : Integer
var $stackSize_i : Integer

$outCallStack_t:=""
$arrow_t:=OT Right Arrow
If ($arrow_t="")
	$arrow_t:="->"
End if 

$stackSize_i:=Size of array(OTR_callStack_at)
For ($index_i; 1; $stackSize_i)
	$frame_t:=OTR_callStack_at{$index_i}
	If ($outCallStack_t="")
		$outCallStack_t:=$frame_t
	Else 
		$outCallStack_t:=$outCallStack_t+" "+$arrow_t+" "+$frame_t
	End if 
End for 

If ($inSource_t#"")
	If ($stackSize_i=0)
		$outCallStack_t:=$inSource_t
	Else 
		If (OTR_callStack_at{$stackSize_i}#$inSource_t)
			$outCallStack_t:=$outCallStack_t+" "+$arrow_t+" "+$inSource_t
		End if 
	End if 
End if 