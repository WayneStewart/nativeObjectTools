//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: OTr_BLOBToObject (inBLOB) --> Longint

  // Deserialises an OTr object from a BLOB previously created by
  // OTr_ObjectToBLOB or OTr_ObjectToNewBLOB. Returns a new handle.

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
  //       OTR1 envelope. Now uses EXPAND BLOB + BLOB TO VARIABLE.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
  // Wayne Stewart, 2026-04-10 - Removed spurious OTr_zSetOK(1) on
  //   success path (see OTr-OK0-Conditions specification).
  // ----------------------------------------------------

#DECLARE($inBLOB_blob : Blob)->$handle_i : Integer

OTr_zAddToCallStack(Current method name)

var $work_blob : Blob
var $obj_o : Object
var $compressed_i : Integer

$handle_i := 0

If (BLOB SIZE($inBLOB_blob) = 0)
	OTr_zError("BLOB is empty"; Current method name)
	OTr_zSetOK(0)

Else

	$work_blob := $inBLOB_blob
	BLOB PROPERTIES($work_blob; $compressed_i)
	If ($compressed_i # Is not compressed)
		EXPAND BLOB($work_blob)
	End if

	BLOB TO VARIABLE($work_blob; $obj_o)

	If (OK = 0)
		OTr_zError("BLOB does not contain a valid OTr object"; Current method name)
		OTr_zSetOK(0)

	Else

		OTr_zLock

		$handle_i := Find in array(<>OTR_InUse_ab; False)
		If ($handle_i = -1)
			$handle_i := Size of array(<>OTR_InUse_ab)+1
			INSERT IN ARRAY(<>OTR_InUse_ab; $handle_i; 1)
			INSERT IN ARRAY(<>OTR_Objects_ao; $handle_i; 1)
		End if
		<>OTR_InUse_ab{$handle_i} := True
		<>OTR_Objects_ao{$handle_i} := $obj_o

		OTr_zUnlock

	End if

End if

OTr_zRemoveFromCallStack(Current method name)
