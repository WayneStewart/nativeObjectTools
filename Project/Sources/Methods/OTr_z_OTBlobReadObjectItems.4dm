//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadObjectItems (inBlob; ioOffset; inItemCount) --> Object

// Parses inItemCount legacy OT item records from ioOffset into a native
// OTr object shape. Used for embedded ObjectTools objects, whose payload
// stores item records without the top-level "Objects!" envelope.

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer; $inItemCount_i : Integer)->$result_o : Object

var $item_i; $keyLen_i; $typeByte_i; $textLen_i : Integer
var $count_i; $descriptorBytes_i; $arrayStart_i; $payloadStart_i : Integer
var $index_i; $childCount_i : Integer
var $factor_i; $bit_i : Integer
var $day_i; $month_i; $year_i; $long_i; $timeSeconds_i : Integer
var $hour_i; $minute_i; $second_i : Integer
var $key_t; $value_t; $yyyy_t; $mm_t; $dd_t : Text
var $hh_t; $mn_t; $ss_t : Text
var $real_r : Real
var $array_o; $child_o : Object
var $blob_blob : Blob
var $picture_pic : Picture
var $ok_b : Boolean

$result_o:=New object
$ok_b:=True
$item_i:=1

While (($item_i<=$inItemCount_i) & ($ok_b))
	If (($ioOffset_ptr->+2)>BLOB size($inBlob_blob))
		$ok_b:=False
	Else
		$keyLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
		If (($keyLen_i<=0) | (($ioOffset_ptr->+(($keyLen_i*2)-1))>=BLOB size($inBlob_blob)))
			$ok_b:=False
		Else
			$key_t:=OTr_z_OTBlobReadKey($inBlob_blob; $ioOffset_ptr; $keyLen_i)
			$typeByte_i:=$inBlob_blob{$ioOffset_ptr->}
			$ioOffset_ptr->:=$ioOffset_ptr->+1
			
			Case of
				: ($typeByte_i=161)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$textLen_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$value_t:=OTr_z_OTBlobReadUTF16LE($inBlob_blob; $ioOffset_ptr; $textLen_i; True)
					OB SET($result_o; $key_t; $value_t)
					OB SET($result_o; OTr_z_ShadowKey($key_t); OT Is Character)
					If ($item_i<$inItemCount_i)
						If (($ioOffset_ptr->+1)<BLOB size($inBlob_blob))
							If (($inBlob_blob{$ioOffset_ptr->}=0) & ($inBlob_blob{$ioOffset_ptr->+1}=0))
								$ioOffset_ptr->:=$ioOffset_ptr->+2
							End if
						End if
					End if
					
				: ($typeByte_i=132)
					$ioOffset_ptr->:=$ioOffset_ptr->+2
					$day_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$month_i:=$inBlob_blob{$ioOffset_ptr->}
					$ioOffset_ptr->:=$ioOffset_ptr->+1
					$year_i:=($inBlob_blob{$ioOffset_ptr->}*256)+$inBlob_blob{$ioOffset_ptr->+1}
					$ioOffset_ptr->:=$ioOffset_ptr->+5
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
					$ioOffset_ptr->:=$ioOffset_ptr->+1
					$real_r:=OTr_z_OTBlobReadRealBE($inBlob_blob; $ioOffset_ptr)
					OB SET($result_o; $key_t; $real_r)
					OB SET($result_o; OTr_z_ShadowKey($key_t); Is real)
					If ($item_i<$inItemCount_i)
						While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
							$ioOffset_ptr->:=$ioOffset_ptr->+1
						End while
					End if
					
				: ($typeByte_i=137)
					$ioOffset_ptr->:=$ioOffset_ptr->+1
					$long_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
					If ($long_i>2147483647)
						$long_i:=$long_i-4294967296
					End if
					OB SET($result_o; $key_t; $long_i)
					OB SET($result_o; OTr_z_ShadowKey($key_t); Is longint)
					If ($item_i<$inItemCount_i)
						While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
							$ioOffset_ptr->:=$ioOffset_ptr->+1
						End while
					End if
					
				: ($typeByte_i=134)
					$ioOffset_ptr->:=$ioOffset_ptr->+1
					OB SET($result_o; $key_t; ($inBlob_blob{$ioOffset_ptr->}#0))
					OB SET($result_o; OTr_z_ShadowKey($key_t); Is boolean)
					$ioOffset_ptr->:=$ioOffset_ptr->+1
					If ($item_i<$inItemCount_i)
						While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
							$ioOffset_ptr->:=$ioOffset_ptr->+1
						End while
					End if
					
				: ($typeByte_i=139)
					$ioOffset_ptr->:=$ioOffset_ptr->+1
					$timeSeconds_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
					$hour_i:=$timeSeconds_i\3600
					$minute_i:=($timeSeconds_i%3600)\60
					$second_i:=$timeSeconds_i%60
					$hh_t:=String($hour_i; "00")
					$mn_t:=String($minute_i; "00")
					$ss_t:=String($second_i; "00")
					OB SET($result_o; $key_t; $hh_t+":"+$mn_t+":"+$ss_t)
					OB SET($result_o; OTr_z_ShadowKey($key_t); Is time)
					If ($item_i<$inItemCount_i)
						While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
							$ioOffset_ptr->:=$ioOffset_ptr->+1
						End while
					End if
					
				: ($typeByte_i=158)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$count_i:=$inBlob_blob{$ioOffset_ptr->}
					$ioOffset_ptr->:=$ioOffset_ptr->+1
					If (($ioOffset_ptr->+$count_i)<=BLOB size($inBlob_blob))
						SET BLOB SIZE($blob_blob; $count_i)
						COPY BLOB($inBlob_blob; $blob_blob; $ioOffset_ptr->; 0; $count_i)
						$ioOffset_ptr->:=$ioOffset_ptr->+$count_i
						If (Storage:C1525.OTr.nativeBlobInObject)
							OB SET($result_o; $key_t; $blob_blob)
						Else
							OB SET($result_o; $key_t; OTr_u_BlobToText($blob_blob))
						End if
						OB SET($result_o; OTr_z_ShadowKey($key_t); Is BLOB)
						OTr_z_SetOK(1)
						If ($item_i<$inItemCount_i)
							While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
								$ioOffset_ptr->:=$ioOffset_ptr->+1
							End while
						End if
					Else
						$ok_b:=False
					End if
					
				: ($typeByte_i=138)
					If (OTr_z_OTBlobReadWrappedPicture($inBlob_blob; $ioOffset_ptr->; $ioOffset_ptr; ->$picture_pic))
						OB SET($result_o; $key_t; $picture_pic)
						OB SET($result_o; OTr_z_ShadowKey($key_t); Is picture:K8:10)
						OTr_z_SetOK(1)
						If ($item_i<$inItemCount_i)
							While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
								$ioOffset_ptr->:=$ioOffset_ptr->+1
							End while
						End if
					Else
						$ok_b:=False
					End if
					
				: ($typeByte_i=162)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+8
					$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$arrayStart_i:=$ioOffset_ptr->+$descriptorBytes_i
					$array_o:=OTr_z_OTBlobReadTextArray($inBlob_blob; $arrayStart_i; $ioOffset_ptr; $count_i)
					If ($array_o=Null)
						$ok_b:=False
					Else
						OB SET($result_o; $key_t; $array_o)
					End if
					
				: ($typeByte_i=144)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+8
					$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$payloadStart_i:=$ioOffset_ptr->-1
					$array_o:=New object("arrayType"; LongInt array; "numElements"; $count_i; "currentItem"; 0; "0"; 0)
					$ioOffset_ptr->:=$payloadStart_i
					For ($index_i; 1; $count_i)
						$long_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
						If ($long_i>2147483647)
							$long_i:=$long_i-4294967296
						End if
						OB SET($array_o; String($index_i); $long_i)
					End for
					OB SET($result_o; $key_t; $array_o)
					If ($item_i<$inItemCount_i)
						While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
							$ioOffset_ptr->:=$ioOffset_ptr->+1
						End while
					End if
					
				: ($typeByte_i=142)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+8
					$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$payloadStart_i:=$ioOffset_ptr->+3
					$array_o:=New object("arrayType"; Real array; "numElements"; $count_i; "currentItem"; 0; "0"; 0)
					$ioOffset_ptr->:=$payloadStart_i
					For ($index_i; 1; $count_i)
						$real_r:=OTr_z_OTBlobReadRealBE($inBlob_blob; $ioOffset_ptr)
						OB SET($array_o; String($index_i); $real_r)
					End for
					OB SET($result_o; $key_t; $array_o)
					If ($item_i<$inItemCount_i)
						While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
							$ioOffset_ptr->:=$ioOffset_ptr->+1
						End while
					End if
					
				: ($typeByte_i=145)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+8
					$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$payloadStart_i:=$ioOffset_ptr->+2
					$array_o:=New object("arrayType"; Date array; "numElements"; $count_i; "currentItem"; 0; "0"; "0000-00-00")
					$ioOffset_ptr->:=$payloadStart_i
					For ($index_i; 1; $count_i)
						$day_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
						$month_i:=$inBlob_blob{$ioOffset_ptr->}
						$ioOffset_ptr->:=$ioOffset_ptr->+1
						$year_i:=($inBlob_blob{$ioOffset_ptr->}*256)+$inBlob_blob{$ioOffset_ptr->+1}
						$ioOffset_ptr->:=$ioOffset_ptr->+2
						If ($index_i<$count_i)
							$ioOffset_ptr->:=$ioOffset_ptr->+1
						End if
						$yyyy_t:=String($year_i; "0000")
						$mm_t:=String($month_i; "00")
						$dd_t:=String($day_i; "00")
						OB SET($array_o; String($index_i); $yyyy_t+"-"+$mm_t+"-"+$dd_t)
					End for
					OB SET($result_o; $key_t; $array_o)
					If ($item_i<$inItemCount_i)
						While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
							$ioOffset_ptr->:=$ioOffset_ptr->+1
						End while
					End if
					
				: ($typeByte_i=160)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+8
					$descriptorBytes_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$payloadStart_i:=$ioOffset_ptr->-1
					$array_o:=New object("arrayType"; Time array; "numElements"; $count_i; "currentItem"; 0; "0"; "00:00:00")
					$ioOffset_ptr->:=$payloadStart_i
					For ($index_i; 1; $count_i)
						$timeSeconds_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
						$hour_i:=$timeSeconds_i\3600
						$minute_i:=($timeSeconds_i%3600)\60
						$second_i:=$timeSeconds_i%60
						OB SET($array_o; String($index_i); String($hour_i; "00")+":"+String($minute_i; "00")+":"+String($second_i; "00"))
					End for
					OB SET($result_o; $key_t; $array_o)
					If ($item_i<$inItemCount_i)
						While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
							$ioOffset_ptr->:=$ioOffset_ptr->+1
						End while
					End if
					
				: ($typeByte_i=150)
					$ioOffset_ptr->:=$ioOffset_ptr->+4
					$count_i:=OTr_z_OTBlobReadUInt16LE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+8
					$array_o:=New object("arrayType"; Boolean array; "numElements"; $count_i; "currentItem"; 0; "0"; False)
					$ioOffset_ptr->:=$ioOffset_ptr->+1
					If ($ioOffset_ptr-><BLOB size($inBlob_blob))
						For ($index_i; 1; $count_i)
							$factor_i:=1
							For ($bit_i; 1; $index_i)
								$factor_i:=$factor_i*2
							End for
							OB SET($array_o; String($index_i); ((($inBlob_blob{$ioOffset_ptr->}\$factor_i)%2)#0))
						End for
						$ioOffset_ptr->:=$ioOffset_ptr->+1
						OB SET($result_o; $key_t; $array_o)
						If ($item_i<$inItemCount_i)
							While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
								$ioOffset_ptr->:=$ioOffset_ptr->+1
							End while
						End if
					Else
						$ok_b:=False
					End if
					
				: ($typeByte_i=114)
					$childCount_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
					$ioOffset_ptr->:=$ioOffset_ptr->+3
					$child_o:=OTr_z_OTBlobReadObjectItems($inBlob_blob; $ioOffset_ptr; $childCount_i)
					If ($child_o=Null)
						$ok_b:=False
					Else
						OB SET($result_o; $key_t; $child_o)
						If ($item_i<$inItemCount_i)
							While (($ioOffset_ptr-><BLOB size($inBlob_blob)) & ($inBlob_blob{$ioOffset_ptr->}=0))
								$ioOffset_ptr->:=$ioOffset_ptr->+1
							End while
						End if
					End if
					
				Else
					$ok_b:=False
			End case
		End if
	End if
	$item_i:=$item_i+1
End while

If (Not($ok_b))
	$result_o:=Null
End if
