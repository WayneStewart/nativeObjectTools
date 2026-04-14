//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_16a_OTBlobValues

// Phase 16a legacy ObjectTools BLOB importer value tests.
// Generates OT BLOBs, imports them through OTr_BLOBToObject, and
// verifies the imported values through public OTr getters.

// PLATFORM REQUIREMENT: ObjectTools 5.0 must be installed as a plugin.
//
// Access: Private
//
// Parameters:
//   $suppressAlert_b : Boolean : True to suppress the final alert
//
// Returns: Nothing
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added Phase 16a value-level OT BLOB tests.
// ----------------------------------------------------

#DECLARE($suppressAlert_b : Boolean)

OTr_z_AddToCallStack(Current method name:C684)

var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t : Text
var $hideAlert_b : Boolean

$StackSize_i:=0
$DesiredProcessName_t:=Current method name:C684

If (Count parameters:C259<1)
	$hideAlert_b:=False:C215
Else
	$hideAlert_b:=$suppressAlert_b
End if

If (Current process name:C1392=$DesiredProcessName_t)
	
	var $otH_i; $childH_i; $otrH_i; $childOTrH_i; $reg_i : Integer
	var $total_i; $passed_i; $failed_i : Integer
	var $caseName_t; $result_t; $summary_t; $report_t; $reportPath_t : Text
	var $legacyBlob_blob; $testBlob_blob; $gotBlob_blob : Blob
	var $testPic_pic; $gotPic_pic : Picture
	var $pass_b : Boolean
	var $real_r; $real1_r; $real2_r; $real3_r : Real
	var $size_i; $arrayType_i; $itemType_i; $long1_i; $long2_i; $long3_i : Integer
	
	ARRAY TEXT:C222($textArray_at; 0)
	ARRAY TEXT:C222($gotTextArray_at; 0)
	ARRAY LONGINT:C221($longArray_ai; 0)
	ARRAY LONGINT:C221($gotLongArray_ai; 0)
	ARRAY REAL:C219($realArray_ar; 0)
	ARRAY REAL:C219($gotRealArray_ar; 0)
	ARRAY BOOLEAN:C223($booleanArray_ab; 0)
	ARRAY BOOLEAN:C223($gotBooleanArray_ab; 0)
	ARRAY DATE:C224($dateArray_ad; 0)
	ARRAY DATE:C224($gotDateArray_ad; 0)
	ARRAY TIME:C1223($timeArray_ah; 0)
	ARRAY TIME:C1223($gotTimeArray_ah; 0)
	
	OTr_ClearAll
	$total_i:=0
	$passed_i:=0
	$failed_i:=0
	$report_t:="Phase 16a OT BLOB value verification"+Char:C90(Carriage return:K15:38)
	$report_t:=$report_t+"Generated legacy OT BLOBs are imported and checked with OTr getters."+Char:C90(Carriage return:K15:38)+Char:C90(Carriage return:K15:38)
	
	$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")
	$otH_i:=OT New
	If ($otH_i=0)
		$summary_t:="Phase 16a OT BLOB Value Tests"+Char:C90(Carriage return:K15:38)+"Skip: ObjectTools 5.0 is not available or not registered."
	Else
		OT Clear($otH_i)
		
		$total_i:=$total_i+1
		$caseName_t:="01 text scalar value"
		$otH_i:=OT New
		OT PutText($otH_i; "text"; "phase16-text")
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		$pass_b:=((OK=1) & ($otrH_i>0) & (OTr_GetText($otrH_i; "text")="phase16-text"))
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetText did not match expected value"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="02 date scalar value"
		$otH_i:=OT New
		OT PutDate($otH_i; "date"; !2026-04-14!)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		$pass_b:=((OK=1) & ($otrH_i>0) & (OTr_GetDate($otrH_i; "date")=!2026-04-14!))
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetDate did not match expected value"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="03 text array values"
		ARRAY TEXT:C222($textArray_at; 3)
		$textArray_at{1}:="alpha"
		$textArray_at{2}:="bravo"
		$textArray_at{3}:="charlie"
		ARRAY TEXT:C222($gotTextArray_at; 0)
		$otH_i:=OT New
		OT PutArray($otH_i; "textArray"; $textArray_at)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			OTr_GetArray($otrH_i; "textArray"; ->$gotTextArray_at)
		End if
		$pass_b:=False:C215
		If ((OK=1) & (Size of array:C274($gotTextArray_at)=3))
			$pass_b:=(($gotTextArray_at{1}="alpha") & ($gotTextArray_at{2}="bravo") & ($gotTextArray_at{3}="charlie"))
		End if
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetArray text values did not match"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="04 long scalar value"
		$otH_i:=OT New
		OT PutLong($otH_i; "long"; 424242)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		$pass_b:=((OK=1) & ($otrH_i>0) & (OTr_GetLong($otrH_i; "long")=424242))
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetLong did not match expected value"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="05 real scalar value"
		$otH_i:=OT New
		OT PutReal($otH_i; "real"; 3.14159)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		$itemType_i:=0
		If ($otrH_i>0)
			$itemType_i:=OTr_ItemType($otrH_i; "real")
		End if
		$real_r:=OTr_GetReal($otrH_i; "real")
		$pass_b:=((OK=1) & ($otrH_i>0) & (Abs:C99($real_r-3.14159)<0.00001))
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetReal did not match expected value; got="+String:C10($real_r)+"; expected=3.14159; itemType="+String:C10($itemType_i)
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="06 boolean scalar value"
		$otH_i:=OT New
		OT PutBoolean($otH_i; "boolean"; Num:C11(True:C214))
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		$pass_b:=((OK=1) & ($otrH_i>0) & (OTr_GetBoolean($otrH_i; "boolean")=1))
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetBoolean did not match expected value"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="07 time scalar value"
		$otH_i:=OT New
		OT PutTime($otH_i; "time"; ?10:30:45?)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		$pass_b:=((OK=1) & ($otrH_i>0) & (OTr_GetTime($otrH_i; "time")=?10:30:45?))
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetTime did not match expected value"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="08 blob scalar value"
		SET BLOB SIZE:C606($testBlob_blob; 4)
		$testBlob_blob{0}:=0
		$testBlob_blob{1}:=65
		$testBlob_blob{2}:=0
		$testBlob_blob{3}:=255
		$otH_i:=OT New
		OT PutBLOB($otH_i; "blob"; $testBlob_blob)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			$gotBlob_blob:=OTr_GetNewBLOB($otrH_i; "blob")
		End if
		$pass_b:=((OK=1) & ($otrH_i>0) & (OTr_u_EqualBLOBs($testBlob_blob; $gotBlob_blob)))
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetNewBLOB did not match expected bytes"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="09 picture scalar png value"
		$testPic_pic:=OTr_z_Wombat
		$otH_i:=OT New
		OT PutPicture($otH_i; "picture"; $testPic_pic)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			$gotPic_pic:=OTr_GetPicture($otrH_i; "picture")
		End if
		$pass_b:=((OK=1) & ($otrH_i>0) & (OTr_u_EqualPictures($testPic_pic; $gotPic_pic)))
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetPicture PNG did not match expected picture"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="10 picture scalar jpg value"
		$testPic_pic:=OTr_z_Echidna
		$otH_i:=OT New
		OT PutPicture($otH_i; "picture"; $testPic_pic)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			$gotPic_pic:=OTr_GetPicture($otrH_i; "picture")
		End if
		$pass_b:=((OK=1) & ($otrH_i>0) & (OTr_u_EqualPictures($testPic_pic; $gotPic_pic)))
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetPicture JPG did not match expected picture"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="11 long array values"
		ARRAY LONGINT:C221($longArray_ai; 3)
		$longArray_ai{1}:=10
		$longArray_ai{2}:=-20
		$longArray_ai{3}:=3000
		ARRAY LONGINT:C221($gotLongArray_ai; 0)
		$otH_i:=OT New
		OT PutArray($otH_i; "longArray"; $longArray_ai)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		$size_i:=0
		$arrayType_i:=0
		$long1_i:=0
		$long2_i:=0
		$long3_i:=0
		If ((OK=1) & ($otrH_i>0))
			$arrayType_i:=OTr_ArrayType($otrH_i; "longArray")
			$size_i:=OTr_SizeOfArray($otrH_i; "longArray")
			$long1_i:=OTr_GetArrayLong($otrH_i; "longArray"; 1)
			$long2_i:=OTr_GetArrayLong($otrH_i; "longArray"; 2)
			$long3_i:=OTr_GetArrayLong($otrH_i; "longArray"; 3)
			OTr_GetArray($otrH_i; "longArray"; ->$gotLongArray_ai)
		End if
		$pass_b:=False:C215
		If ((OK=1) & (Size of array:C274($gotLongArray_ai)=3))
			$pass_b:=(($gotLongArray_ai{1}=10) & ($gotLongArray_ai{2}=-20) & ($gotLongArray_ai{3}=3000))
		End if
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetArray long values did not match; arrayType="+String:C10($arrayType_i)+"; size="+String:C10($size_i)+"; restoredSize="+String:C10(Size of array:C274($gotLongArray_ai))+"; elementGetters="+String:C10($long1_i)+","+String:C10($long2_i)+","+String:C10($long3_i)
			If (Size of array:C274($gotLongArray_ai)>=3)
				$result_t:=$result_t+"; restored="+String:C10($gotLongArray_ai{1})+","+String:C10($gotLongArray_ai{2})+","+String:C10($gotLongArray_ai{3})
			End if
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="12 real array values"
		ARRAY REAL:C219($realArray_ar; 3)
		$realArray_ar{1}:=1.5
		$realArray_ar{2}:=-2.25
		$realArray_ar{3}:=9.75
		ARRAY REAL:C219($gotRealArray_ar; 0)
		$otH_i:=OT New
		OT PutArray($otH_i; "realArray"; $realArray_ar)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		$size_i:=0
		$arrayType_i:=0
		$real1_r:=0
		$real2_r:=0
		$real3_r:=0
		If ((OK=1) & ($otrH_i>0))
			$arrayType_i:=OTr_ArrayType($otrH_i; "realArray")
			$size_i:=OTr_SizeOfArray($otrH_i; "realArray")
			$real1_r:=OTr_GetArrayReal($otrH_i; "realArray"; 1)
			$real2_r:=OTr_GetArrayReal($otrH_i; "realArray"; 2)
			$real3_r:=OTr_GetArrayReal($otrH_i; "realArray"; 3)
			OTr_GetArray($otrH_i; "realArray"; ->$gotRealArray_ar)
		End if
		$pass_b:=False:C215
		If ((OK=1) & (Size of array:C274($gotRealArray_ar)=3))
			$pass_b:=((Abs:C99($gotRealArray_ar{1}-1.5)<0.00001) & (Abs:C99($gotRealArray_ar{2}+2.25)<0.00001) & (Abs:C99($gotRealArray_ar{3}-9.75)<0.00001))
		End if
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetArray real values did not match; arrayType="+String:C10($arrayType_i)+"; size="+String:C10($size_i)+"; restoredSize="+String:C10(Size of array:C274($gotRealArray_ar))+"; elementGetters="+String:C10($real1_r)+","+String:C10($real2_r)+","+String:C10($real3_r)
			If (Size of array:C274($gotRealArray_ar)>=3)
				$result_t:=$result_t+"; restored="+String:C10($gotRealArray_ar{1})+","+String:C10($gotRealArray_ar{2})+","+String:C10($gotRealArray_ar{3})
			End if
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="13 boolean array values"
		ARRAY BOOLEAN:C223($booleanArray_ab; 3)
		$booleanArray_ab{1}:=True:C214
		$booleanArray_ab{2}:=False:C215
		$booleanArray_ab{3}:=True:C214
		ARRAY BOOLEAN:C223($gotBooleanArray_ab; 0)
		$otH_i:=OT New
		OT PutArray($otH_i; "booleanArray"; $booleanArray_ab)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			OTr_GetArray($otrH_i; "booleanArray"; ->$gotBooleanArray_ab)
		End if
		$pass_b:=False:C215
		If ((OK=1) & (Size of array:C274($gotBooleanArray_ab)=3))
			$pass_b:=(($gotBooleanArray_ab{1}=True:C214) & ($gotBooleanArray_ab{2}=False:C215) & ($gotBooleanArray_ab{3}=True:C214))
		End if
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetArray boolean values did not match"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="14 date array values"
		ARRAY DATE:C224($dateArray_ad; 3)
		$dateArray_ad{1}:=!2026-04-14!
		$dateArray_ad{2}:=!1863-06-22!
		$dateArray_ad{3}:=!2030-12-31!
		ARRAY DATE:C224($gotDateArray_ad; 0)
		$otH_i:=OT New
		OT PutArray($otH_i; "dateArray"; $dateArray_ad)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			OTr_GetArray($otrH_i; "dateArray"; ->$gotDateArray_ad)
		End if
		$pass_b:=False:C215
		If ((OK=1) & (Size of array:C274($gotDateArray_ad)=3))
			$pass_b:=(($gotDateArray_ad{1}=!2026-04-14!) & ($gotDateArray_ad{2}=!1863-06-22!) & ($gotDateArray_ad{3}=!2030-12-31!))
		End if
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetArray date values did not match"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="15 time array values"
		ARRAY TIME:C1223($timeArray_ah; 3)
		$timeArray_ah{1}:=?00:00:00?
		$timeArray_ah{2}:=?10:30:45?
		$timeArray_ah{3}:=?23:59:58?
		ARRAY TIME:C1223($gotTimeArray_ah; 0)
		$otH_i:=OT New
		OT PutArray($otH_i; "timeArray"; $timeArray_ah)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			OTr_GetArray($otrH_i; "timeArray"; ->$gotTimeArray_ah)
		End if
		$pass_b:=False:C215
		If ((OK=1) & (Size of array:C274($gotTimeArray_ah)=3))
			$pass_b:=(($gotTimeArray_ah{1}=?00:00:00?) & ($gotTimeArray_ah{2}=?10:30:45?) & ($gotTimeArray_ah{3}=?23:59:58?))
		End if
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: OTr_GetArray time values did not match"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="16 embedded object text value"
		$otH_i:=OT New
		$childH_i:=OT New
		OT PutText($childH_i; "text"; "embedded-text")
		OT PutObject($otH_i; "embeddedObject"; $childH_i)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($childH_i)
		OT Clear($otH_i)
		$childOTrH_i:=0
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			$childOTrH_i:=OTr_GetObject($otrH_i; "embeddedObject")
		End if
		$pass_b:=False:C215
		If ((OK=1) & ($childOTrH_i>0))
			$pass_b:=(OTr_GetText($childOTrH_i; "text")="embedded-text")
		End if
		If ($childOTrH_i>0)
			OTr_Clear($childOTrH_i)
		End if
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: embedded OTr_GetObject/OTr_GetText did not match"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="17 embedded object text array values"
		ARRAY TEXT:C222($textArray_at; 2)
		$textArray_at{1}:="child-alpha"
		$textArray_at{2}:="child-bravo"
		ARRAY TEXT:C222($gotTextArray_at; 0)
		$otH_i:=OT New
		$childH_i:=OT New
		OT PutArray($childH_i; "textArray"; $textArray_at)
		OT PutObject($otH_i; "embeddedObject"; $childH_i)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($childH_i)
		OT Clear($otH_i)
		$childOTrH_i:=0
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			$childOTrH_i:=OTr_GetObject($otrH_i; "embeddedObject")
			If ($childOTrH_i>0)
				OTr_GetArray($childOTrH_i; "textArray"; ->$gotTextArray_at)
			End if
		End if
		$pass_b:=False:C215
		If ((OK=1) & ($childOTrH_i>0) & (Size of array:C274($gotTextArray_at)=2))
			$pass_b:=(($gotTextArray_at{1}="child-alpha") & ($gotTextArray_at{2}="child-bravo"))
		End if
		If ($childOTrH_i>0)
			OTr_Clear($childOTrH_i)
		End if
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: embedded OTr_GetArray text values did not match"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="18 mixed object values"
		ARRAY TEXT:C222($textArray_at; 2)
		$textArray_at{1}:="mix-alpha"
		$textArray_at{2}:="mix-bravo"
		ARRAY LONGINT:C221($longArray_ai; 2)
		$longArray_ai{1}:=100
		$longArray_ai{2}:=200
		ARRAY TEXT:C222($gotTextArray_at; 0)
		ARRAY LONGINT:C221($gotLongArray_ai; 0)
		$otH_i:=OT New
		$childH_i:=OT New
		OT PutText($otH_i; "text"; "mixed")
		OT PutLong($otH_i; "long"; 42)
		OT PutArray($otH_i; "textArray"; $textArray_at)
		OT PutArray($otH_i; "longArray"; $longArray_ai)
		OT PutText($childH_i; "text"; "child")
		OT PutObject($otH_i; "embeddedObject"; $childH_i)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($childH_i)
		OT Clear($otH_i)
		$childOTrH_i:=0
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		If ((OK=1) & ($otrH_i>0))
			OTr_GetArray($otrH_i; "textArray"; ->$gotTextArray_at)
			OTr_GetArray($otrH_i; "longArray"; ->$gotLongArray_ai)
			$childOTrH_i:=OTr_GetObject($otrH_i; "embeddedObject")
		End if
		$pass_b:=False:C215
		If ((OK=1) & ($otrH_i>0) & ($childOTrH_i>0) & (Size of array:C274($gotTextArray_at)=2) & (Size of array:C274($gotLongArray_ai)=2))
			$pass_b:=((OTr_GetText($otrH_i; "text")="mixed") & (OTr_GetLong($otrH_i; "long")=42) & ($gotTextArray_at{1}="mix-alpha") & ($gotTextArray_at{2}="mix-bravo") & ($gotLongArray_ai{1}=100) & ($gotLongArray_ai{2}=200) & (OTr_GetText($childOTrH_i; "text")="child"))
		End if
		If ($childOTrH_i>0)
			OTr_Clear($childOTrH_i)
		End if
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass"
		Else
			$failed_i:=$failed_i+1
			$result_t:="Fail: mixed object getter values did not match"
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$summary_t:="Phase 16a OT BLOB Value Tests"+Char:C90(Carriage return:K15:38)
		$summary_t:=$summary_t+"Total:  "+String:C10($total_i)+Char:C90(Carriage return:K15:38)
		$summary_t:=$summary_t+"Passed: "+String:C10($passed_i)+Char:C90(Carriage return:K15:38)
		$summary_t:=$summary_t+"Failed: "+String:C10($failed_i)
	End if
	
	$report_t:=$report_t+Char:C90(Carriage return:K15:38)+$summary_t
	$reportPath_t:=Get 4D folder:C485(Logs folder:K5:19)+"____Test_Phase_16a_OTBlobValues.txt"
	TEXT TO DOCUMENT:C1237($reportPath_t; $report_t; "UTF-8")
	
	If ($hideAlert_b)
	Else
		ALERT:C41($summary_t+Char:C90(Carriage return:K15:38)+"Report written to: "+$reportPath_t)
		SET TEXT TO PASTEBOARD:C523($report_t)
	End if
	
Else
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; $hideAlert_b; *)
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
