//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_Lock ({$inObject_i : Integer})

// Acquires the appropriate OTr semaphore with reentrant lock counting.
// Dispatches on Storage.OTr.mechanism.
//
// IP Arrays mechanism ($inObject_i ignored):
//   Existing single-semaphore path against <>OTR_Semaphore_t / OTR_LockCount_i.
//   Preserved unchanged from v0.5.
//
// Storage mechanism:
//   $inObject_i = 0 (default, omitted) — controller semaphore path.
//   $inObject_i > 0 — group semaphore path; group index = $inObject_i % 10.
//
// NOTE: Not marked preemptive-capable. The IP Arrays branch reads/writes
// interprocess variables (<>OTR_Semaphore_t, OTR_LockCount_i), which are
// not permitted in preemptive processes. Preemptive support for the Storage
// branch will be enabled in W6/W8 when the Inner layer takes over lock
// acquisition and the IP Arrays Outer-layer wrappers are removed.

// Access: Private

// Parameters:
//   $inObject_i : Integer : Object handle (Storage mechanism only).
//                           0 = controller semaphore (default when omitted).

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// 2026-04-11 - Reentrant lock count added (OTR_LockCount_i).
// Wayne Stewart, 2026-05-19 - W2 (Phase 100): mechanism-aware dispatch; Storage
//       branch adds per-group and controller semaphore paths; $inObject_i added;
//       OTr_z_Init call removed (callers own initialisation).
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)

var $digit_i : Integer

Case of
	: (Storage:C1525.OTr.mechanism=OTR IP Arrays)
		// Scalar path — unchanged from v0.5.
		If (OTR_LockCount_i=0)
			While (Semaphore:C143(<>OTR_Semaphore_t; 10))
				IDLE:C311
			End while
		End if
		OTR_LockCount_i:=OTR_LockCount_i+1

	: (Storage:C1525.OTr.mechanism=OTR Storage)
		If ($inObject_i=0)
			// Controller path.
			OTr_ControllerLockDepth_i:=OTr_ControllerLockDepth_i+1
			If (OTr_ControllerLockDepth_i=1)
				While (Semaphore:C143(Storage:C1525.OTr.controllerSemaphore; 10))
					IDLE:C311
				End while
			End if
		Else
			// Group path.
			$digit_i:=$inObject_i%10
			OTr_LockDepth_ci[$digit_i]:=OTr_LockDepth_ci[$digit_i]+1
			If (OTr_LockDepth_ci[$digit_i]=1)
				While (Semaphore:C143(Storage:C1525.OTr.semaphoreNames[$digit_i]; 10))
					IDLE:C311
				End while
			End if
		End if

End case
