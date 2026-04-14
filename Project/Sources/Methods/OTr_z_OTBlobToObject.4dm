//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobToObject (inBlob) --> Object

// Converts a legacy ObjectTools object BLOB into the native OTr object
// storage shape.
//
// Supports the Phase 16 proven legacy OT payload markers for text, date,
// longint, real, boolean, time, BLOB, PNG/JPEG picture, text array,
// longint array, real array, boolean array, date array, time array, and
// embedded objects.
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
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob)->$result_o : Object

OTr_z_AddToCallStack(Current method name:C684)

var $offset_i; $itemCount_i; $item_i; $rootType_i : Integer
var $keyLen_i; $typeByte_i; $textLen_i : Integer
var $count_i; $descriptorBytes_i; $arrayStart_i : Integer
var $index_i; $payloadStart_i; $childCount_i : Integer
var $factor_i; $bit_i : Integer
var $day_i; $month_i; $year_i : Integer
var $long_i; $timeSeconds_i : Integer
var $hour_i; $minute_i; $second_i : Integer
var $key_t; $value_t; $yyyy_t; $mm_t; $dd_t : Text
var $hh_t; $mn_t; $ss_t : Text
var $real_r : Real
var $array_o; $child_o : Object
var $blob_blob : Blob
var $picture_pic : Picture
var $ok_b : Boolean

$result_o:=Null
$ok_b:=False

If (OTr_z_OTBlobIsObject($inBlob_blob))
	$offset_i:=14
	OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
	$rootType_i:=OTr_z_OTBlobReadUInt32LE($inBlob_blob; ->$offset_i)
	$itemCount_i:=OTr_z_OTBlobReadUInt32LE($inBlob_blob; ->$offset_i)

	If (($rootType_i=OT Is Object) & ($itemCount_i>=0))
		$result_o:=New object
		$ok_b:=True
		$item_i:=1

		While (($item_i<=$itemCount_i) & ($ok_b))
			If (($offset_i+2)>BLOB size($inBlob_blob))
				$ok_b:=False
			Else
				$keyLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
				If (($keyLen_i<=0) | (($offset_i+(($keyLen_i*2)-1))>=BLOB size($inBlob_blob)))
					$ok_b:=False
				Else
					$key_t:=OTr_z_OTBlobReadKey($inBlob_blob; ->$offset_i; $keyLen_i)
					$typeByte_i:=$inBlob_blob{$offset_i}
					$offset_i:=$offset_i+1

					Case of
						: ($typeByte_i=161)
							$offset_i:=$offset_i+4
							$textLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$value_t:=OTr_z_OTBlobReadUTF16LE($inBlob_blob; ->$offset_i; $textLen_i; True)
							OB SET($result_o; $key_t; $value_t)
							OB SET($result_o; OTr_z_ShadowKey($key_t); OT Is Character)

							If ($item_i<$itemCount_i)
								If (($offset_i+1)<BLOB size($inBlob_blob))
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

							$yyyy_t:=String($year_i)
							While (Length($yyyy_t)<4)
								$yyyy_t:="0"+$yyyy_t
							End while
							$mm_t:=String($month_i)
							If (Length($mm_t)<2)
								$mm_t:="0"+$mm_t
							End if
							$dd_t:=String($day_i)
							If (Length($dd_t)<2)
								$dd_t:="0"+$dd_t
							End if

							OB SET($result_o; $key_t; $yyyy_t+"-"+$mm_t+"-"+$dd_t)
							OB SET($result_o; OTr_z_ShadowKey($key_t); Is date)

						: ($typeByte_i=129)
							If (($offset_i+8)<BLOB size($inBlob_blob))
								$offset_i:=$offset_i+1
								$real_r:=OTr_z_OTBlobReadRealBE($inBlob_blob; ->$offset_i)
								OB SET($result_o; $key_t; $real_r)
								OB SET($result_o; OTr_z_ShadowKey($key_t); Is real)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=137)
							If (($offset_i+4)<BLOB size($inBlob_blob))
								$offset_i:=$offset_i+1
								$long_i:=OTr_z_OTBlobReadInt32BE($inBlob_blob; ->$offset_i)
								OB SET($result_o; $key_t; $long_i)
								OB SET($result_o; OTr_z_ShadowKey($key_t); Is longint)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=134)
							If (($offset_i+1)<BLOB size($inBlob_blob))
								$offset_i:=$offset_i+1
								OB SET($result_o; $key_t; ($inBlob_blob{$offset_i}#0))
								OB SET($result_o; OTr_z_ShadowKey($key_t); Is boolean)
								$offset_i:=$offset_i+1
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=139)
							If (($offset_i+4)<BLOB size($inBlob_blob))
								$offset_i:=$offset_i+1
								$timeSeconds_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
								$hour_i:=$timeSeconds_i\3600
								$minute_i:=($timeSeconds_i%3600)\60
								$second_i:=$timeSeconds_i%60
								$hh_t:=String($hour_i)
								If (Length($hh_t)<2)
									$hh_t:="0"+$hh_t
								End if
								$mn_t:=String($minute_i)
								If (Length($mn_t)<2)
									$mn_t:="0"+$mn_t
								End if
								$ss_t:=String($second_i)
								If (Length($ss_t)<2)
									$ss_t:="0"+$ss_t
								End if
								OB SET($result_o; $key_t; $hh_t+":"+$mn_t+":"+$ss_t)
								OB SET($result_o; OTr_z_ShadowKey($key_t); Is time)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=158)
							If (OTr_z_OTBlobReadBlobPayload($inBlob_blob; ->$offset_i; ->$blob_blob))
								If (Storage:C1525.OTr.nativeBlobInObject)
									OB SET($result_o; $key_t; $blob_blob)
								Else
									OB SET($result_o; $key_t; OTr_u_BlobToText($blob_blob))
								End if
								OB SET($result_o; OTr_z_ShadowKey($key_t); Is BLOB)
								OTr_z_SetOK(1)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=138)
							If (OTr_z_OTBlobReadWrappedPicture($inBlob_blob; $offset_i; ->$offset_i; ->$picture_pic))
								OB SET($result_o; $key_t; $picture_pic)
								OB SET($result_o; OTr_z_ShadowKey($key_t); Is picture:K8:10)
								OTr_z_SetOK(1)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
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
								$ok_b:=False
							Else
								OB SET($result_o; $key_t; $array_o)
							End if

						: ($typeByte_i=144)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							$payloadStart_i:=$offset_i-1
							If (($payloadStart_i>=0) & (($payloadStart_i+($count_i*4))<=BLOB size($inBlob_blob)))
								$array_o:=New object("arrayType"; LongInt array; "numElements"; $count_i; "currentItem"; 0; "0"; 0)
								$offset_i:=$payloadStart_i
								For ($index_i; 1; $count_i)
									$long_i:=OTr_z_OTBlobReadInt32BE($inBlob_blob; ->$offset_i)
									OB SET($array_o; String($index_i); $long_i)
								End for
								OB SET($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=142)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							$payloadStart_i:=$offset_i+3
							If (($payloadStart_i>=0) & (($payloadStart_i+($count_i*8))<=BLOB size($inBlob_blob)))
								$array_o:=New object("arrayType"; Real array; "numElements"; $count_i; "currentItem"; 0; "0"; 0)
								$offset_i:=$payloadStart_i
								For ($index_i; 1; $count_i)
									$real_r:=OTr_z_OTBlobReadRealBE($inBlob_blob; ->$offset_i)
									OB SET($array_o; String($index_i); $real_r)
								End for
								OB SET($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=145)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							$payloadStart_i:=$offset_i+2
							If (($payloadStart_i>=0) & (($payloadStart_i+($count_i*5)+($count_i-1))<=BLOB size($inBlob_blob)))
								$array_o:=New object("arrayType"; Date array; "numElements"; $count_i; "currentItem"; 0; "0"; "0000-00-00")
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
									$yyyy_t:=String($year_i)
									While (Length($yyyy_t)<4)
										$yyyy_t:="0"+$yyyy_t
									End while
									$mm_t:=String($month_i)
									If (Length($mm_t)<2)
										$mm_t:="0"+$mm_t
									End if
									$dd_t:=String($day_i)
									If (Length($dd_t)<2)
										$dd_t:="0"+$dd_t
									End if
									OB SET($array_o; String($index_i); $yyyy_t+"-"+$mm_t+"-"+$dd_t)
								End for
								OB SET($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=160)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+4
							$payloadStart_i:=$offset_i-1
							If (($payloadStart_i>=0) & (($payloadStart_i+($count_i*4))<=BLOB size($inBlob_blob)))
								$array_o:=New object("arrayType"; Time array; "numElements"; $count_i; "currentItem"; 0; "0"; "00:00:00")
								$offset_i:=$payloadStart_i
								For ($index_i; 1; $count_i)
									$timeSeconds_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
									$hour_i:=$timeSeconds_i\3600
									$minute_i:=($timeSeconds_i%3600)\60
									$second_i:=$timeSeconds_i%60
									$hh_t:=String($hour_i)
									If (Length($hh_t)<2)
										$hh_t:="0"+$hh_t
									End if
									$mn_t:=String($minute_i)
									If (Length($mn_t)<2)
										$mn_t:="0"+$mn_t
									End if
									$ss_t:=String($second_i)
									If (Length($ss_t)<2)
										$ss_t:="0"+$ss_t
									End if
									OB SET($array_o; String($index_i); $hh_t+":"+$mn_t+":"+$ss_t)
								End for
								OB SET($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=150)
							$offset_i:=$offset_i+4
							$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$offset_i:=$offset_i+8
							$array_o:=New object("arrayType"; Boolean array; "numElements"; $count_i; "currentItem"; 0; "0"; False)
							$offset_i:=$offset_i+1
							If ($offset_i<BLOB size($inBlob_blob))
								For ($index_i; 1; $count_i)
									$factor_i:=1
									For ($bit_i; 1; $index_i)
										$factor_i:=$factor_i*2
									End for
									OB SET($array_o; String($index_i); ((($inBlob_blob{$offset_i}\$factor_i)%2)#0))
								End for
								$offset_i:=$offset_i+1
								OB SET($result_o; $key_t; $array_o)
								If ($item_i<$itemCount_i)
									While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
										$offset_i:=$offset_i+1
									End while
								End if
							Else
								$ok_b:=False
							End if

						: ($typeByte_i=114)
							If (($offset_i+6)<BLOB size($inBlob_blob))
								$childCount_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
								$offset_i:=$offset_i+3
								$child_o:=OTr_z_OTBlobReadObjectItems($inBlob_blob; ->$offset_i; $childCount_i)
								If ($child_o=Null)
									$ok_b:=False
								Else
									OB SET($result_o; $key_t; $child_o)
									If ($item_i<$itemCount_i)
										While (($offset_i<BLOB size($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
											$offset_i:=$offset_i+1
										End while
									End if
								End if
							Else
								$ok_b:=False
							End if

						Else
							$ok_b:=False
					End case
				End if
			End if
			$item_i:=$item_i+1
		End while
	End if
End if

If (Not($ok_b))
	$result_o:=Null
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
