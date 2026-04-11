//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zUnlock

// Releases the OTr registry semaphore with reentrant lock counting.
//
// Decrements OTR_LockCount_i. The semaphore is only cleared when
// the counter reaches 0, meaning the outermost OTr_zLock / OTr_zUnlock
// pair has completed and no nested locks remain outstanding.
//
// Every OTr_zUnlock call must be paired with exactly one prior OTr_zLock call.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// 2026-04-11 - Reentrant lock count added (OTR_LockCount_i).
// ----------------------------------------------------

If (OTR_LockCount_i>0)
	OTR_LockCount_i:=OTR_LockCount_i-1
End if

If (OTR_LockCount_i=0)
	CLEAR SEMAPHORE(<>OTR_Semaphore_t)
End if
