//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_x_OTBlobReadRecord (inBlob; ioOffset) --> Object

// Reads a legacy ObjectTools packed record payload (marker 115) into
// the native OTr record snapshot shape.
//
// The legacy payload stores field number, compact field type, and value
// tuples. Field names are not present in the BLOB, so stable fieldN
// properties are always written. When the source table number is valid
// in the current database, matching field-name properties are also
// written so OTr_GetRecord can restore into a current record.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob  : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr : Pointer : Offset at record payload start; receives end offset
//
// Returns:
//   $record_o : Object : Record snapshot object, or Null on failure
//
// Created by Wayne Stewart / Codex, 2026-04-16
// Wayne Stewart / Codex, 2026-04-16 - Added OT packed record payload reader.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$record_o : Object

OTr_z_AddToCallStack(Current method name:C684)

var $offset_i; $tableNum_i; $recordNum_i; $flags_i : Integer
var $fieldNum_i; $fieldType_i; $textLen_i; $value_i; $fieldCount_i : Integer
var $year_i; $month_i; $day_i : Integer
var $fieldKey_t; $fieldName_t; $value_t; $yyyy_t; $mm_t; $dd_t : Text
var $value_r : Real
var $value_b : Boolean
var $fields_o; $fieldTypes_o : Object
var $tablePtr_ptr; $fieldPtr_ptr : Pointer
var $ok_b; $haveTable_b : Boolean

$record_o:=Null
$ok_b:=False

If ($ioOffset_ptr#Null)
	$offset_i:=$ioOffset_ptr->
	If (($offset_i+7)<BLOB size($inBlob_blob))
		$tableNum_i:=($inBlob_blob{$offset_i}*256)+$inBlob_blob{$offset_i+1}
		$offset_i:=$offset_i+2
		$recordNum_i:=OTr_x_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
		$flags_i:=OTr_x_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
		
		$record_o:=New object("__tableNum"; $tableNum_i; "__recordNum"; $recordNum_i; "__flags"; $flags_i)
		$fields_o:=New object
		$fieldTypes_o:=New object
		$fieldCount_i:=0
		OB SET($record_o; "__fields"; $fields_o)
		OB SET($record_o; "__fieldTypes"; $fieldTypes_o)
		
		$haveTable_b:=False
		If (Is table number valid:C999($tableNum_i))
			$tablePtr_ptr:=Table:C252($tableNum_i)
			$haveTable_b:=True
		End if
		
		$ok_b:=True
		While (($ok_b) & (($offset_i+3)<BLOB size($inBlob_blob)))
			$fieldNum_i:=OTr_x_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
			$fieldType_i:=OTr_x_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
			
			If (($fieldNum_i=0) & ($fieldType_i=0))
				$offset_i:=BLOB size($inBlob_blob)
			Else
				$fieldKey_t:="field"+String($fieldNum_i)
				OB SET($fieldTypes_o; String($fieldNum_i); $fieldType_i)
				
				$fieldName_t:=""
				If ($haveTable_b)
					If (Is field number valid:C1000($tablePtr_ptr; $fieldNum_i))
						$fieldPtr_ptr:=Field:C253($tableNum_i; $fieldNum_i)
						$fieldName_t:=Field name:C257($fieldPtr_ptr)
					End if
				End if
				
				Case of
					: ($fieldType_i=1)
						If (($offset_i+1)<BLOB size($inBlob_blob))
							$value_i:=OTr_x_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							OB SET($record_o; $fieldKey_t; $value_i)
							OB SET($fields_o; String($fieldNum_i); $fieldKey_t)
							$fieldCount_i:=$fieldCount_i+1
							If ($fieldName_t#"")
								OB SET($record_o; $fieldName_t; $value_i)
							End if
						Else
							$ok_b:=False
						End if
						
					: ($fieldType_i=3)
						If (($offset_i+1)<BLOB size($inBlob_blob))
							$value_i:=OTr_x_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$value_b:=($value_i#0)
							OB SET($record_o; $fieldKey_t; $value_b)
							OB SET($fields_o; String($fieldNum_i); $fieldKey_t)
							$fieldCount_i:=$fieldCount_i+1
							If ($fieldName_t#"")
								OB SET($record_o; $fieldName_t; $value_b)
							End if
						Else
							$ok_b:=False
						End if
						
					: ($fieldType_i=4)
						If (($offset_i+3)<BLOB size($inBlob_blob))
							$value_i:=OTr_x_OTBlobReadInt32LE($inBlob_blob; ->$offset_i)
							OB SET($record_o; $fieldKey_t; $value_i)
							OB SET($fields_o; String($fieldNum_i); $fieldKey_t)
							$fieldCount_i:=$fieldCount_i+1
							If ($fieldName_t#"")
								OB SET($record_o; $fieldName_t; $value_i)
							End if
						Else
							$ok_b:=False
						End if
						
					: ($fieldType_i=6)
						If (($offset_i+7)<BLOB size($inBlob_blob))
							$value_r:=OTr_x_OTBlobReadRealLE($inBlob_blob; ->$offset_i)
							OB SET($record_o; $fieldKey_t; $value_r)
							OB SET($fields_o; String($fieldNum_i); $fieldKey_t)
							$fieldCount_i:=$fieldCount_i+1
							If ($fieldName_t#"")
								OB SET($record_o; $fieldName_t; $value_r)
							End if
						Else
							$ok_b:=False
						End if
						
					: ($fieldType_i=8)
						If (($offset_i+7)<BLOB size($inBlob_blob))
							$year_i:=OTr_x_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
							$month_i:=$inBlob_blob{$offset_i}
							$day_i:=$inBlob_blob{$offset_i+1}
							$offset_i:=$offset_i+6
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
							$value_t:=$yyyy_t+"-"+$mm_t+"-"+$dd_t
							OB SET($record_o; $fieldKey_t; $value_t)
							OB SET($fields_o; String($fieldNum_i); $fieldKey_t)
							$fieldCount_i:=$fieldCount_i+1
						Else
							$ok_b:=False
						End if
						
					: ($fieldType_i=9)
						If (($offset_i+7)<BLOB size($inBlob_blob))
							$value_t:=String($inBlob_blob{$offset_i})+" "+String($inBlob_blob{$offset_i+1})+" "+String($inBlob_blob{$offset_i+2})+" "+String($inBlob_blob{$offset_i+3})+" "+String($inBlob_blob{$offset_i+4})+" "+String($inBlob_blob{$offset_i+5})+" "+String($inBlob_blob{$offset_i+6})+" "+String($inBlob_blob{$offset_i+7})
							$offset_i:=$offset_i+8
							OB SET($record_o; $fieldKey_t; $value_t)
							OB SET($fields_o; String($fieldNum_i); $fieldKey_t)
							$fieldCount_i:=$fieldCount_i+1
							If ($fieldName_t#"")
								OB SET($record_o; $fieldName_t; $value_t)
							End if
						Else
							$ok_b:=False
						End if
						
					: ($fieldType_i=10)
						If (($offset_i+3)<BLOB size($inBlob_blob))
							$textLen_i:=OTr_x_OTBlobReadInt32LE($inBlob_blob; ->$offset_i)
							If ($textLen_i<0)
								$textLen_i:=0-$textLen_i
							End if
							If (($offset_i+(($textLen_i*2)-1))<BLOB size($inBlob_blob))
								$value_t:=OTr_x_OTBlobReadUTF16LE($inBlob_blob; ->$offset_i; $textLen_i; True)
								OB SET($record_o; $fieldKey_t; $value_t)
								OB SET($fields_o; String($fieldNum_i); $fieldKey_t)
								$fieldCount_i:=$fieldCount_i+1
								If ($fieldName_t#"")
									OB SET($record_o; $fieldName_t; $value_t)
								End if
							Else
								$ok_b:=False
							End if
						Else
							$ok_b:=False
						End if
						
					Else
						$ok_b:=False
				End case
			End if
		End while
		
		If ($ok_b)
			OB SET($record_o; "__fieldCount"; $fieldCount_i)
			$ioOffset_ptr->:=$offset_i
		End if
	End if
End if

If (Not:C34($ok_b))
	$record_o:=Null
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
