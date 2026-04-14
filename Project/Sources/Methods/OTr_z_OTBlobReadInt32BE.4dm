//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadInt32BE (inBlob; ioOffset) --> Integer

// Reads a signed 32-bit big-endian value from a legacy ObjectTools
// BLOB and advances ioOffset by 4 bytes.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob  : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr : Pointer : Current read offset, advanced by 4 bytes
//
// Returns:
//   $value_i : Integer : Signed 32-bit big-endian integer value
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added signed reader for OT long payloads.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$value_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $b0_i; $b1_i; $b2_i; $b3_i : Integer

$value_i:=0

If ($ioOffset_ptr#Null)
	If (($ioOffset_ptr->+3)<BLOB size($inBlob_blob))
		$b0_i:=$inBlob_blob{$ioOffset_ptr->}
		$b1_i:=$inBlob_blob{$ioOffset_ptr->+1}
		$b2_i:=$inBlob_blob{$ioOffset_ptr->+2}
		$b3_i:=$inBlob_blob{$ioOffset_ptr->+3}
		
		If ($b0_i>=128)
			$value_i:=(($b0_i-256)*16777216)+($b1_i*65536)+($b2_i*256)+$b3_i
		Else
			$value_i:=($b0_i*16777216)+($b1_i*65536)+($b2_i*256)+$b3_i
		End if
		
		$ioOffset_ptr->:=$ioOffset_ptr->+4
	End if
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
