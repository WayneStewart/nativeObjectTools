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
	LOG ENABLE(False)
	LOG STOP LOG WRITER
	Use (Storage.OTr)
		Storage.OTr.logInitialised_b:=False
	End use
End if
