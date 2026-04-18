//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_x_OTBlobReadUInt32BE (inBlob; ioOffset) --> Integer

// Reads an unsigned 32-bit big-endian value from a legacy ObjectTools
// BLOB and advances ioOffset by 4 bytes.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob  : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr : Pointer : Current read offset, advanced by 4 bytes
//
// Returns:
//   $value_i : Integer : Unsigned 32-bit big-endian value where representable
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added big-endian UInt32 reader for OT payloads.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$value_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

$value_i:=0

If ($ioOffset_ptr#Null)
	If (($ioOffset_ptr->+3)<BLOB size($inBlob_blob))
		$value_i:=($inBlob_blob{$ioOffset_ptr->}*16777216) \
			+($inBlob_blob{$ioOffset_ptr->+1}*65536) \
			+($inBlob_blob{$ioOffset_ptr->+2}*256) \
			+($inBlob_blob{$ioOffset_ptr->+3})
		$ioOffset_ptr->:=$ioOffset_ptr->+4
	End if
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
