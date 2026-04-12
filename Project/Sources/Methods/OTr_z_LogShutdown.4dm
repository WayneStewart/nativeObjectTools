//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_LogShutdown

// Performs the basic shutdown of the OTr logging subsystem.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 logging shutdown entry point.
// ----------------------------------------------------

OTr_z_Init

If (Storage:C1525.OT_Logging#Null:C1517)
	var $openHandles_i : Integer
	
	$openHandles_i:=OTr_GetActiveHandleCount
	
	If (Storage:C1525.OT_Logging.level#"off")
		OTr_z_LogWrite("info"; "env"; "ObjectTools shutdown - "+String:C10($openHandles_i)+" handles open")
	End if 
	
	LOG CLOSE LOG
	LOG STOP LOG WRITER
	LOG ENABLE(False:C215)
	
End if 
