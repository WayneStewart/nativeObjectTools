//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobToObject (inBlob) --> Object

// Converts a legacy ObjectTools object BLOB into the native OTr object
// storage shape.
//
// Supports the Phase 16 proven legacy OT payload markers for text, date,
// longint, real, boolean, time, BLOB, PNG/JPEG picture, text array,
// longint array, real array, boolean array, date array, time array,
// records, and embedded objects. Also supports the compact Guy sample
// layout with ASCII keys, marker 2 text, and marker 18 text arrays.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob : Blob : Legacy ObjectTools object BLOB
//
// Returns:
//   $result_o : Object : Native OTr object storage shape, or Null on failure
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Phase 16 legacy ObjectTools BLOB importer.
// Wayne Stewart / Codex, 2026-04-15 - Added compact ASCII-key legacy layout
//   used by Guy Examples 2 and 3.
// Wayne Stewart / Codex, 2026-04-16 - Added OT packed record marker 115.
// Wayne Stewart / Codex, 2026-04-18 - Added descriptor-aligned array payloads
//   and OT marker 143 16-bit integer arrays used by Guy EX6 SubRec.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob)->$result_o : Object

OTr_z_AddToCallStack(Current method name:C684)

var $offset_i; $itemCount_i; $item_i; $rootType_i : Integer
var $keyLen_i; $typeByte_i; $textLen_i : Integer
var $count_i; $descriptorBytes_i; $arrayStart_i : Integer
var $index_i; $payloadStart_i; $childCount_i : Integer
var $descriptorStart_i; $payloadOffset_i; $elementLen_i : Integer
var $factor_i; $bit_i : Integer
var $day_i; $month_i; $year_i : Integer
var $long_i; $timeSeconds_i : Integer
var $hour_i; $minute_i; $second_i : Integer
var $key_t; $value_t; $yyyy_t; $mm_t; $dd_t : Text
var $hh_t; $mn_t; $ss_t : Text
var $real_r : Real
var $array_o; $child_o; $record_o : Object
var $blob_blob : Blob
var $picture_pic : Picture
var $ok_b; $compact_b : Boolean

$result_o:=Null:C1517
$ok_b:=False:C215

If (OTr_z_OTBlobIsObject($inBlob_blob))
	$offset_i:=14
	$compact_b:=($inBlob_blob{14}=7) & ($inBlob_blob{15}=1)
	OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
	$rootType_i:=OTr_z_OTBlobReadUInt32LE($inBlob_blob; ->$offset_i)
	$itemCount_i:=OTr_z_OTBlobReadUInt32LE($inBlob_blob; ->$offset_i)
	
	If (($rootType_i=OT Is Object) & ($itemCount_i>=0))
		$result_o:=New object:C1471
		$ok_b:=True:C214
		$item_i:=1
		
		While (($item_i<=$itemCount_i) & ($ok_b))
			If (($offset_i+2)>BLOB size:C605($inBlob_blob))
				$ok_b:=False:C215
			Else 
				If ($compact_b)
					$keyLen_i:=$inBlob_blob{$offset_i}
					$offset_i:=$offset_i+1
					$key_t:=""
					If (($keyLen_i<=0) | (($offset_i+$keyLen_i)>BLOB size:C605($inBlob_blob)))
						$ok_b:=False:C215
					Else 
						For ($index_i; 1; $keyLen_i)
							$key_t:=$key_t+Char:C90($inBlob_blob{$offset_i})
							$offset_i:=$offset_i+1
						End for 
					End if 
				Else 
					$keyLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
					If (($keyLen_i<=0) | (($offset_i+(($keyLen_i*2)-1))>=BLOB size:C605($inBlob_blob)))
						$ok_b:=False:C215
					Else 
						$key_t:=OTr_z_OTBlobReadKey($inBlob_blob; ->$offset_i; $keyLen_i)
					End if 
				End if 
				If ($ok_b)
					$typeByte_i:=$inBlob_blob{$offset_i}
					$offset_i:=$offset_i+1
					
					Case of 
						: (($compact_b) & ($typeByte_i=2))
							If (($offset_i+2)<BLOB size:C605($inBlob_blob))
								$offset_i:=$offset_i+2
								$textLen_i:=$inBlob_blob{$offset_i}
								$offset_i:=$offset_i+1
								If (($offset_i+$textLen_i)<=BLOB size:C605($inBlob_blob))
									$value_t:=""
									For ($index_i; 1; $textLen_i)
										$value_t:=$value_t+Char:C90($inBlob_blob{$offset_i})
										$offset_i:=$offset_i+1
									End for 
									OB SET:C1220($result_o; $key_t; $value_t)
									OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); OT Is Character)
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while 
									End if 
								Else 
									$ok_b:=False:C215
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: (($compact_b) & ($typeByte_i=18))
							If (($offset_i+5)<BLOB size:C605($inBlob_blob))
								$offset_i:=$offset_i+4
								$count_i:=$inBlob_blob{$offset_i}
								$offset_i:=$offset_i+1
								$descriptorStart_i:=$offset_i+17
								$payloadStart_i:=$descriptorStart_i+($count_i*6)-1
								$payloadOffset_i:=$payloadStart_i
								If (($descriptorStart_i>=0) & ($payloadStart_i<=BLOB size:C605($inBlob_blob)))
									$array_o:=New object:C1471("arrayType"; Text array:K8:16; "numElements"; $count_i; "currentItem"; 0; "0"; "")
									For ($index_i; 1; $count_i)
										If (($descriptorStart_i+((($index_i-1)*6)))<BLOB size:C605($inBlob_blob))
											$elementLen_i:=$inBlob_blob{$descriptorStart_i+(($index_i-1)*6)}
											If (($payloadOffset_i+$elementLen_i)<=BLOB size:C605($inBlob_blob))
												$value_t:=""
												While ($elementLen_i>0)
													$value_t:=$value_t+Char:C90($inBlob_blob{$payloadOffset_i})
													$payloadOffset_i:=$payloadOffset_i+1
													$elementLen_i:=$elementLen_i-1
												End while 
												OB SET:C1220($array_o; String:C10($index_i); $value_t)
											Else 
												$ok_b:=False:C215
											End if 
										Else 
											$ok_b:=False:C215
										End if 
									End for 
									If ($ok_b)
										$offset_i:=$payloadOffset_i
										OB SET:C1220($result_o; $key_t; $array_o)
										If ($item_i<$itemCount_i)
											While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
												$offset_i:=$offset_i+1
											End while 
										End if 
									End if 
								Else 
									$ok_b:=False:C215
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=161)
							$offset_i:=$offset_i+4
							$textLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$value_t:=OTr_z_OTBlobReadUTF16LE($inBlob_blob; ->$offset_i; $textLen_i; True:C214)
							OB SET:C1220($result_o; $key_t; $value_t)
							OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); OT Is Character)
							
							If ($item_i<$itemCount_i)
								If (($offset_i+1)<BLOB size:C605($inBlob_blob))
									If (($inBlob_blob{$offset_i}=0) & ($inBlob_blob{$offset_i+1}=0))
										$offset_i:=$offset_i+2
									End if 
								End if 
							End if 
							
						: ($typeByte_i=132)
							$offset_i:=$offset_i+2
							$day_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$month_i:=$inBlob_blob{$offset_i}
							$offset_i:=$offset_i+1
							$year_i:=($inBlob_blob{$offset_i}*256)+$inBlob_blob{$offset_i+1}
							$offset_i:=$offset_i+5
							
							$yyyy_t:=String:C10($year_i)
							While (Length:C16($yyyy_t)<4)
								$yyyy_t:="0"+$yyyy_t
							End while 
							$mm_t:=String:C10($month_i)
							If (Length:C16($mm_t)<2)
								$mm_t:="0"+$mm_t
							End if 
							$dd_t:=String:C10($day_i)
							If (Length:C16($dd_t)<2)
								$dd_t:="0"+$dd_t
							End if 
							
							OB SET:C1220($result_o; $key_t; $yyyy_t+"-"+$mm_t+"-"+$dd_t)
							OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is date:K8:7)
							
						: ($typeByte_i=129)
							If (($offset_i+8)<BLOB size:C605($inBlob_blob))
								$offset_i:=$offset_i+1
								$real_r:=OTr_z_OTBlobReadRealBE($inBlob_blob; ->$offset_i)
								OB SET:C1220($result_o; $key_t; $real_r)
								OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is real:K8:4)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=137)
							If (($offset_i+4)<BLOB size:C605($inBlob_blob))
								$offset_i:=$offset_i+1
								$long_i:=OTr_z_OTBlobReadInt32BE($inBlob_blob; ->$offset_i)
								OB SET:C1220($result_o; $key_t; $long_i)
								OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is longint:K8:6)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=134)
							If (($offset_i+1)<BLOB size:C605($inBlob_blob))
								$offset_i:=$offset_i+1
								OB SET:C1220($result_o; $key_t; ($inBlob_blob{$offset_i}#0))
								OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is boolean:K8:9)
								$offset_i:=$offset_i+1
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=139)
							If (($offset_i+4)<BLOB size:C605($inBlob_blob))
								$offset_i:=$offset_i+1
								$timeSeconds_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
								$hour_i:=$timeSeconds_i\3600
								$minute_i:=($timeSeconds_i%3600)\60
								$second_i:=$timeSeconds_i%60
								$hh_t:=String:C10($hour_i)
								If (Length:C16($hh_t)<2)
									$hh_t:="0"+$hh_t
								End if 
								$mn_t:=String:C10($minute_i)
								If (Length:C16($mn_t)<2)
									$mn_t:="0"+$mn_t
								End if 
								$ss_t:=String:C10($second_i)
								If (Length:C16($ss_t)<2)
									$ss_t:="0"+$ss_t
								End if 
								OB SET:C1220($result_o; $key_t; $hh_t+":"+$mn_t+":"+$ss_t)
								OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is time:K8:8)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=158)
							If (OTr_z_OTBlobReadBlobPayload($inBlob_blob; ->$offset_i; ->$blob_blob))
								If (Storage:C1525.OTr.nativeBlobInObject)
									OB SET:C1220($result_o; $key_t; $blob_blob)
								Else 
									OB SET:C1220($result_o; $key_t; OTr_u_BlobToText($blob_blob))
								End if 
								OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is BLOB:K8:12)
								OTr_z_SetOK(1)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=115)
							$record_o:=OTr_z_OTBlobReadRecord($inBlob_blob; ->$offset_i)
							If ($record_o=Null:C1517)
								$ok_b:=False:C215
							Else 
								OB SET:C1220($result_o; $key_t; $record_o)
								OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); OT Is Record)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							End if 
							
						: ($typeByte_i=138)
							If (OTr_z_OTBlobReadWrappedPicture($inBlob_blob; $offset_i; ->$offset_i; ->$picture_pic))
								OB SET:C1220($result_o; $key_t; $picture_pic)
								OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is picture:K8:10)
								OTr_z_SetOK(1)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=162)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							If ($count_i=0)
								$array_o:=New object:C1471("arrayType"; Text array:K8:16; "numElements"; 0; "currentItem"; 0; "0"; "")
								$offset_i:=$offset_i+$descriptorBytes_i-2
							Else 
								$arrayStart_i:=$offset_i+$descriptorBytes_i
								$array_o:=OTr_z_OTBlobReadTextArray($inBlob_blob; $arrayStart_i; ->$offset_i; $count_i)
							End if 
							
							If ($array_o=Null:C1517)
								$ok_b:=False:C215
							Else 
								OB SET:C1220($result_o; $key_t; $array_o)
							End if 
							
						: ($typeByte_i=144)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							$payloadStart_i:=$offset_i+$descriptorBytes_i-($count_i*4)-5
							If (($payloadStart_i<0) | (($payloadStart_i+($count_i*4))>BLOB size:C605($inBlob_blob)))
								$payloadStart_i:=$offset_i-1
							End if 
							If (($payloadStart_i>=0) & (($payloadStart_i+($count_i*4))<=BLOB size:C605($inBlob_blob)))
								$array_o:=New object:C1471("arrayType"; LongInt array:K8:19; "numElements"; $count_i; "currentItem"; 0; "0"; 0)
								$offset_i:=$payloadStart_i
								For ($index_i; 1; $count_i)
									$long_i:=OTr_z_OTBlobReadInt32BE($inBlob_blob; ->$offset_i)
									OB SET:C1220($array_o; String:C10($index_i); $long_i)
								End for 
								OB SET:C1220($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=143)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							$payloadStart_i:=$offset_i+$descriptorBytes_i-($count_i*2)-2
							If (($payloadStart_i<0) | (($payloadStart_i+($count_i*2))>BLOB size:C605($inBlob_blob)))
								$payloadStart_i:=$offset_i
							End if 
							If (($payloadStart_i>=0) & (($payloadStart_i+($count_i*2))<=BLOB size:C605($inBlob_blob)))
								$array_o:=New object:C1471("arrayType"; LongInt array:K8:19; "numElements"; $count_i; "currentItem"; 0; "0"; 0)
								$offset_i:=$payloadStart_i
								For ($index_i; 1; $count_i)
									$long_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									OB SET:C1220($array_o; String:C10($index_i); $long_i)
								End for 
								OB SET:C1220($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=142)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							$payloadStart_i:=$offset_i+$descriptorBytes_i-($count_i*8)-3
							If (($payloadStart_i<0) | (($payloadStart_i+($count_i*8))>BLOB size:C605($inBlob_blob)))
								$payloadStart_i:=$offset_i+3
							End if 
							If (($payloadStart_i>=0) & (($payloadStart_i+($count_i*8))<=BLOB size:C605($inBlob_blob)))
								$array_o:=New object:C1471("arrayType"; Real array:K8:17; "numElements"; $count_i; "currentItem"; 0; "0"; 0)
								$offset_i:=$payloadStart_i
								For ($index_i; 1; $count_i)
									$real_r:=OTr_z_OTBlobReadRealBE($inBlob_blob; ->$offset_i)
									OB SET:C1220($array_o; String:C10($index_i); $real_r)
								End for 
								OB SET:C1220($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=145)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							$payloadStart_i:=$offset_i+2
							If (($payloadStart_i>=0) & (($payloadStart_i+($count_i*5)+($count_i-1))<=BLOB size:C605($inBlob_blob)))
								$array_o:=New object:C1471("arrayType"; Date array:K8:20; "numElements"; $count_i; "currentItem"; 0; "0"; "0000-00-00")
								$offset_i:=$payloadStart_i
								For ($index_i; 1; $count_i)
									$day_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
									$month_i:=$inBlob_blob{$offset_i}
									$offset_i:=$offset_i+1
									$year_i:=($inBlob_blob{$offset_i}*256)+$inBlob_blob{$offset_i+1}
									$offset_i:=$offset_i+2
									If ($index_i<$count_i)
										$offset_i:=$offset_i+1
									End if 
									$yyyy_t:=String:C10($year_i)
									While (Length:C16($yyyy_t)<4)
										$yyyy_t:="0"+$yyyy_t
									End while 
									$mm_t:=String:C10($month_i)
									If (Length:C16($mm_t)<2)
										$mm_t:="0"+$mm_t
									End if 
									$dd_t:=String:C10($day_i)
									If (Length:C16($dd_t)<2)
										$dd_t:="0"+$dd_t
									End if 
									OB SET:C1220($array_o; String:C10($index_i); $yyyy_t+"-"+$mm_t+"-"+$dd_t)
								End for 
								OB SET:C1220($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=160)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							$payloadStart_i:=$offset_i-1
							If (($payloadStart_i>=0) & (($payloadStart_i+($count_i*4))<=BLOB size:C605($inBlob_blob)))
								$array_o:=New object:C1471("arrayType"; Time array:K8:29; "numElements"; $count_i; "currentItem"; 0; "0"; "00:00:00")
								$offset_i:=$payloadStart_i
								For ($index_i; 1; $count_i)
									$timeSeconds_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
									$hour_i:=$timeSeconds_i\3600
									$minute_i:=($timeSeconds_i%3600)\60
									$second_i:=$timeSeconds_i%60
									$hh_t:=String:C10($hour_i)
									If (Length:C16($hh_t)<2)
										$hh_t:="0"+$hh_t
									End if 
									$mn_t:=String:C10($minute_i)
									If (Length:C16($mn_t)<2)
										$mn_t:="0"+$mn_t
									End if 
									$ss_t:=String:C10($second_i)
									If (Length:C16($ss_t)<2)
										$ss_t:="0"+$ss_t
									End if 
									OB SET:C1220($array_o; String:C10($index_i); $hh_t+":"+$mn_t+":"+$ss_t)
								End for 
								OB SET:C1220($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=150)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$array_o:=New object:C1471("arrayType"; Boolean array:K8:21; "numElements"; $count_i; "currentItem"; 0; "0"; False:C215)
							$offset_i:=$offset_i+1
							If ($offset_i<BLOB size:C605($inBlob_blob))
								For ($index_i; 1; $count_i)
									$factor_i:=1
									For ($bit_i; 1; $index_i)
										$factor_i:=$factor_i*2
									End for 
									OB SET:C1220($array_o; String:C10($index_i); ((($inBlob_blob{$offset_i}\$factor_i)%2)#0))
								End for 
								$offset_i:=$offset_i+1
								OB SET:C1220($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						: ($typeByte_i=114)
							If (($offset_i+6)<BLOB size:C605($inBlob_blob))
								$childCount_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
								$offset_i:=$offset_i+3
								$child_o:=OTr_z_OTBlobReadObjectItems($inBlob_blob; ->$offset_i; $childCount_i)
								If ($child_o=Null:C1517)
									$ok_b:=False:C215
								Else 
									OB SET:C1220($result_o; $key_t; $child_o)
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while 
									End if 
								End if 
							Else 
								$ok_b:=False:C215
							End if 
							
						Else 
							$ok_b:=False:C215
					End case 
				End if 
			End if 
			$item_i:=$item_i+1
		End while 
	End if 
End if 

If (Not:C34($ok_b))
	$result_o:=Null:C1517
End if 

If ($result_o=Null:C1517)
	OTr_z_Error("Invalid object"; Current method name:C684)
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
