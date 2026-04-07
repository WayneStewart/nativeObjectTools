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

If (Storage.OTr.logInitialised_b=True)
	var $openHandles_i : Integer
	var $slot_i : Integer
	
	$openHandles_i:=0
	For ($slot_i; 1; Size of array(<>OTR_InUse_ab))
		If (<>OTR_InUse_ab{$slot_i})
			$openHandles_i:=$openHandles_i+1
		End if
	End for 
	
	If (Storage.OTr.logLevel#"off")
		OTr_zLogWrite("info"; "env"; "ObjectTools shutdown - "+String($openHandles_i)+" handles open")
	End if 
	
	LOG CLOSE LOG
	LOG STOP LOG WRITER
	LOG ENABLE(False)
	Use (Storage.OTr)
		Storage.OTr.logInitialised_b:=False
	End use
End if
