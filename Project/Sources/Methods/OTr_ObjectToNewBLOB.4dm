//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ObjectToNewBLOB (inObject) --> Blob

// Serialises an OTr object into a new BLOB and returns it as
// the function result. This is the recommended serialisation
// method because it avoids the by-reference BLOB parameter
// issues associated with OTr_ObjectToBLOB.

// **ORIGINAL DOCUMENTATION**
// 
// *OTr_ObjectToNewBLOB* serialises an object into a new BLOB which
// is returned as the function result.
// 
// Once stored within a BLOB, you must retrieve an object from it
// with *OTr_BLOBToObject*, not with *BLOB TO VARIABLE*.
// 
// If *inObject* is not a valid object handle, an error is generated,
// OK is set to zero, and an empty BLOB is returned.
// 
// **Note:** The object remains in memory after serialisation. Clear
// it with *OTr_Clear* when no longer needed.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject (handle)

// Returns:
//   $result_blob : Blob : New BLOB containing the serialised object, or an empty BLOB on error

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)->$result_blob : Blob

OTr_zAddToCallStack(Current method name)

OTr_ObjectToBLOB($inObject_i; ->$result_blob)

OTr_zRemoveFromCallStack(Current method name)
