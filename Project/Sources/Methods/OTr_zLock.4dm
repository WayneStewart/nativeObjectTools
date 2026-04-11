//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zLock

// Acquires the OTr registry semaphore with reentrant lock counting.
//
// OTR_LockCount_i is a process variable initialised to 0.
// On the first call from a given process the semaphore is acquired
// and the counter is set to 1. Subsequent nested calls (same process,
// same call stack) simply increment the counter and return immediately
// — the semaphore call is bypassed so no deadlock can occur.
//
// Every OTr_zLock call must be paired with exactly one OTr_zUnlock call.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// 2026-04-11 - Reentrant lock count added (OTR_LockCount_i).
// ----------------------------------------------------

OTr_zInit

If (OTR_LockCount_i=0)
	While (Semaphore(<>OTR_Semaphore_t; 10))
		IDLE
	End while
End if

OTR_LockCount_i:=OTR_LockCount_i+1
