//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadTextArray (inBlob; inStart; ioOffset; inCount) --> Object

// Reads the character-array payload used by legacy ObjectTools BLOBs.
// The descriptor block length in observed OT 5 BLOBs lands either on
// the first Pascal UTF-16 string length word or on the first character;
// try the nearby aligned offsets and accept the first complete parse.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob   : Blob    : Legacy ObjectTools object BLOB
//   $inStart_i     : Integer : Candidate payload start offset
//   $ioOffset_ptr  : Pointer : Receives offset immediately after parsed payload
//   $inCount_i     : Integer : Number of text array elements to read
//
// Returns:
//   $array_o : Object : Native OTr array object, or Null on failure
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added OT character-array payload reader.
// Wayne Stewart / Codex, 2026-04-16 - Added descriptor-table reader for
//   large/sparse OT text arrays.
// Wayne Stewart / Codex, 2026-04-18 - Prefer descriptor-table parsing for
//   sparse multi-element text arrays with odd-byte descriptor alignment.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $inStart_i : Integer; $ioOffset_ptr : Pointer; $inCount_i : Integer)->$array_o : Object

OTr_z_AddToCallStack(Current method name:C684)

ARRAY LONGINT($delta_ai; 5)
$delta_ai{1}:=0
$delta_ai{2}:=-2
$delta_ai{3}:=2
$delta_ai{4}:=-4
$delta_ai{5}:=4

var $candidate_i; $deltaIndex_i; $index_i; $len_i : Integer
var $testOffset_i; $endOffset_i : Integer
var $scanStart_i; $scanEnd_i; $descriptorStart_i; $descriptorOffset_i : Integer
var $payloadOffset_i; $payloadLen_i; $nonEmpty_i : Integer
var $ok_b : Boolean
var $value_t : Text
ARRAY LONGINT($lengths_ai; 0)

$array_o:=Null

If ($inCount_i>0)
	$scanStart_i:=$inStart_i-($inCount_i*16)-2
	If ($scanStart_i<0)
		$scanStart_i:=0
	End if
	$scanEnd_i:=$scanStart_i
	
	If ($scanEnd_i>=$scanStart_i)
		For ($descriptorStart_i; $scanStart_i; $scanEnd_i)
			If ($array_o=Null)
				ARRAY LONGINT($lengths_ai; $inCount_i)
				$ok_b:=True
				$nonEmpty_i:=0
				
				For ($index_i; 1; $inCount_i)
					If ($ok_b)
						$descriptorOffset_i:=$descriptorStart_i+(($index_i-1)*16)
						If (($descriptorOffset_i+1)<BLOB size($inBlob_blob))
							$len_i:=$inBlob_blob{$descriptorOffset_i}+($inBlob_blob{$descriptorOffset_i+1}*256)
							If ($len_i>1024)
								$ok_b:=False
							Else
								$lengths_ai{$index_i}:=$len_i
								If ($len_i>0)
									$nonEmpty_i:=$nonEmpty_i+1
								End if
							End if
						Else
							$ok_b:=False
						End if
					End if
				End for
				
				$payloadOffset_i:=$descriptorStart_i+($inCount_i*16)
				If ($payloadOffset_i>=BLOB size($inBlob_blob))
					$ok_b:=False
				End if
				
				If ($ok_b)
					$testOffset_i:=$payloadOffset_i
					$array_o:=New object("arrayType"; Text array; "numElements"; $inCount_i; "currentItem"; 0; "0"; "")
					
					For ($index_i; 1; $inCount_i)
						If ($ok_b)
							$len_i:=$lengths_ai{$index_i}
							If ($len_i=0)
								OB SET($array_o; String($index_i); "")
							Else
								If (($testOffset_i+1)<BLOB size($inBlob_blob))
									$payloadLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$testOffset_i)
									If (($payloadLen_i#$len_i) & ($payloadLen_i#($len_i+1)))
										$ok_b:=False
									Else
										If (($testOffset_i+(($payloadLen_i*2)-1))>BLOB size($inBlob_blob))
											$ok_b:=False
										Else
											$value_t:=OTr_z_OTBlobReadUTF16LE($inBlob_blob; ->$testOffset_i; $payloadLen_i; True)
											OB SET($array_o; String($index_i); $value_t)
											
											If (($testOffset_i+1)<BLOB size($inBlob_blob))
												If (($inBlob_blob{$testOffset_i}=0) & ($inBlob_blob{$testOffset_i+1}=0))
													$testOffset_i:=$testOffset_i+2
												End if
											End if
										End if
									End if
								Else
									$ok_b:=False
								End if
							End if
						End if
					End for
					
					If ($ok_b)
						$ioOffset_ptr->:=$testOffset_i
					Else
						$array_o:=Null
					End if
				End if
			End if
		End for
	End if
End if

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

If ($array_o=Null)
	$scanStart_i:=$inStart_i-128
	If ($scanStart_i<0)
		$scanStart_i:=0
	End if
	If (($scanStart_i%2)#0)
		$scanStart_i:=$scanStart_i+1
	End if
	$scanEnd_i:=$inStart_i+128
	If ($scanEnd_i>(BLOB size($inBlob_blob)-($inCount_i*16)))
		$scanEnd_i:=BLOB size($inBlob_blob)-($inCount_i*16)
	End if
	
	If ($scanEnd_i>=$scanStart_i)
		For ($descriptorStart_i; $scanStart_i; $scanEnd_i)
			If ($array_o=Null)
				ARRAY LONGINT($lengths_ai; $inCount_i)
				$ok_b:=True
				$nonEmpty_i:=0
				
				For ($index_i; 1; $inCount_i)
					If ($ok_b)
						$descriptorOffset_i:=$descriptorStart_i+(($index_i-1)*16)
						If (($descriptorOffset_i+1)<BLOB size($inBlob_blob))
							$len_i:=$inBlob_blob{$descriptorOffset_i}+($inBlob_blob{$descriptorOffset_i+1}*256)
							If ($len_i>1024)
								$ok_b:=False
							Else
								$lengths_ai{$index_i}:=$len_i
								If ($len_i>0)
									$nonEmpty_i:=$nonEmpty_i+1
								End if
							End if
						Else
							$ok_b:=False
						End if
					End if
				End for
				
				$payloadOffset_i:=$descriptorStart_i+($inCount_i*16)
				If (($nonEmpty_i=0) | ($payloadOffset_i>=BLOB size($inBlob_blob)))
					$ok_b:=False
				End if
				
				If ($ok_b)
					$testOffset_i:=$payloadOffset_i
					$array_o:=New object("arrayType"; Text array; "numElements"; $inCount_i; "currentItem"; 0; "0"; "")
					
					For ($index_i; 1; $inCount_i)
						If ($ok_b)
							$len_i:=$lengths_ai{$index_i}
							If ($len_i=0)
								OB SET($array_o; String($index_i); "")
							Else
								If (($testOffset_i+1)<BLOB size($inBlob_blob))
									$payloadLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$testOffset_i)
									If (($payloadLen_i#$len_i) & ($payloadLen_i#($len_i+1)))
										$ok_b:=False
									Else
										If (($testOffset_i+(($payloadLen_i*2)-1))>BLOB size($inBlob_blob))
											$ok_b:=False
										Else
											$value_t:=OTr_z_OTBlobReadUTF16LE($inBlob_blob; ->$testOffset_i; $payloadLen_i; True)
											OB SET($array_o; String($index_i); $value_t)
											
											If (($testOffset_i+1)<BLOB size($inBlob_blob))
												If (($inBlob_blob{$testOffset_i}=0) & ($inBlob_blob{$testOffset_i+1}=0))
													$testOffset_i:=$testOffset_i+2
												End if
											End if
										End if
									End if
								Else
									$ok_b:=False
								End if
							End if
						End if
					End for
					
					If ($ok_b)
						$ioOffset_ptr->:=$testOffset_i
					Else
						$array_o:=Null
					End if
				End if
			End if
		End for
	End if
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
