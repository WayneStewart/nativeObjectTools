//%attributes = {"invisible":true,"preemptive":"capable"}
// ----------------------------------------------------
// Project Method: OTr_z_InitStorage

// Thread-safe per-process initialisation for the Storage mechanism.
// Initialises OTr_LockDepth_ci and OTr_ControllerLockDepth_i for the
// calling process.

// Called at the start of every preemptive method that uses OTr Storage
// paths. OTr_z_Init must have been called from a cooperative context at
// startup before any preemptive workers that use OTr are spawned.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-05-19
// ----------------------------------------------------

If (Not:C34(OTr_StorageInitialised_b))
	OTr_LockDepth_ci:=New collection:C1472(0; 0; 0; 0; 0; 0; 0; 0; 0; 0)
	OTr_ControllerLockDepth_i:=0
	OTr_StorageInitialised_b:=True:C214
End if
