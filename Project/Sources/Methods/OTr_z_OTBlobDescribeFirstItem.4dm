//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobDescribeFirstItem (inBlob) --> Text

// Returns compact marker diagnostics for a legacy ObjectTools object
// BLOB. Phase 16 uses this while payload layouts are still being
// mapped. The scanner knows how to skip proven scalar/text-array
// payloads, including the compact ASCII-key Guy samples, and stops at the
// first unsupported top-level marker.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob : Blob : Legacy ObjectTools object BLOB
//
// Returns:
//   $description_t : Text : Compact marker and offset diagnostic text
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added Phase 16 OT BLOB marker diagnostics.
// Wayne Stewart / Codex, 2026-04-15 - Added compact marker 2/18 diagnostics.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob)->$description_t : Text

OTr_z_AddToCallStack(Current method name:C684)

var $offset_i; $itemCount_i; $rootType_i; $keyLen_i; $typeByte_i : Integer
var $item_i; $textLen_i; $count_i; $descriptorBytes_i; $arrayStart_i : Integer
var $index_i; $descriptorStart_i; $payloadOffset_i; $elementLen_i : Integer
var $key_t : Text
var $array_o : Object
var $picture_pic : Picture
var $blob_blob : Blob
var $scan_b; $compact_b : Boolean

$description_t:="Not a legacy OT object BLOB"

If (OTr_z_OTBlobIsObject($inBlob_blob))
	$offset_i:=14
	$compact_b:=($inBlob_blob{14}=7) & ($inBlob_blob{15}=1)
	OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
	$rootType_i:=OTr_z_OTBlobReadUInt32LE($inBlob_blob; ->$offset_i)
	$itemCount_i:=OTr_z_OTBlobReadUInt32LE($inBlob_blob; ->$offset_i)
	$description_t:="rootType="+String:C10($rootType_i)+"; itemCount="+String:C10($itemCount_i)
	
	If ($itemCount_i>0)
		$description_t:=$description_t+"; markers="
		$item_i:=1
		$scan_b:=True
		
		While (($item_i<=$itemCount_i) & ($scan_b))
			If ($item_i>1)
				$description_t:=$description_t+", "
			End if
			
			If (($offset_i+2)<=BLOB size:C605($inBlob_blob))
				If ($compact_b)
					$keyLen_i:=$inBlob_blob{$offset_i}
					$offset_i:=$offset_i+1
				Else
					$keyLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
				End if
				If ($keyLen_i>0)
					If ($compact_b)
						$key_t:=""
						If (($offset_i+$keyLen_i)<=BLOB size:C605($inBlob_blob))
							For ($index_i; 1; $keyLen_i)
								$key_t:=$key_t+Char:C90($inBlob_blob{$offset_i})
								$offset_i:=$offset_i+1
							End for
						End if
					Else
						$key_t:=OTr_z_OTBlobReadKey($inBlob_blob; ->$offset_i; $keyLen_i)
					End if
					If ($key_t#"")
						If ($offset_i<BLOB size:C605($inBlob_blob))
							$typeByte_i:=$inBlob_blob{$offset_i}
							$description_t:=$description_t+$key_t+"="+String:C10($typeByte_i)+"@"+String:C10($offset_i)
							$offset_i:=$offset_i+1
							
							Case of
								: (($compact_b) & ($typeByte_i=2))
									$offset_i:=$offset_i+2
									If ($offset_i<BLOB size:C605($inBlob_blob))
										$textLen_i:=$inBlob_blob{$offset_i}
										$offset_i:=$offset_i+1+$textLen_i
									Else
										$description_t:=$description_t+" payload=<unreadable-text>"
										$scan_b:=False
									End if
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while
									End if
									
								: (($compact_b) & ($typeByte_i=18))
									$offset_i:=$offset_i+4
									If ($offset_i<BLOB size:C605($inBlob_blob))
										$count_i:=$inBlob_blob{$offset_i}
										$offset_i:=$offset_i+1
										$descriptorStart_i:=$offset_i+17
										$payloadOffset_i:=$descriptorStart_i+($count_i*6)-1
										For ($index_i; 1; $count_i)
											If (($descriptorStart_i+(($index_i-1)*6))<BLOB size:C605($inBlob_blob))
												$elementLen_i:=$inBlob_blob{$descriptorStart_i+(($index_i-1)*6)}
												$payloadOffset_i:=$payloadOffset_i+$elementLen_i
											Else
												$description_t:=$description_t+" payload=<unreadable-array>"
												$scan_b:=False
											End if
										End for
										$offset_i:=$payloadOffset_i
										If ($item_i<$itemCount_i)
											While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
												$offset_i:=$offset_i+1
											End while
										End if
									Else
										$description_t:=$description_t+" payload=<unreadable-array>"
										$scan_b:=False
									End if
									
								: ($typeByte_i=161)
									$offset_i:=$offset_i+4
									$textLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+($textLen_i*2)
									If ($item_i<$itemCount_i)
										If (($offset_i+1)<BLOB size:C605($inBlob_blob))
											If (($inBlob_blob{$offset_i}=0) & ($inBlob_blob{$offset_i+1}=0))
												$offset_i:=$offset_i+2
											End if
										End if
									End if
									
								: ($typeByte_i=132)
									$offset_i:=$offset_i+10
									
								: ($typeByte_i=129)
									$offset_i:=$offset_i+9
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while
									End if
									
								: (($typeByte_i=137) | ($typeByte_i=139))
									$offset_i:=$offset_i+5
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while
									End if
									
								: ($typeByte_i=134)
									$offset_i:=$offset_i+2
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while
									End if
									
								: ($typeByte_i=158)
									If (OTr_z_OTBlobReadBlobPayload($inBlob_blob; ->$offset_i; ->$blob_blob))
										If ($item_i<$itemCount_i)
											While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
												$offset_i:=$offset_i+1
											End while
										End if
									Else
										$description_t:=$description_t+" payload=<unreadable-blob>"
										$scan_b:=False
									End if
									
								: ($typeByte_i=138)
									If (OTr_z_OTBlobReadWrappedPicture($inBlob_blob; $offset_i; ->$offset_i; ->$picture_pic))
										If ($item_i<$itemCount_i)
											While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
												$offset_i:=$offset_i+1
											End while
										End if
									Else
										$description_t:=$description_t+" payload=<unreadable-picture>"
										$scan_b:=False
									End if
									
								: ($typeByte_i=162)
									$offset_i:=$offset_i+4
									$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+8
									$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+4
									$arrayStart_i:=$offset_i+$descriptorBytes_i
									$array_o:=OTr_z_OTBlobReadTextArray($inBlob_blob; $arrayStart_i; ->$offset_i; $count_i)
									If ($array_o=Null)
										$description_t:=$description_t+" payload=<unreadable>"
										$scan_b:=False
									End if
									
								: (($typeByte_i=144) | ($typeByte_i=160))
									$offset_i:=$offset_i+4
									$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+8
									$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+4
									$offset_i:=($offset_i-1)+($count_i*4)
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while
									End if
									
								: ($typeByte_i=142)
									$offset_i:=$offset_i+4
									$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+8
									$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+4
									$offset_i:=($offset_i+3)+($count_i*8)
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while
									End if
									
								: ($typeByte_i=145)
									$offset_i:=$offset_i+4
									$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+8
									$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+4
									$offset_i:=($offset_i+2)+($count_i*5)+($count_i-1)
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while
									End if
									
								: ($typeByte_i=150)
									$offset_i:=$offset_i+4
									$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+9+((($count_i+1)+7)\8)
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while
									End if
									
								: ($typeByte_i=114)
									$count_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
									$offset_i:=$offset_i+3
									$array_o:=OTr_z_OTBlobReadObjectItems($inBlob_blob; ->$offset_i; $count_i)
									If ($array_o=Null)
										$description_t:=$description_t+" payload=<unreadable>"
										$scan_b:=False
									End if
									
								Else
									$description_t:=$description_t+" unsupported"
									$scan_b:=False
							End case
						Else
							$description_t:=$description_t+$key_t+"=<truncated>"
							$scan_b:=False
						End if
					Else
						$description_t:=$description_t+"<unreadable-key length="+String:C10($keyLen_i)+">"
						$scan_b:=False
					End if
				Else
					$description_t:=$description_t+"<invalid-key-length "+String:C10($keyLen_i)+">"
					$scan_b:=False
				End if
			Else
				$description_t:=$description_t+"<truncated-item>"
				$scan_b:=False
			End if
			
			$item_i:=$item_i+1
		End while
		
		// Preserve the original first-item fields for reports already
		// keyed on firstKey/firstMarker.
		$offset_i:=24
		If (($offset_i+2)<=BLOB size:C605($inBlob_blob))
			If ($compact_b)
				$keyLen_i:=$inBlob_blob{$offset_i}
				$offset_i:=$offset_i+1
			Else
				$keyLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
			End if
			If ($keyLen_i>0)
				If ($compact_b)
					$key_t:=""
					If (($offset_i+$keyLen_i)<=BLOB size:C605($inBlob_blob))
						For ($index_i; 1; $keyLen_i)
							$key_t:=$key_t+Char:C90($inBlob_blob{$offset_i})
							$offset_i:=$offset_i+1
						End for
					End if
				Else
					$key_t:=OTr_z_OTBlobReadKey($inBlob_blob; ->$offset_i; $keyLen_i)
				End if
				If ($key_t#"")
					If ($offset_i<BLOB size:C605($inBlob_blob))
						$typeByte_i:=$inBlob_blob{$offset_i}
						$description_t:=$description_t+"; firstKey="+$key_t+"; firstMarker="+String:C10($typeByte_i)+"; markerOffset="+String:C10($offset_i)
					Else
						$description_t:=$description_t+"; firstKey="+$key_t+"; firstMarker=<truncated>"
					End if
				Else
					$description_t:=$description_t+"; firstKey=<unreadable>; keyLength="+String:C10($keyLen_i)
				End if
			Else
				$description_t:=$description_t+"; firstKeyLength="+String:C10($keyLen_i)
			End if
		Else
			$description_t:=$description_t+"; firstItem=<truncated>"
		End if
	End if
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
