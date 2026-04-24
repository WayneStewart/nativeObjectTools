//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT BLOBToObject (inBLOB) --> Longint

// Deserialises an OTr object from a BLOB previously made by
// OT ObjectToBLOB or OT ObjectToNewBLOB. A new handle is returned.
// Legacy ObjectTools object BLOBs are detected and converted into the
// native OTr object storage shape when their item types are supported.

// **WARNING: Changed Behaviour**

// The legacy ioOffset parameter is not present; reading always starts
// at byte 0. If legacy code read from a non-zero offset, slice the BLOB
// before calling this method. OTr can import supported legacy OT object
// BLOB payloads, but OTr-generated BLOBs remain OTr-only.

// **ORIGINAL DOCUMENTATION**

// *OT BLOBToObject* retrieves an object from a *BLOB* into a new object
// handle. The object must have been stored in the *BLOB* with *OT
// ObjectToBLOB* or *OT ObjectToNewBLOB*, not with VARIABLE TO *BLOB*.

// If the bytes at the given offset do not describe an object stored with
// *OT ObjectToBLOB* or *OT ObjectToNewBLOB*, an error is generated, *OK*
// is set to zero, and a null handle (0) is returned.

// *OT BLOBToObject* transparently converts *BLOBs* created with earlier
// versions of ObjectTools.

// Warning: The handle returned is a new object that is added to
// ObjectTools' internal list of objects. You must be sure to clear the
// new object with *OT Clear* when you no longer need it.

// Access: Shared

// Parameters:
//   $inBLOB_blob : Blob : A BLOB containing a serialised OTr object

// Returns:
//   $handle_i : Integer : New OTr handle, or 0 on error

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Simplified: dropped ioOffset parameter and
//   OTR1 envelope. Now uses EXPAND BLOB + BLOB TO VARIABLE.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_z_SetOK(1) on
//   success path (see OTr-OK0-Conditions specification).
// Wayne Stewart, 2026-04-14 - Added legacy ObjectTools BLOB detection and
//   conversion for character, date, and character-array item payloads.
// ----------------------------------------------------

#DECLARE($inBLOB_blob : Blob)->$handle_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $work_blob : Blob
var $obj_o : Object
var $compressed_i : Integer

$handle_i:=0

If (BLOB size:C605($inBLOB_blob)=0)
	OTr_z_Error("BLOB is empty"; Current method name:C684)
	OTr_z_SetOK(0)
	
Else 
	
	If (OT x_OTBlobIsObject($inBLOB_blob))
		
		$obj_o:=OT x_OTBlobToObject($inBLOB_blob)
		
	Else 
		
		OTr_z_Error("BLOB not legacy format return OT x_OTBlobIsObject($inBLOB_blob) false"; Current method name:C684)
		
		$work_blob:=$inBLOB_blob
		BLOB PROPERTIES:C536($work_blob; $compressed_i)
		If ($compressed_i#Is not compressed:K22:11)
			EXPAND BLOB:C535($work_blob)
		End if 
		
		BLOB TO VARIABLE:C533($work_blob; $obj_o)
		
	End if 
	
	If ($obj_o=Null:C1517)
		If (OT x_OTBlobIsObject($inBLOB_blob))
			OTr_z_Error("BLOB contains unsupported legacy OT object data"; Current method name:C684)
		Else 
			OTr_z_Error("BLOB does not contain a valid OTr object"; Current method name:C684)
		End if 
		OTr_z_SetOK(0)
		
	Else 
		
		OTr_z_Lock
		
		$handle_i:=Find in array:C230(<>OTR_InUse_ab; False:C215)
		If ($handle_i=-1)
			$handle_i:=Size of array:C274(<>OTR_InUse_ab)+1
			INSERT IN ARRAY:C227(<>OTR_InUse_ab; $handle_i; 1)
			INSERT IN ARRAY:C227(<>OTR_Objects_ao; $handle_i; 1)
		End if 
		<>OTR_InUse_ab{$handle_i}:=True:C214
		<>OTR_Objects_ao{$handle_i}:=$obj_o
		
		OTr_z_Unlock
		
	End if 
	
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
