//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_Unlock

// Releases the OTr registry semaphore with reentrant lock counting.
//
// Decrements OTR_LockCount_i. The semaphore is only cleared when
// the counter reaches 0, meaning the outermost OTr_z_Lock / OTr_z_Unlock
// pair has completed and no nested locks remain outstanding.
//
// Every OTr_z_Unlock call must be paired with exactly one prior OTr_z_Lock call.

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
	CLEAR SEMAPHORE:C144(<>OTR_Semaphore_t)
End if 
