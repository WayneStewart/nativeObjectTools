//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OT x_OTBlobReadSerializedText (inBlob; ioOffset; inDropNull) --> Text

// Reads the source-defined serialized Unicode string:
// UInt32BE UTF-16 code-unit count, followed by UTF-16BE code units.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob  : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr : Pointer : Current read offset, advanced past string
//   $inDropNull_b : Boolean : True to remove one trailing null character
//
// Returns:
//   $value_t : Text : Decoded text
//
// Created by Wayne Stewart / Codex, 2026-04-19
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer; $inDropNull_b : Boolean)->$value_t : Text

OTr_z_AddToCallStack(Current method name:C684)

var $charCount_i : Integer

$value_t:=""

If ($ioOffset_ptr#Null:C1517)
	If (($ioOffset_ptr->+4)<=BLOB size:C605($inBlob_blob))
		$charCount_i:=OT x_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
		If ($charCount_i=0)
			$value_t:=""
		Else 
			$value_t:=OT x_OTBlobReadUTF16BE($inBlob_blob; $ioOffset_ptr; $charCount_i; $inDropNull_b)
		End if 
	End if 
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
