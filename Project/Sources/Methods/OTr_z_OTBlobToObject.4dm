//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobToObject (inBlob) --> Object

// Converts a legacy ObjectTools object BLOB into the native OTr object
// storage shape. This parser currently supports the OT item families
// proven by the supplied samples: character, date, and character array.

#DECLARE($inBlob_blob : Blob)->$result_o : Object

var $offset_i; $itemCount_i; $item_i; $rootType_i : Integer
var $keyLen_i; $typeByte_i; $textLen_i : Integer
var $count_i; $descriptorBytes_i; $arrayStart_i : Integer
var $day_i; $month_i; $year_i : Integer
var $key_t; $value_t; $yyyy_t; $mm_t; $dd_t : Text
var $array_o : Object
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
