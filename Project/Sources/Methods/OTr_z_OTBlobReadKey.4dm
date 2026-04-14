//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadKey (inBlob; ioOffset; inCharCount) --> Text

// Reads an ObjectTools item key. OT stores key names as UTF-16LE but
// omits the final zero high byte, so an 8-character key occupies
// 15 bytes, followed immediately by the item type byte.

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer; $inCharCount_i : Integer)->$key_t : Text

var $storedBytes_i; $fullBytes_i : Integer
var $work_blob : Blob

$key_t:=""
$storedBytes_i:=($inCharCount_i*2)-1
$fullBytes_i:=$inCharCount_i*2

If ($ioOffset_ptr#Null)
	If ($inCharCount_i>0)
		If (($ioOffset_ptr->+$storedBytes_i)<=BLOB size($inBlob_blob))
			SET BLOB SIZE($work_blob; $fullBytes_i)
			COPY BLOB($inBlob_blob; $work_blob; $ioOffset_ptr->; 0; $storedBytes_i)
			$key_t:=Convert to text($work_blob; "UTF-16LE")
			$ioOffset_ptr->:=$ioOffset_ptr->+$storedBytes_i
		End if
	End if
End if
