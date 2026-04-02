//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ClearAll

// Clears all OTr handles and backing storage arrays.

// Access: Shared

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

OTr_zLock

ARRAY OBJECT:C1221(<>OTR_Objects_ao; 0)
ARRAY BOOLEAN:C223(<>OTR_InUse_ab; 0)

ARRAY BLOB:C1222(<>OTR_Blobs_ablob; 0)
ARRAY BOOLEAN:C223(<>OTR_BlobInUse_ab; 0)

ARRAY PICTURE:C279(<>OTR_Pictures_apic; 0)
ARRAY BOOLEAN:C223(<>OTR_PicInUse_ab; 0)

OTr_zUnlock
