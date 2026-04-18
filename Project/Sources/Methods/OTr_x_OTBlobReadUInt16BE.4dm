//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_x_OTBlobReadUInt16BE (inBlob; ioOffset) --> Integer

// Reads an unsigned 16-bit big-endian value from an ObjectTools BLOB.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob  : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr : Pointer : Current read offset, advanced by 2 bytes
//
// Returns:
//   $value_i : Integer : Unsigned 16-bit value
//
// Created by Wayne Stewart / Codex, 2026-04-19
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$value_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

$value_i:=0

If ($ioOffset_ptr#Null:C1517)
	If (($ioOffset_ptr->+1)<BLOB size:C605($inBlob_blob))
		$value_i:=($inBlob_blob{$ioOffset_ptr->}*256)+$inBlob_blob{$ioOffset_ptr->+1}
		$ioOffset_ptr->:=$ioOffset_ptr->+2
	End if 
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
