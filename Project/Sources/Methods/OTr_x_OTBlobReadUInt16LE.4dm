//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_x_OTBlobReadUInt16LE (inBlob; ioOffset) --> Integer

// Reads an unsigned 16-bit little-endian value from a legacy
// ObjectTools BLOB and advances ioOffset by 2 bytes.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob  : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr : Pointer : Current read offset, advanced by 2 bytes
//
// Returns:
//   $value_i : Integer : Unsigned 16-bit little-endian value
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added little-endian UInt16 reader for OT payloads.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$value_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

$value_i:=0

If ($ioOffset_ptr#Null)
	If (($ioOffset_ptr->+1)<BLOB size($inBlob_blob))
		$value_i:=($inBlob_blob{$ioOffset_ptr->})+($inBlob_blob{$ioOffset_ptr->+1}*256)
		$ioOffset_ptr->:=$ioOffset_ptr->+2
	End if
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
