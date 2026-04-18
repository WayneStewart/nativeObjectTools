//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_x_OTBlobReadUTF16BE (inBlob; ioOffset; inCharCount; inDropNull) --> Text

// Reads UTF-16BE text from the source-defined ObjectTools v3 format.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob    : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr   : Pointer : Current read offset, advanced past text
//   $inCharCount_i  : Integer : Number of UTF-16 code units to read
//   $inDropNull_b   : Boolean : True to remove one trailing null character
//
// Returns:
//   $value_t : Text : Decoded text
//
// Created by Wayne Stewart / Codex, 2026-04-19
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer; $inCharCount_i : Integer; $inDropNull_b : Boolean)->$value_t : Text

OTr_z_AddToCallStack(Current method name:C684)

var $bytes_i : Integer
var $work_blob : Blob

$value_t:=""

If ($ioOffset_ptr#Null:C1517)
	If ($inCharCount_i>0)
		$bytes_i:=$inCharCount_i*2
		If (($ioOffset_ptr->+$bytes_i)<=BLOB size:C605($inBlob_blob))
			SET BLOB SIZE:C606($work_blob; $bytes_i)
			COPY BLOB:C558($inBlob_blob; $work_blob; $ioOffset_ptr->; 0; $bytes_i)
			$value_t:=Convert to text:C1012($work_blob; "UTF-16BE")
			$ioOffset_ptr->:=$ioOffset_ptr->+$bytes_i
			
			If ($inDropNull_b)
				If (Length:C16($value_t)>0)
					If (Character code:C91($value_t[[Length:C16($value_t)]])=0)
						$value_t:=Substring:C12($value_t; 1; Length:C16($value_t)-1)
					End if 
				End if 
			End if 
		End if 
	End if 
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
