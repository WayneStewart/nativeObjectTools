//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadUTF16LE (inBlob; ioOffset; inCharCount; inDropNull) --> Text

// Reads UTF-16LE text from a legacy ObjectTools BLOB and advances
// ioOffset by inCharCount UTF-16 code units.

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer; $inCharCount_i : Integer; $inDropNull_b : Boolean)->$value_t : Text

var $bytes_i : Integer
var $storedBytes_i : Integer
var $work_blob : Blob

$value_t:=""
$bytes_i:=$inCharCount_i*2
$storedBytes_i:=$bytes_i

If ($ioOffset_ptr#Null)
	If ($inCharCount_i=0)
		$value_t:=""
	Else
		If ($inCharCount_i>0)
			If (($ioOffset_ptr->+$storedBytes_i)>BLOB size($inBlob_blob))
				If (($ioOffset_ptr->+$bytes_i-1)<=BLOB size($inBlob_blob))
					$storedBytes_i:=$bytes_i-1
				End if
			End if

			If (($ioOffset_ptr->+$storedBytes_i)<=BLOB size($inBlob_blob))
				SET BLOB SIZE($work_blob; $bytes_i)
				COPY BLOB($inBlob_blob; $work_blob; $ioOffset_ptr->; 0; $storedBytes_i)
				$value_t:=Convert to text($work_blob; "UTF-16LE")
				$ioOffset_ptr->:=$ioOffset_ptr->+$storedBytes_i

				If ($inDropNull_b)
					If (Length($value_t)>0)
						If (Character code($value_t[[Length($value_t)]])=0)
							$value_t:=Substring($value_t; 1; Length($value_t)-1)
						End if
					End if
				End if
			End if
		End if
	End if
End if
