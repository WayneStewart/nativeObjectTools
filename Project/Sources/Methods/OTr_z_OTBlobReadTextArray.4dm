//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadTextArray (inBlob; inStart; ioOffset; inCount) --> Object

// Reads the character-array payload used by legacy ObjectTools BLOBs.
// The descriptor block length in observed OT 5 BLOBs lands either on
// the first Pascal UTF-16 string length word or on the first character;
// try the nearby aligned offsets and accept the first complete parse.

#DECLARE($inBlob_blob : Blob; $inStart_i : Integer; $ioOffset_ptr : Pointer; $inCount_i : Integer)->$array_o : Object

ARRAY LONGINT($delta_ai; 5)
$delta_ai{1}:=0
$delta_ai{2}:=-2
$delta_ai{3}:=2
$delta_ai{4}:=-4
$delta_ai{5}:=4

var $candidate_i; $deltaIndex_i; $index_i; $len_i : Integer
var $testOffset_i; $endOffset_i : Integer
var $ok_b : Boolean
var $value_t : Text

$array_o:=Null

For ($deltaIndex_i; 1; Size of array($delta_ai))
	If ($array_o=Null)
		$candidate_i:=$inStart_i+$delta_ai{$deltaIndex_i}
		If ($candidate_i>=0)
			$testOffset_i:=$candidate_i
			$ok_b:=True
			$array_o:=New object("arrayType"; Text array; "numElements"; $inCount_i; "currentItem"; 0; "0"; "")

			$index_i:=1
			While (($index_i<=$inCount_i) & ($ok_b))
				If (($testOffset_i+1)<BLOB size($inBlob_blob))
					$len_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$testOffset_i)
					If (($len_i<1) | (($testOffset_i+(($len_i*2)-1))>BLOB size($inBlob_blob)))
						$ok_b:=False
					Else
						$value_t:=OTr_z_OTBlobReadUTF16LE($inBlob_blob; ->$testOffset_i; $len_i; True)
						OB SET($array_o; String($index_i); $value_t)

						If (($testOffset_i+1)<BLOB size($inBlob_blob))
							If (($inBlob_blob{$testOffset_i}=0) & ($inBlob_blob{$testOffset_i+1}=0))
								$testOffset_i:=$testOffset_i+2
							End if
						End if
					End if
				Else
					$ok_b:=False
				End if
				$index_i:=$index_i+1
			End while

			If ($ok_b)
				$endOffset_i:=$testOffset_i
				$ioOffset_ptr->:=$endOffset_i
			Else
				$array_o:=Null
			End if
		End if
	End if
End for
