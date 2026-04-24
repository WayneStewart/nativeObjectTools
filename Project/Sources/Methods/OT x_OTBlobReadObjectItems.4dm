//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OT x_OTBlobReadObjectItems (inBlob; ioOffset; inItemCount) --> Object

// Reads ObjectTools v3 item records from ioOffset into native OTr
// object storage shape.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob    : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr   : Pointer : Current read offset, advanced past items
//   $inItemCount_i  : Integer : Number of items to read
//
// Returns:
//   $result_o : Object : Native OTr object storage shape, or Null on failure
//
// Created by Wayne Stewart / Codex, 2026-04-19
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer; $inItemCount_i : Integer)->$result_o : Object

OTr_z_AddToCallStack(Current method name:C684)

var $item_i; $typeByte_i; $childCount_i; $size_i; $table_i : Integer
var $day_i; $month_i; $year_i; $long_i; $timeSeconds_i : Integer
var $hour_i; $minute_i; $second_i; $pictureEnd_i : Integer
var $key_t; $value_t; $yyyy_t; $mm_t; $dd_t; $hh_t; $mn_t; $ss_t : Text
var $real_r : Real
var $array_o; $child_o; $record_o : Object
var $blob_blob : Blob
var $picture_pic : Picture
var $ok_b : Boolean

$result_o:=New object:C1471
$ok_b:=($ioOffset_ptr#Null:C1517) & ($inItemCount_i>=0)

$item_i:=1
While (($item_i<=$inItemCount_i) & ($ok_b))
	$key_t:=OT x_OTBlobReadSerializedText($inBlob_blob; $ioOffset_ptr; False:C215)
	
	If (($ioOffset_ptr->+1)>BLOB size:C605($inBlob_blob))
		$ok_b:=False:C215
	Else 
		$typeByte_i:=$inBlob_blob{$ioOffset_ptr->}
		$ioOffset_ptr->:=$ioOffset_ptr->+1
		
		Case of 
			: ($typeByte_i=114)  // embedded object
				$childCount_i:=OT x_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
				$child_o:=OT x_OTBlobReadObjectItems($inBlob_blob; $ioOffset_ptr; $childCount_i)
				If ($child_o=Null:C1517)
					$ok_b:=False:C215
				Else 
					OB SET:C1220($result_o; $key_t; $child_o)
					OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); OT Is Object)
				End if 
				
			: ($typeByte_i=115)  // packed record
				$record_o:=OT x_OTBlobReadRecord($inBlob_blob; $ioOffset_ptr)
				If ($record_o=Null:C1517)
					$ok_b:=False:C215
				Else 
					OB SET:C1220($result_o; $key_t; $record_o)
					OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); OT Is Record)
				End if 
				
			: ($typeByte_i=129)  // real
				$ioOffset_ptr->:=$ioOffset_ptr->+1
				$real_r:=OT x_OTBlobReadRealBE($inBlob_blob; $ioOffset_ptr)
				OB SET:C1220($result_o; $key_t; $real_r)
				OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is real:K8:4)
				
			: ($typeByte_i=132)  // date
				$ioOffset_ptr->:=$ioOffset_ptr->+1
				$day_i:=OT x_OTBlobReadUInt16BE($inBlob_blob; $ioOffset_ptr)
				$month_i:=OT x_OTBlobReadUInt16BE($inBlob_blob; $ioOffset_ptr)
				$year_i:=OT x_OTBlobReadUInt16BE($inBlob_blob; $ioOffset_ptr)
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
				
			: ($typeByte_i=134)  // boolean
				$ioOffset_ptr->:=$ioOffset_ptr->+1
				OB SET:C1220($result_o; $key_t; ($inBlob_blob{$ioOffset_ptr->}#0))
				OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is boolean:K8:9)
				$ioOffset_ptr->:=$ioOffset_ptr->+1
				
			: ($typeByte_i=137)  // longint
				$ioOffset_ptr->:=$ioOffset_ptr->+1
				$long_i:=OT x_OTBlobReadInt32BE($inBlob_blob; $ioOffset_ptr)
				OB SET:C1220($result_o; $key_t; $long_i)
				OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is longint:K8:6)
				
			: ($typeByte_i=138)  // picture
				$ioOffset_ptr->:=$ioOffset_ptr->+1
				$size_i:=OT x_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
				If (($size_i>=0) & (($ioOffset_ptr->+$size_i)<=BLOB size:C605($inBlob_blob)))
					If ($size_i>0)
						$pictureEnd_i:=$ioOffset_ptr->
						If (OT x_OTBlobReadWrappedPicture($inBlob_blob; $ioOffset_ptr->; ->$pictureEnd_i; ->$picture_pic))
							OB SET:C1220($result_o; $key_t; $picture_pic)
							OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is picture:K8:10)
						Else 
							$ok_b:=False:C215
						End if 
					Else 
						OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is picture:K8:10)
					End if 
					$ioOffset_ptr->:=$ioOffset_ptr->+$size_i
				Else 
					$ok_b:=False:C215
				End if 
				
			: ($typeByte_i=139)  // time
				$ioOffset_ptr->:=$ioOffset_ptr->+1
				$timeSeconds_i:=OT x_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
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
				
			: ($typeByte_i=158)  // BLOB
				If (OT x_OTBlobReadBlobPayload($inBlob_blob; $ioOffset_ptr; ->$blob_blob))
					If (Storage:C1525.OTr.nativeBlobInObject)
						OB SET:C1220($result_o; $key_t; $blob_blob)
					Else 
						OB SET:C1220($result_o; $key_t; OTr_u_BlobToText($blob_blob))
					End if 
					OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); Is BLOB:K8:12)
				Else 
					$ok_b:=False:C215
				End if 
				
			: ($typeByte_i=161)  // Unicode text
				$ioOffset_ptr->:=$ioOffset_ptr->+1
				$value_t:=OT x_OTBlobReadSerializedText($inBlob_blob; $ioOffset_ptr; True:C214)
				OB SET:C1220($result_o; $key_t; $value_t)
				OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); OT Is Character)
				
			: (($typeByte_i>=142) & ($typeByte_i<=162))
				$array_o:=OT x_OTBlobReadArray($inBlob_blob; $ioOffset_ptr; $typeByte_i)
				If ($array_o=Null:C1517)
					$ok_b:=False:C215
				Else 
					OB SET:C1220($result_o; $key_t; $array_o)
				End if 
				
			Else 
				$ok_b:=False:C215
		End case 
	End if 
	
	$item_i:=$item_i+1
End while 

If (Not:C34($ok_b))
	$result_o:=Null:C1517
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
