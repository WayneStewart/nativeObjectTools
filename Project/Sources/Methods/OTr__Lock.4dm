//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr__Lock

// Acquires the OTr registry semaphore.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// ----------------------------------------------------

var $semaphore_t : Text

$semaphore_t:="OTr_Registry"

OTr__Init

While (Semaphore($semaphore_t; 10))
	IDLE
End while
