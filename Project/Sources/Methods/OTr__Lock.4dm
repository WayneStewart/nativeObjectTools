//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr__Lock

// Acquires the OTr registry semaphore.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------


OTr__Init

While (Semaphore:C143(<>OTR_Semaphore_t; 10))
	IDLE:C311
End while 
