//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ObjectToNewBLOB (inObject) --> Blob

// Serialises an OTr object into a new BLOB and returns it as
// the function result. This is the recommended serialisation
// method because it avoids the by-reference BLOB parameter
// issues associated with OTr_ObjectToBLOB.

// **ORIGINAL DOCUMENTATION**

// *OT ObjectToNewBLOB* stores an object into a new *BLOB*.

// Once stored within a *BLOB*, you must retrieve an object from it with
// *OT BLOBToObject*, not with BLOB TO VARIABLE.

// If *inObject* is not a valid object handle or if memory cannot be
// allocated to copy the object, an error is generated, *OK* is set to
// zero, and an empty *BLOB* is returned.

// Warning: Do not attempt to open an object saved in ObjectTools 4 with
// a version earlier than v3.

// The object passed to *OT ObjectToNewBLOB* is copied into the *BLOB*
// and remains in memory. You must be sure to clear it with *OT Clear*
// when you no longer need it.

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

OTr_z_AddToCallStack(Current method name:C684)

OTr_ObjectToBLOB($inObject_i; ->$result_blob)

OTr_z_RemoveFromCallStack(Current method name:C684)
