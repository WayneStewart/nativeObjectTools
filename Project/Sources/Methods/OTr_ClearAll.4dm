//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ClearAll

// Clears all OTr handles.

// Access: Shared

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

OTr_z_AddToCallStack(Current method name:C684)

OTr_z_Lock

ARRAY OBJECT:C1221(<>OTR_Objects_ao; 0)
ARRAY BOOLEAN:C223(<>OTR_InUse_ab; 0)

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
