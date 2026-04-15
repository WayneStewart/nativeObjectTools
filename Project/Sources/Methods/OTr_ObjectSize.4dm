//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ObjectSize (inObject) --> Longint

// Returns an approximation of the memory size of an OTr object. Note: byte counts
// will not match the legacy plugin exactly.

// **WARNING: Changed Behaviour**

// The value is based on OTr's native 4D serialisation of the object,
// not the in-memory byte size of the legacy ObjectTools plugin
// structure. Treat values as OTr-only relative estimates.

// **ORIGINAL DOCUMENTATION**

// *OT ObjectSize* returns the total size of an object in memory. If *inObject* is not a
// valid object handle, an error is generated, *OK* is set to zero, and zero is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject

// Returns:
//   $size_i : Integer : Approximate size in characters, or 0 on error

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-05 - Removed erroneous per-key BLOB/Picture
//   size loop. BLOBs and Pictures are embedded in the Object; no
//   external accumulation is required or correct.
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_z_SetOK(1) on
//   success path (see OTr-OK0-Conditions specification).
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)->$size_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $temp_blob : Blob

$size_i:=0
OTr_z_Init

If (OTr_z_IsValidHandle($inObject_i))
	
	VARIABLE TO BLOB:C532(<>OTR_Objects_ao{$inObject_i}; $temp_blob)
	$size_i:=BLOB size:C605($temp_blob)
	SET BLOB SIZE:C606($temp_blob; 0)
	
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

// OTr_z_Unlock // Unnecessary to lock for Read Only access

OTr_z_RemoveFromCallStack(Current method name:C684)
