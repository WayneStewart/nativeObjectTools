//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_x_OTBlobReadInt16BE (inBlob; ioOffset) --> Integer

// Reads a signed 16-bit big-endian value from an ObjectTools BLOB.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob  : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr : Pointer : Current read offset, advanced by 2 bytes
//
// Returns:
//   $value_i : Integer : Signed 16-bit value
//
// Created by Wayne Stewart / Codex, 2026-04-19
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$value_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

$value_i:=OTr_x_OTBlobReadUInt16BE($inBlob_blob; $ioOffset_ptr)
If ($value_i>=32768)
	$value_i:=$value_i-65536
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
