//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_x_OTBlobReadArray (inBlob; ioOffset; inTypeByte) --> Object

// Reads an array payload from the source-defined ObjectTools v3
// Variable4D serialization format.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob   : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr  : Pointer : Offset after the array type marker
//   $inTypeByte_i  : Integer : Serialized type marker, e.g. 162 for text array
//
// Returns:
//   $array_o : Object : Native OTr array object, or Null on failure
//
// Created by Wayne Stewart / Codex, 2026-04-19
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer; $inTypeByte_i : Integer)->$array_o : Object

OTr_z_AddToCallStack(Current method name:C684)

var $arrayType_i; $count_i; $unused_i; $current_i; $handleSize_i : Integer
var $dataStart_i; $dataEnd_i; $allocatedOffset_i; $offset_i : Integer
var $index_i; $allIndex_i; $len_i; $size_i; $bitByte_i; $bitMask_i : Integer
var $day_i; $month_i; $year_i; $long_i; $timeSeconds_i : Integer
var $hour_i; $minute_i; $second_i; $picEnd_i : Integer
var $value_t; $yyyy_t; $mm_t; $dd_t; $hh_t; $mn_t; $ss_t : Text
var $real_r : Real
var $blob_blob : Blob
var $picture_pic : Picture
var $ok_b : Boolean

$array_o:=Null:C1517
$ok_b:=False:C215

If ($ioOffset_ptr#Null:C1517)
	$arrayType_i:=$inTypeByte_i-128
	If (($arrayType_i>=0) & (($ioOffset_ptr->+15)<=BLOB size:C605($inBlob_blob)))
		$ioOffset_ptr->:=$ioOffset_ptr->+1  // fixed-type flag
		$count_i:=OTr_x_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
		$unused_i:=OTr_x_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
		$current_i:=OTr_x_OTBlobReadUInt16BE($inBlob_blob; $ioOffset_ptr)
		$handleSize_i:=OTr_x_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
		$dataStart_i:=$ioOffset_ptr->
		$dataEnd_i:=$dataStart_i+$handleSize_i
		$allocatedOffset_i:=$dataEnd_i
		
		If (($count_i>=0) & ($handleSize_i>=0) & ($dataEnd_i<=BLOB size:C605($inBlob_blob)))
			$ok_b:=True:C214
			
			Case of 
				: ($arrayType_i=14)  // ARRAY REAL
					If ($handleSize_i>=(($count_i+1)*8))
						$array_o:=New object:C1471("arrayType"; Real array:K8:17; "numElements"; $count_i; "currentItem"; $current_i; "0"; 0)
						For ($index_i; 1; $count_i)
							$offset_i:=$dataStart_i+($index_i*8)
							$real_r:=OTr_x_OTBlobReadRealBE($inBlob_blob; ->$offset_i)
							OB SET:C1220($array_o; String:C10($index_i); $real_r)
						End for 
					Else 
						$ok_b:=False:C215
					End if 
					
				: ($arrayType_i=15)  // ARRAY INTEGER
					If ($handleSize_i>=(($count_i+1)*2))
						$array_o:=New object:C1471("arrayType"; LongInt array:K8:19; "numElements"; $count_i; "currentItem"; $current_i; "0"; 0)
						For ($index_i; 1; $count_i)
							$offset_i:=$dataStart_i+($index_i*2)
							$long_i:=OTr_x_OTBlobReadInt16BE($inBlob_blob; ->$offset_i)
							OB SET:C1220($array_o; String:C10($index_i); $long_i)
						End for 
					Else 
						$ok_b:=False:C215
					End if 
					
				: ($arrayType_i=16)  // ARRAY LONGINT
					If ($handleSize_i>=(($count_i+1)*4))
						$array_o:=New object:C1471("arrayType"; LongInt array:K8:19; "numElements"; $count_i; "currentItem"; $current_i; "0"; 0)
						For ($index_i; 1; $count_i)
							$offset_i:=$dataStart_i+($index_i*4)
							$long_i:=OTr_x_OTBlobReadInt32BE($inBlob_blob; ->$offset_i)
							OB SET:C1220($array_o; String:C10($index_i); $long_i)
						End for 
					Else 
						$ok_b:=False:C215
					End if 
					
				: ($arrayType_i=17)  // ARRAY DATE
					If ($handleSize_i>=(($count_i+1)*6))
						$array_o:=New object:C1471("arrayType"; Date array:K8:20; "numElements"; $count_i; "currentItem"; $current_i; "0"; "0000-00-00")
						For ($index_i; 1; $count_i)
							$offset_i:=$dataStart_i+($index_i*6)
							$day_i:=OTr_x_OTBlobReadUInt16BE($inBlob_blob; ->$offset_i)
							$month_i:=OTr_x_OTBlobReadUInt16BE($inBlob_blob; ->$offset_i)
							$year_i:=OTr_x_OTBlobReadUInt16BE($inBlob_blob; ->$offset_i)
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
					Else 
						$ok_b:=False:C215
					End if 
					
				: ($arrayType_i=19)  // ARRAY PICTURE
					If ($handleSize_i>=(($count_i+1)*4))
						$array_o:=New object:C1471("arrayType"; Picture array:K8:22; "numElements"; $count_i; "currentItem"; $current_i; "0"; $picture_pic)
						For ($allIndex_i; 0; $count_i)
							$offset_i:=$dataStart_i+($allIndex_i*4)
							$size_i:=OTr_x_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
							If ($size_i>0)
								If (($allocatedOffset_i+$size_i)<=BLOB size:C605($inBlob_blob))
									If ($allIndex_i>0)
										$picEnd_i:=$allocatedOffset_i
										If (OTr_x_OTBlobReadWrappedPicture($inBlob_blob; $allocatedOffset_i; ->$picEnd_i; ->$picture_pic))
											OB SET:C1220($array_o; String:C10($allIndex_i); $picture_pic)
										Else 
											$ok_b:=False:C215
										End if 
									End if 
									$allocatedOffset_i:=$allocatedOffset_i+$size_i
								Else 
									$ok_b:=False:C215
								End if 
							End if 
						End for 
					Else 
						$ok_b:=False:C215
					End if 
					
				: ($arrayType_i=22)  // ARRAY BOOLEAN
					$array_o:=New object:C1471("arrayType"; Boolean array:K8:21; "numElements"; $count_i; "currentItem"; $current_i; "0"; False:C215)
					For ($index_i; 1; $count_i)
						$offset_i:=$dataStart_i+($index_i\8)
						If ($offset_i<$dataEnd_i)
							$bitByte_i:=$inBlob_blob{$offset_i}
							$bitMask_i:=1
							For ($len_i; 1; ($index_i%8))
								$bitMask_i:=$bitMask_i*2
							End for 
							OB SET:C1220($array_o; String:C10($index_i); ((($bitByte_i\$bitMask_i)%2)#0))
						Else 
							$ok_b:=False:C215
						End if 
					End for 
					
				: ($arrayType_i=31)  // ARRAY BLOB
					If ($handleSize_i>=(($count_i+1)*8))
						$array_o:=New object:C1471("arrayType"; Blob array:K8:30; "numElements"; $count_i; "currentItem"; $current_i; "0"; "")
						For ($allIndex_i; 0; $count_i)
							$offset_i:=$dataStart_i+($allIndex_i*8)
							$size_i:=OTr_x_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
							If ($size_i>0)
								If (($allocatedOffset_i+$size_i)<=BLOB size:C605($inBlob_blob))
									If ($allIndex_i>0)
										SET BLOB SIZE:C606($blob_blob; $size_i)
										COPY BLOB:C558($inBlob_blob; $blob_blob; $allocatedOffset_i; 0; $size_i)
										OB SET:C1220($array_o; String:C10($allIndex_i); OTr_u_BlobToText($blob_blob))
									End if 
									$allocatedOffset_i:=$allocatedOffset_i+$size_i
								Else 
									$ok_b:=False:C215
								End if 
							Else 
								If ($allIndex_i>0)
									SET BLOB SIZE:C606($blob_blob; 0)
									OB SET:C1220($array_o; String:C10($allIndex_i); OTr_u_BlobToText($blob_blob))
								End if 
							End if 
						End for 
					Else 
						$ok_b:=False:C215
					End if 
					
				: ($arrayType_i=32)  // ARRAY TIME
					If ($handleSize_i>=(($count_i+1)*4))
						$array_o:=New object:C1471("arrayType"; Time array:K8:29; "numElements"; $count_i; "currentItem"; $current_i; "0"; "00:00:00")
						For ($index_i; 1; $count_i)
							$offset_i:=$dataStart_i+($index_i*4)
							$timeSeconds_i:=OTr_x_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
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
					Else 
						$ok_b:=False:C215
					End if 
					
				: ($arrayType_i=34)  // ARRAY TEXT / STRING stored as Unicode
					If ($handleSize_i>=(($count_i+1)*16))
						$array_o:=New object:C1471("arrayType"; Text array:K8:16; "numElements"; $count_i; "currentItem"; $current_i; "0"; "")
						For ($allIndex_i; 0; $count_i)
							$offset_i:=$dataStart_i+($allIndex_i*16)
							$len_i:=OTr_x_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
							If ($len_i>0)
								$value_t:=OTr_x_OTBlobReadSerializedText($inBlob_blob; ->$allocatedOffset_i; True:C214)
							Else 
								$value_t:=""
							End if 
							If ($allIndex_i>0)
								OB SET:C1220($array_o; String:C10($allIndex_i); $value_t)
							End if 
						End for 
					Else 
						$ok_b:=False:C215
					End if 
					
				Else 
					$ok_b:=False:C215
			End case 
			
			If ($ok_b)
				$ioOffset_ptr->:=$allocatedOffset_i
			Else 
				$array_o:=Null:C1517
			End if 
		End if 
	End if 
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
