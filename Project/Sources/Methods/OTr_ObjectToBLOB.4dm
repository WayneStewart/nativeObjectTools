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

// *OT ObjectToBLOB* stores an object into a *BLOB*. The previous
// contents of the *BLOB*, if any, are completely replaced, unless a
// non-zero value is passed in *inAppend*, in which case the object is
// appended to the *BLOB*.

// Once stored within a *BLOB*, you must retrieve an object from it with
// *OT BLOBToObject*, not with BLOB TO VARIABLE.

// If *inObject* is not a valid object handle or if memory cannot be
// allocated to copy the object, an error is generated, *OK* is set to
// zero, and the *BLOB* is cleared.

// Warning: Do not attempt to open an object saved in ObjectTools 4 with
// a version earlier than v3. Do not attempt to pass a *BLOB* field or a
// dereferenced pointer to a *BLOB* field as the *ioBLOB* parameter, as
// this will result in a crash. If you want to store a *BLOB* item into a
// field, either use an intermediate local variable or assign the result
// of *OT ObjectToNewBLOB* to the field.

// The object passed to *OT ObjectToBLOB* is copied into the *BLOB* and
// remains in memory. You must be sure to clear it with *OT Clear* when
// you no longer need it.

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
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_zSetOK(1) on
//   success path (see OTr-OK0-Conditions specification).
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $ioBLOB_ptr : Pointer; $inAppend_i : Integer)

OTr_zAddToCallStack(Current method name:C684)

var $inAppend_i : Integer

var $obj_o : Object
var $serialised_blob : Blob
var $doAppend_i : Integer

If (Count parameters:C259=3)
	$doAppend_i:=$inAppend_i
Else 
	$doAppend_i:=0
End if 

If ($ioBLOB_ptr=Null:C1517)
	OTr_zError("ioBLOB pointer is Nil"; Current method name:C684)
	OTr_zSetOK(0)
	
Else 
	
	OTr_zLock
	
	If (OTr_zIsValidHandle($inObject_i))
		$obj_o:=OB Copy:C1225(<>OTR_Objects_ao{$inObject_i})
		OTr_zUnlock
		
		VARIABLE TO BLOB:C532($obj_o; $serialised_blob)
		COMPRESS BLOB:C534($serialised_blob; GZIP best compression mode:K22:18)
		
		If ($doAppend_i=0)
			SET BLOB SIZE:C606($ioBLOB_ptr->; 0)
			COPY BLOB:C558($serialised_blob; $ioBLOB_ptr->; 0; 0; BLOB size:C605($serialised_blob))
		Else 
			COPY BLOB:C558($serialised_blob; $ioBLOB_ptr->; 0; BLOB size:C605($ioBLOB_ptr->); BLOB size:C605($serialised_blob))
		End if 
		
	Else 
		OTr_zError("Invalid inObject"; Current method name:C684)
		SET BLOB SIZE:C606($ioBLOB_ptr->; 0)
		OTr_zSetOK(0)
		OTr_zUnlock
		
	End if 
	
End if 

OTr_zRemoveFromCallStack(Current method name:C684)
