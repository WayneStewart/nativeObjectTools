// ----------------------------------------------------
// Project Method: On Host Database Event ($event_i : Integer)

// Handles host database lifecycle events for the OTr component.

// Access: Private

// Parameters:
//   $event_i : Integer : Host database lifecycle event code

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 lifecycle integration.
// ----------------------------------------------------

#DECLARE($event_i : Integer)

Case of 
	: ($event_i=1)
		OTr_Startup
		
	: ($event_i=3)
		OTr_zLogShutdown
		
End case 
