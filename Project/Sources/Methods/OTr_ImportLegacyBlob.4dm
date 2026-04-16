//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ImportLegacyBlob (inBLOB) --> Longint

// Imports a legacy ObjectTools object BLOB into a new OTr handle.
//
// This is the explicit public compatibility entry point for BLOBs
// exported by the legacy ObjectTools plugin with OT ObjectToBLOB or
// OT ObjectToNewBLOB. 

// The imported object is converted into native OTr
// storage and can then be accessed with normal OTr getters and saved
// with OTr_ObjectToBLOB or OTr_ObjectToNewBLOB.
//
// Access: Shared
//
// Parameters:
//   $inBLOB_blob : Blob : Legacy ObjectTools object BLOB
//
// Returns:
//   $handle_i : Integer : New OTr handle, or 0 on error
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added explicit public legacy OT BLOB import API.
// ----------------------------------------------------

#DECLARE($inBLOB_blob : Blob)->$handle_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

$handle_i:=0

If (BLOB size:C605($inBLOB_blob)=0)
	OTr_z_Error("BLOB is empty"; Current method name:C684)
	OTr_z_SetOK(0)
Else 
	If (OTr_z_OTBlobIsObject($inBLOB_blob))
		$handle_i:=OTr_BLOBToObject($inBLOB_blob)
	Else 
		OTr_z_Error("BLOB is not a legacy ObjectTools object BLOB"; Current method name:C684)
		OTr_z_SetOK(0)
	End if 
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
