//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_Unlock ({$inObject_i : Integer})

// Releases the appropriate OTr semaphore with reentrant lock counting.
// Dispatches on Storage.OTr.mechanism.
//
// IP Arrays mechanism ($inObject_i ignored):
//   Existing single-semaphore path against <>OTR_Semaphore_t / OTR_LockCount_i.
//   Preserved unchanged from v0.5.
//
// Storage mechanism:
//   $inObject_i = 0 (default, omitted) — controller semaphore path.
//   $inObject_i > 0 — group semaphore path; group index = $inObject_i % 10.
//   An unlock without a matching lock is a programming error: the counter is
//   reset to 0, OK is set to 0, and OTr_z_Error is called.
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
//       under-decrement guard (error + reset) added for Storage paths.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)

var $digit_i : Integer

Case of
	: (Storage:C1525.OTr.mechanism=OTR IP Arrays)
		// Scalar path — unchanged from v0.5.
		If (OTR_LockCount_i>0)
			OTR_LockCount_i:=OTR_LockCount_i-1
		End if
		If (OTR_LockCount_i=0)
			CLEAR SEMAPHORE:C144(<>OTR_Semaphore_t)
		End if

	: (Storage:C1525.OTr.mechanism=OTR Storage)
		If ($inObject_i=0)
			// Controller path.
			OTr_ControllerLockDepth_i:=OTr_ControllerLockDepth_i-1
			If (OTr_ControllerLockDepth_i<0)
				// Programming error: unlock without matching lock.
				OTr_ControllerLockDepth_i:=0
				OTr_z_Error("OTr_z_Unlock: controller unlock without matching lock"; "OTr_z_Unlock")
			Else
				If (OTr_ControllerLockDepth_i=0)
					CLEAR SEMAPHORE:C144(Storage:C1525.OTr.controllerSemaphore)
				End if
			End if
		Else
			// Group path.
			$digit_i:=$inObject_i%10
			OTr_LockDepth_ci[$digit_i]:=OTr_LockDepth_ci[$digit_i]-1
			If (OTr_LockDepth_ci[$digit_i]<0)
				// Programming error: unlock without matching lock.
				OTr_LockDepth_ci[$digit_i]:=0
				OTr_z_Error("OTr_z_Unlock: group "+String:C10($digit_i)+" unlock without matching lock"; "OTr_z_Unlock")
			Else
				If (OTr_LockDepth_ci[$digit_i]=0)
					CLEAR SEMAPHORE:C144(Storage:C1525.OTr.semaphoreNames[$digit_i])
				End if
			End if
		End if

End case
