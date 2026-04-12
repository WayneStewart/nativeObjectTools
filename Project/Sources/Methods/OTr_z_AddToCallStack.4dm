//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_AddToCallStack (inMethodName)

// Pushes a public OTr method onto the current process call stack.

// Access: Private

// Parameters:
//   $inMethodName_t : Text : Method name to push onto the call stack

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 call-stack push helper.
// ----------------------------------------------------

#DECLARE($inMethodName_t : Text)

OTr_z_Init

If (Storage:C1525.OT_Logging.level#"off")
	APPEND TO ARRAY:C911(OTR_callStack_at; $inMethodName_t)
End if 
