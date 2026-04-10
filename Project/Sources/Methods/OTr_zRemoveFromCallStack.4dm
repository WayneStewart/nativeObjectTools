//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zRemoveFromCallStack (inMethodName)

// Pops the current public OTr method from the process call stack.

// Access: Private

// Parameters:
//   $inMethodName_t : Text : Method name expected at the top of the stack

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 call-stack pop helper.
// ----------------------------------------------------

#DECLARE($inMethodName_t : Text)

var $stackSize_i : Integer

OTr_zInit

If (Storage:C1525.OT_Logging.level#"off")
	$stackSize_i:=Size of array:C274(OTR_callStack_at)
	If ($stackSize_i>0)
		DELETE FROM ARRAY:C228(OTR_callStack_at; $stackSize_i)
	End if 
End if 
