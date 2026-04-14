//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadUInt32BE (inBlob; ioOffset) --> Integer

// Reads an unsigned 32-bit big-endian value from a legacy ObjectTools
// BLOB and advances ioOffset by 4 bytes.

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$value_i : Integer

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
