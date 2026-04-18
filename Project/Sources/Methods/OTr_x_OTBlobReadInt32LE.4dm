//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_x_OTBlobReadInt32LE (inBlob; ioOffset) --> Integer

// Reads a signed 32-bit integer stored little-endian in a legacy
// ObjectTools BLOB and advances ioOffset by 4 bytes.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob  : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr : Pointer : Current read offset, advanced by 4 bytes
//
// Returns:
//   $value_i : Integer : Decoded signed 32-bit integer
//
// Created by Wayne Stewart / Codex, 2026-04-16
// Wayne Stewart / Codex, 2026-04-16 - Added little-endian record integer reader.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$value_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $raw_r : Real

$value_i:=0

If ($ioOffset_ptr#Null)
	If (($ioOffset_ptr->+3)<BLOB size($inBlob_blob))
		$raw_r:=$inBlob_blob{$ioOffset_ptr->}+($inBlob_blob{$ioOffset_ptr->+1}*256)+($inBlob_blob{$ioOffset_ptr->+2}*65536)+($inBlob_blob{$ioOffset_ptr->+3}*16777216)
		If ($raw_r>=2147483648)
			$value_i:=$raw_r-4294967296
		Else
			$value_i:=$raw_r
		End if
		$ioOffset_ptr->:=$ioOffset_ptr->+4
	End if
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
