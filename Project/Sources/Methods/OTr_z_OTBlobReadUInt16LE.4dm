//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadUInt16LE (inBlob; ioOffset) --> Integer

// Reads an unsigned 16-bit little-endian value from a legacy
// ObjectTools BLOB and advances ioOffset by 2 bytes.

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$value_i : Integer

$value_i:=0

If ($ioOffset_ptr#Null)
	If (($ioOffset_ptr->+1)<BLOB size($inBlob_blob))
		$value_i:=($inBlob_blob{$ioOffset_ptr->})+($inBlob_blob{$ioOffset_ptr->+1}*256)
		$ioOffset_ptr->:=$ioOffset_ptr->+2
	End if
End if
