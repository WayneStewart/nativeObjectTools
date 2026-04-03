//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: OTr_BLOBToObject (inBLOB) --> Longint

  // Deserialises an OTr object from a BLOB previously created by
  // OTr_ObjectToBLOB or OTr_ObjectToNewBLOB. Returns a new handle.

  // **ORIGINAL DOCUMENTATION**
  // 
  // *OT BLOBToObject* deserialises an object from a BLOB and returns
  // a new object handle.
  // 
  // If the BLOB is empty or does not contain a valid serialised
  // Object, an error is generated, OK is set to zero, and zero is
  // returned.
  // 
  // **Warning:** The handle returned is a new object added to OTr's
  // internal list. Clear it with *OTr_Clear* when no longer needed.

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
  // ----------------------------------------------------

#DECLARE($inBLOB_blob : Blob)->$handle_i : Integer

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

		OTr_zSetOK(1)
		OTr_zUnlock

	End if

End if
