//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zLogShutdown

// Performs the basic shutdown of the OTr logging subsystem.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 logging shutdown entry point.
// ----------------------------------------------------

OTr_zInit

If (Storage:C1525.OT_LoggingInitialised_b=True:C214)
	var $openHandles_i : Integer
	var $slot_i : Integer
	
	$openHandles_i:=0
	For ($slot_i; 1; Size of array:C274(<>OTR_InUse_ab))
		If (<>OTR_InUse_ab{$slot_i})
			$openHandles_i:=$openHandles_i+1
		End if 
	End for 
	
	If (Storage:C1525.OT_Logging.level#"off")
		OTr_zLogWrite("info"; "env"; "ObjectTools shutdown - "+String:C10($openHandles_i)+" handles open")
	End if 
	
	LOG CLOSE LOG
	LOG STOP LOG WRITER
	LOG ENABLE(False:C215)
	Use (Storage:C1525.OTr)
		Storage:C1525.OT_LoggingInitialised_b:=False:C215
	End use 
End if 
