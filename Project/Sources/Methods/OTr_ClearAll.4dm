//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ClearAll

// Clears all OTr handles and backing storage arrays.

// Access: Shared

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

OTr__Lock

ARRAY OBJECT(<>OTR_Objects_ao; 0)
ARRAY BOOLEAN(<>OTR_InUse_ab; 0)

ARRAY BLOB(<>OTR_Blobs_ax; 0)
ARRAY BOOLEAN(<>OTR_BlobInUse_ab; 0)

ARRAY PICTURE(<>OTR_Pictures_ap; 0)
ARRAY BOOLEAN(<>OTR_PicInUse_ab; 0)

OTr__Unlock
