//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: OTr_ObjectToBLOB (inObject; ioBLOB {; append})

  // Serialises an OTr object into a BLOB using the OTR1 binary
  // format. Binary data (BLOBs and Pictures stored as parallel-array
  // references) is embedded in the BLOB as a binary attachment table.
  // 
  // Because 4D passes BLOBs by value, *ioBLOB* must be passed as a
  // Pointer to a BLOB variable: OTr_ObjectToBLOB($h; ->$myBlob).
  // Use OTr_ObjectToNewBLOB for the simpler function-result form.

  // **ORIGINAL DOCUMENTATION**
  // 
  // *OT ObjectToBLOB* serialises an object into a BLOB. The previous
  // contents of the BLOB, if any, are completely replaced, unless a
  // non-zero value is passed in *append*, in which case the serialised
  // object is appended to the existing BLOB contents.
  // 
  // Once stored within a BLOB, you must retrieve an object from it
  // with *OTr_BLOBToObject*, not with *BLOB TO VARIABLE*.
  // 
  // If *inObject* is not a valid object handle, an error is generated,
  // OK is set to zero, and *ioBLOB* is cleared.
  // 
  // **Warning:** Do not pass a BLOB field or a dereferenced pointer to
  // a BLOB field in the *ioBLOB* parameter. Use an intermediate local
  // variable or *OTr_ObjectToNewBLOB* instead.
  // 
  // **Note:** The object remains in memory after serialisation. Clear
  // it with *OTr_Clear* when no longer needed.

  // Access: Shared

  // Parameters:
  //   $inObject_i : Integer : OTr inObject (handle)
  //   $ioBLOB_ptr : Pointer : Pointer to the BLOB variable to receive the data
  //   $append_i   : Integer : 0 = replace (default), non-zero = append
  //                           (optional)

  // Returns: Nothing

  // Created by Wayne Stewart, 2026-04-03
  // Based on work by himself, Rob Laveaux, and Cannon Smith.
  // Wayne Stewart, 2026-04-03 - Changed $ioBLOB param from Blob to Pointer
  //       because 4D passes BLOBs by value; callers must pass ->$blobVar.
  // ----------------------------------------------------

#DECLARE($inObject_i : Integer; $ioBLOB_ptr : Pointer; $append_i : Integer)

var $snapshot_o : Object
var $expanded_o : Object
var $varBlob_blob : Blob
var $workBlob_blob : Blob
var $doAppend_i : Integer

$doAppend_i := Choose(Count parameters < 3; 0; $append_i)

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))

	//MARK:- Snapshot and expand binaries (inside lock)
	$snapshot_o := OB Copy(<>OTR_Objects_ao{$inObject_i})
	$expanded_o := OTr_uExpandBinaries($snapshot_o)

	OTr_zUnlock

	//MARK:- Serialise self-contained expanded object
	VARIABLE TO BLOB($expanded_o; $varBlob_blob)

	//MARK:- Build OTR1 BLOB: magic(4) + varBlobLen(4) + varBlobData
	CONVERT FROM TEXT("OTR1"; "US-ASCII"; $workBlob_blob)
	LONGINT TO BLOB(BLOB SIZE($varBlob_blob); $workBlob_blob; Native byte ordering)
	COPY BLOB($varBlob_blob; $workBlob_blob; 0; BLOB SIZE($workBlob_blob); BLOB SIZE($varBlob_blob))

	//MARK:- Write result to caller via pointer
	If ($doAppend_i = 0)
		SET BLOB SIZE($ioBLOB_ptr->; 0)
		COPY BLOB($workBlob_blob; $ioBLOB_ptr->; 0; 0; BLOB SIZE($workBlob_blob))
	Else
		COPY BLOB($workBlob_blob; $ioBLOB_ptr->; 0; BLOB SIZE($ioBLOB_ptr->); BLOB SIZE($workBlob_blob))
	End if

	OTr_zSetOK(1)

Else
	OTr_zError("Invalid inObject"; Current method name)
	SET BLOB SIZE($ioBLOB_ptr->; 0)
	OTr_zSetOK(0)
	OTr_zUnlock

End if
