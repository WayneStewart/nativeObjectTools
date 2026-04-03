//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: OTr_ObjectToBLOB (inObject; ioBLOB {; inAppend})

  // Serialises an OTr object into a BLOB using VARIABLE TO BLOB
  // with GZIP compression. The object's contents (including natively
  // stored BLOBs and Pictures) are fully self-contained.
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
  //   $inAppend_i   : Integer : 0 = replace (default), non-zero = append (inAppend) (optional)

  // Returns: Nothing

  // Created by Wayne Stewart, 2026-04-03
  // Based on work by himself, Rob Laveaux, and Cannon Smith.
  // Wayne Stewart, 2026-04-03 - Changed $ioBLOB param from Blob to Pointer
  //       because 4D passes BLOBs by value; callers must pass ->$blobVar.
  // Wayne Stewart, 2026-04-03 - Rewritten: VARIABLE TO BLOB + GZIP compression;
  //       dropped OTR1 envelope and parallel-array expansion.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
  // ----------------------------------------------------

#DECLARE($inObject_i : Integer; $ioBLOB_ptr : Pointer; $inAppend_i : Integer)

var $obj_o : Object
var $serialised_blob : Blob
var $doAppend_i : Integer

$doAppend_i := Choose(Count parameters < 3; 0; $inAppend_i)

If ($ioBLOB_ptr = Null)
	OTr_zError("ioBLOB pointer is Nil"; Current method name)
	OTr_zSetOK(0)

Else

	OTr_zLock

	If (OTr_zIsValidHandle($inObject_i))
		$obj_o := OB Copy(<>OTR_Objects_ao{$inObject_i})
		OTr_zUnlock

		VARIABLE TO BLOB($obj_o; $serialised_blob)
		COMPRESS BLOB($serialised_blob; GZIP best compression mode)

		If ($doAppend_i = 0)
			SET BLOB SIZE($ioBLOB_ptr->; 0)
			COPY BLOB($serialised_blob; $ioBLOB_ptr->; 0; 0; BLOB SIZE($serialised_blob))
		Else
			COPY BLOB($serialised_blob; $ioBLOB_ptr->; 0; BLOB SIZE($ioBLOB_ptr->); BLOB SIZE($serialised_blob))
		End if

		OTr_zSetOK(1)

	Else
		OTr_zError("Invalid inObject"; Current method name)
		SET BLOB SIZE($ioBLOB_ptr->; 0)
		OTr_zSetOK(0)
		OTr_zUnlock

	End if

End if
