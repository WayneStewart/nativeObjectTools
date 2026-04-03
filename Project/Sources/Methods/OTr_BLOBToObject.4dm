//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: OTr_BLOBToObject (inBLOB {; ioOffset}) --> $handle_i : Integer

  // Deserialises an OTr object from a BLOB previously created by
  // OTr_ObjectToBLOB or OTr_ObjectToNewBLOB. Returns a new handle.
  // 
  // The optional *ioOffset* parameter is a Pointer to a Longint
  // variable. On entry, the pointed-to variable controls where in
  // the BLOB reading begins (0 = start of BLOB). On return, the
  // variable is updated to point immediately past the end of the
  // deserialised object, enabling sequential reading of a BLOB
  // built with the append mode of OTr_ObjectToBLOB.
  // 
  // Note: The OT plugin passed ioOffset as an Integer by reference.
  // In OTr, pass a Pointer to a Longint: OTr_BLOBToObject(b; ->$off).

  // **ORIGINAL DOCUMENTATION**
  // 
  // *OT BLOBToObject* deserialises an object from a BLOB and returns
  // a new object handle.
  // 
  // If *ioOffset* is not passed, reading begins at the start of the
  // BLOB.
  // 
  // If the bytes at the given offset do not describe an object stored
  // with *OTr_ObjectToBLOB* / *OTr_ObjectToNewBLOB*, an error is
  // generated, OK is set to zero, *ioOffset* is left untouched, and
  // a null handle (0) is returned.
  // 
  // **Warning:** The handle returned is a new object added to OTr's
  // internal list. Clear it with *OTr_Clear* when no longer needed.

  // Access: Shared

  // Parameters:
  //   $inBLOB_blob   : Blob    : A BLOB containing a serialised OTr object
  //   $ioOffset_ptr  : Pointer : Pointer to offset Longint (optional).
  //                              Read as start offset; updated to end offset.

  // Returns:
  //   $handle_i : Integer : New handle, or 0 on error

  // Created by Wayne Stewart, 2026-04-03
  // Based on work by himself, Rob Laveaux, and Cannon Smith.
  // ----------------------------------------------------

#DECLARE($inBLOB_blob : Blob; $ioOffset_ptr : Pointer)->$handle_i : Integer

var $readOffset_i : Integer
var $magicBlob_blob : Blob
var $magic_t : Text
var $varBlobLen_i : Integer
var $varBlobData_blob : Blob
var $expandedObj_o : Object
var $collapsedObj_o : Object

$handle_i := 0

//MARK:- Determine start offset
If ((Count parameters >= 2) & ($ioOffset_ptr # Null))
	$readOffset_i := $ioOffset_ptr->
Else
	$readOffset_i := 0
End if

//MARK:- Minimum size check (magic + length = 8 bytes)
If (BLOB SIZE($inBLOB_blob) < ($readOffset_i+8))
	OTr_zError("BLOB is too small to contain an OTr object"; Current method name)
	OTr_zSetOK(0)

Else

	//MARK:- Read and verify "OTR1" magic
	COPY BLOB($inBLOB_blob; $magicBlob_blob; $readOffset_i; 0; 4)
	$readOffset_i := $readOffset_i+4
	$magic_t := Convert to text($magicBlob_blob; "US-ASCII")

	If ($magic_t # "OTR1")
		OTr_zError("BLOB does not contain an OTr object (expected OTR1 magic)"; Current method name)
		OTr_zSetOK(0)

	Else

		//MARK:- Read varBlob length (BLOB to longint auto-advances $readOffset_i)
		$varBlobLen_i := BLOB to longint($inBLOB_blob; Native byte ordering; $readOffset_i)

		//MARK:- Extract the object BLOB
		SET BLOB SIZE($varBlobData_blob; $varBlobLen_i)
		COPY BLOB($inBLOB_blob; $varBlobData_blob; $readOffset_i; 0; $varBlobLen_i)
		$readOffset_i := $readOffset_i+$varBlobLen_i

		//MARK:- Deserialise to self-contained expanded object
		BLOB TO VARIABLE($varBlobData_blob; $expandedObj_o)

		//MARK:- Lock, collapse binary refs, allocate handle
		OTr_zLock

		$collapsedObj_o := OTr_uCollapseBinaries($expandedObj_o)

		$handle_i := Find in array(<>OTR_InUse_ab; False)
		If ($handle_i = -1)
			$handle_i := Size of array(<>OTR_InUse_ab)+1
			INSERT IN ARRAY(<>OTR_InUse_ab; $handle_i; 1)
			INSERT IN ARRAY(<>OTR_Objects_ao; $handle_i; 1)
		End if
		<>OTR_InUse_ab{$handle_i} := True
		<>OTR_Objects_ao{$handle_i} := $collapsedObj_o

		//MARK:- Update caller offset if provided
		If ((Count parameters >= 2) & ($ioOffset_ptr # Null))
			$ioOffset_ptr-> := $readOffset_i
		End if

		OTr_zSetOK(1)
		OTr_zUnlock

	End if

End if
