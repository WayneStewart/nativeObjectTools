//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetBLOB (inObject; inTag; outBLOB)

// NOT IMPLEMENTED — stub only.
// 
// This method cannot be reproduced in a native 4D component.
// The legacy OT GetBLOB plugin command could write back
// through the outBLOB parameter directly. In native 4D,
// BLOB parameters are passed by value (copy), so any
// assignment to the parameter inside the method has no
// effect on the caller's variable.
// 
// Use OTr_GetNewBLOB instead, which returns the BLOB as
// a function result.

// **ORIGINAL DOCUMENTATION**
// 
// *OT GetBLOB* retrieves a BLOB value from *inObject*
// into the *outBLOB* parameter.
// 
// Warning: Do not attempt to pass a BLOB field or a
// dereferenced pointer to a BLOB field in the outBLOB
// parameter. Use OTr_GetNewBLOB in preference.

// Access: Shared

// Parameters:
//   $inObject_i   : Integer : OTr inObject
//   $inTag_t      : Text    : Tag path (inTag)
//   $outBLOB_blob : Blob    : Not used — always returns empty

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $outBLOB_blob : Blob)

OTr_zError("OTr_GetBLOB is not implemented. Use OTr_GetNewBLOB instead."; Current method name)
OTr_zSetOK(0)