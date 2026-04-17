//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_16b_OTBlobDeep

// Phase 16b legacy ObjectTools BLOB deep embedded-object tests.
// Generates multi-level OT object graphs, imports them through
// OTr_BLOBToObject, and verifies dotted-path access from the root.

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
// Wayne Stewart / Codex, 2026-04-14 - Added Phase 16b deep embedded object and DOCX BLOB tests.
// ----------------------------------------------------

#DECLARE($suppressAlert_b : Boolean)

// ==== BEGIN OT BLOCK — comment out on Tahoe 26.4+ ====
/*


OTr_z_AddToCallStack(Current method name)

var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t : Text
var $hideAlert_b : Boolean

$StackSize_i:=0
$DesiredProcessName_t:=Current method name

If (Count parameters<1)
	$hideAlert_b:=False
Else 
	$hideAlert_b:=$suppressAlert_b
End if 

If (Current process name=$DesiredProcessName_t)
	
	var $rootOT_i; $level1OT_i; $level2OT_i; $level3OT_i; $siblingOT_i : Integer
	var $otrH_i; $roundTripH_i; $reg_i : Integer
	var $total_i; $passed_i; $failed_i : Integer
	var $caseName_t; $result_t; $summary_t; $report_t; $reportPath_t; $marker_t : Text
	var $rawPath_t : Text
	var $docPath_t; $desktopDocPath_t : Text
	var $legacyBlob_blob; $otrBlob_blob; $testBlob_blob; $gotBlob_blob : Blob
	var $docBlob_blob; $gotDocBlob_blob : Blob
	var $testPic_pic; $gotPic_pic : Picture
	var $pass_b : Boolean
	var $real_r : Real
	
	ARRAY TEXT($textArray_at; 0)
	ARRAY TEXT($gotTextArray_at; 0)
	ARRAY LONGINT($longArray_ai; 0)
	ARRAY LONGINT($gotLongArray_ai; 0)
	ARRAY BOOLEAN($booleanArray_ab; 0)
	ARRAY BOOLEAN($gotBooleanArray_ab; 0)
	
	OTr_ClearAll
	$total_i:=0
	$passed_i:=0
	$failed_i:=0
	$report_t:="Phase 16b OT BLOB deep embedded-object verification"+Char(Carriage return)
	$report_t:=$report_t+"Generated legacy OT BLOBs are imported and checked with dotted-path OTr getters."+Char(Carriage return)+Char(Carriage return)
	
	$reg_i:=OT Register(Storage.OTr.registrationCode)
	$rootOT_i:=OT New
	If ($rootOT_i=0)
		$summary_t:="Phase 16b OT BLOB Deep Object Tests"+Char(Carriage return)+"Skip: ObjectTools 5.0 is not available or not registered."
	Else 
		OT Clear($rootOT_i)
		
		// ====================================================
		//MARK:- Three-level mixed object
		// ====================================================
		$total_i:=$total_i+1
		$caseName_t:="01 three-level mixed object dotted values"
		
		ARRAY TEXT($textArray_at; 3)
		$textArray_at{1}:="deep-alpha"
		$textArray_at{2}:="deep-bravo"
		$textArray_at{3}:="deep-charlie"
		ARRAY LONGINT($longArray_ai; 3)
		$longArray_ai{1}:=10
		$longArray_ai{2}:=-20
		$longArray_ai{3}:=3000
		ARRAY BOOLEAN($booleanArray_ab; 3)
		$booleanArray_ab{1}:=True
		$booleanArray_ab{2}:=False
		$booleanArray_ab{3}:=True
		SET BLOB SIZE($testBlob_blob; 5)
		$testBlob_blob{0}:=1
		$testBlob_blob{1}:=2
		$testBlob_blob{2}:=0
		$testBlob_blob{3}:=255
		$testBlob_blob{4}:=42
		$docPath_t:=Get 4D folder(Current resources folder)+"1 Corinthians 1.docx"
		DOCUMENT TO BLOB($docPath_t; $docBlob_blob)
		$testPic_pic:=OTr_z_Echidna
		
		$rootOT_i:=OT New
		$level1OT_i:=OT New
		$level2OT_i:=OT New
		$level3OT_i:=OT New
		OT PutText($rootOT_i; "rootText"; "root")
		OT PutText($level1OT_i; "level1Text"; "level1")
		OT PutLong($level2OT_i; "level2Long"; -12345)
		OT PutText($level3OT_i; "Citem"; "deep text")
		OT PutReal($level3OT_i; "amount"; 123.456)
		OT PutBoolean($level3OT_i; "flag"; Num(True))
		OT PutDate($level3OT_i; "when"; !2026-04-14!)
		OT PutTime($level3OT_i; "clock"; ?12:34:56?)
		OT PutBLOB($level3OT_i; "data"; $testBlob_blob)
		OT PutBLOB($level3OT_i; "document"; $docBlob_blob)
		OT PutPicture($level3OT_i; "photo"; $testPic_pic)
		OT PutArray($level3OT_i; "names"; $textArray_at)
		OT PutArray($level3OT_i; "numbers"; $longArray_ai)
		OT PutArray($level3OT_i; "flags"; $booleanArray_ab)
		OT PutObject($level2OT_i; "cObject"; $level3OT_i)
		OT PutObject($level1OT_i; "bObject"; $level2OT_i)
		OT PutObject($rootOT_i; "AnObject"; $level1OT_i)
		$legacyBlob_blob:=OT ObjectToNewBLOB($rootOT_i)
		$rawPath_t:=Get 4D folder(Logs folder; *)+"Phase16b-OTBlob-01_deep_mixed_docx.blob"
		BLOB TO DOCUMENT($rawPath_t; $legacyBlob_blob)
		OT Clear($level3OT_i)
		OT Clear($level2OT_i)
		OT Clear($level1OT_i)
		OT Clear($rootOT_i)
		
		$marker_t:=OTr_z_OTBlobDescribeFirstItem($legacyBlob_blob)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		ARRAY TEXT($gotTextArray_at; 0)
		ARRAY LONGINT($gotLongArray_ai; 0)
		ARRAY BOOLEAN($gotBooleanArray_ab; 0)
		If ((OK=1) & ($otrH_i>0))
			OTr_GetArray($otrH_i; "AnObject.bObject.cObject.names"; ->$gotTextArray_at)
			OTr_GetArray($otrH_i; "AnObject.bObject.cObject.numbers"; ->$gotLongArray_ai)
			OTr_GetArray($otrH_i; "AnObject.bObject.cObject.flags"; ->$gotBooleanArray_ab)
			$gotBlob_blob:=OTr_GetNewBLOB($otrH_i; "AnObject.bObject.cObject.data")
			$gotDocBlob_blob:=OTr_GetNewBLOB($otrH_i; "AnObject.bObject.cObject.document")
			$gotPic_pic:=OTr_GetPicture($otrH_i; "AnObject.bObject.cObject.photo")
			$real_r:=OTr_GetReal($otrH_i; "AnObject.bObject.cObject.amount")
		End if 
		
		$pass_b:=False
		$pass_b:=((OK=1) & ($otrH_i>0))
		If ($pass_b)
			$pass_b:=(OTr_IsEmbedded($otrH_i; "AnObject")=1)
		End if 
		If ($pass_b)
			$pass_b:=(OTr_IsEmbedded($otrH_i; "AnObject.bObject")=1)
		End if 
		If ($pass_b)
			$pass_b:=(OTr_IsEmbedded($otrH_i; "AnObject.bObject.cObject")=1)
		End if 
		If ($pass_b)
			$pass_b:=(OTr_ItemCount($otrH_i; "AnObject.bObject.cObject")=11)
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetText($otrH_i; "AnObject.level1Text")="level1")
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetLong($otrH_i; "AnObject.bObject.level2Long")=-12345)
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetText($otrH_i; "AnObject.bObject.cObject.Citem")="deep text")
		End if 
		If ($pass_b)
			$pass_b:=(Abs($real_r-123.456)<0.00001)
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetBoolean($otrH_i; "AnObject.bObject.cObject.flag")=1)
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetDate($otrH_i; "AnObject.bObject.cObject.when")=!2026-04-14!)
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetTime($otrH_i; "AnObject.bObject.cObject.clock")=?12:34:56?)
		End if 
		If ($pass_b)
			$pass_b:=OTr_u_EqualBLOBs($testBlob_blob; $gotBlob_blob)
		End if 
		If ($pass_b)
			$pass_b:=OTr_u_EqualBLOBs($docBlob_blob; $gotDocBlob_blob)
		End if 
		If ($pass_b)
			$pass_b:=OTr_u_EqualPictures($testPic_pic; $gotPic_pic)
		End if 
		If ($pass_b)
			$pass_b:=((Size of array($gotTextArray_at)=3) & (Size of array($gotLongArray_ai)=3) & (Size of array($gotBooleanArray_ab)=3))
		End if 
		If ($pass_b)
			$pass_b:=(($gotTextArray_at{1}="deep-alpha") & ($gotTextArray_at{2}="deep-bravo") & ($gotTextArray_at{3}="deep-charlie"))
		End if 
		If ($pass_b)
			$pass_b:=(($gotLongArray_ai{1}=10) & ($gotLongArray_ai{2}=-20) & ($gotLongArray_ai{3}=3000))
		End if 
		If ($pass_b)
			$pass_b:=(($gotBooleanArray_ab{1}=True) & ($gotBooleanArray_ab{2}=False) & ($gotBooleanArray_ab{3}=True))
		End if 
		
		If ($pass_b)
			$otrBlob_blob:=OTr_ObjectToNewBLOB($otrH_i)
			$roundTripH_i:=OTr_BLOBToObject($otrBlob_blob)
			$pass_b:=((OK=1) & ($roundTripH_i>0) & (OTr_GetText($roundTripH_i; "AnObject.bObject.cObject.Citem")="deep text") & (OTr_GetArrayLong($roundTripH_i; "AnObject.bObject.cObject.numbers"; 2)=-20) & (OTr_u_EqualBLOBs($docBlob_blob; OTr_GetNewBLOB($roundTripH_i; "AnObject.bObject.cObject.document"))))
			If ($roundTripH_i>0)
				OTr_Clear($roundTripH_i)
			End if 
		End if 
		If ($pass_b)
			$desktopDocPath_t:=System folder(Desktop)+"Phase16b-Extracted-1-Corinthians-1.docx"
			BLOB TO DOCUMENT($desktopDocPath_t; $gotDocBlob_blob)
			$pass_b:=(OK=1)
		End if 
		
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if 
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass: dotted getters, embedded counts, arrays, media, DOCX extraction, and OTr round-trip succeeded; docxBytes="+String(BLOB size($gotDocBlob_blob))+"; saved="+$desktopDocPath_t+"; "+$marker_t
		Else 
			$failed_i:=$failed_i+1
			$result_t:="Fail: deep dotted-path values did not match; sourceDocxBytes="+String(BLOB size($docBlob_blob))+"; importedDocxBytes="+String(BLOB size($gotDocBlob_blob))+"; raw="+$rawPath_t+"; "+$marker_t
		End if 
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char(Carriage return)
		
		// ====================================================
		//MARK:- Sibling nested object ordering
		// ====================================================
		$total_i:=$total_i+1
		$caseName_t:="02 sibling deep objects and ordering"
		
		ARRAY TEXT($textArray_at; 2)
		$textArray_at{1}:="left-one"
		$textArray_at{2}:="left-two"
		ARRAY LONGINT($longArray_ai; 2)
		$longArray_ai{1}:=-1
		$longArray_ai{2}:=-2
		
		$rootOT_i:=OT New
		$level1OT_i:=OT New
		$level2OT_i:=OT New
		$level3OT_i:=OT New
		$siblingOT_i:=OT New
		OT PutText($rootOT_i; "before"; "before-value")
		OT PutArray($level1OT_i; "leftNames"; $textArray_at)
		OT PutText($level2OT_i; "middle"; "middle-value")
		OT PutArray($level3OT_i; "negativeNumbers"; $longArray_ai)
		OT PutText($level3OT_i; "leaf"; "leaf-value")
		OT PutObject($level2OT_i; "third"; $level3OT_i)
		OT PutObject($level1OT_i; "second"; $level2OT_i)
		OT PutObject($rootOT_i; "first"; $level1OT_i)
		OT PutText($siblingOT_i; "siblingText"; "sibling-value")
		OT PutLong($siblingOT_i; "siblingLong"; 777)
		OT PutObject($rootOT_i; "sibling"; $siblingOT_i)
		OT PutText($rootOT_i; "after"; "after-value")
		$legacyBlob_blob:=OT ObjectToNewBLOB($rootOT_i)
		$rawPath_t:=Get 4D folder(Logs folder; *)+"Phase16b-OTBlob-02_sibling_deep_ordering.blob"
		BLOB TO DOCUMENT($rawPath_t; $legacyBlob_blob)
		OT Clear($siblingOT_i)
		OT Clear($level3OT_i)
		OT Clear($level2OT_i)
		OT Clear($level1OT_i)
		OT Clear($rootOT_i)
		
		$marker_t:=OTr_z_OTBlobDescribeFirstItem($legacyBlob_blob)
		$otrH_i:=OTr_BLOBToObject($legacyBlob_blob)
		ARRAY TEXT($gotTextArray_at; 0)
		ARRAY LONGINT($gotLongArray_ai; 0)
		If ((OK=1) & ($otrH_i>0))
			OTr_GetArray($otrH_i; "first.leftNames"; ->$gotTextArray_at)
			OTr_GetArray($otrH_i; "first.second.third.negativeNumbers"; ->$gotLongArray_ai)
		End if 
		
		$pass_b:=False
		$pass_b:=((OK=1) & ($otrH_i>0))
		If ($pass_b)
			$pass_b:=(OTr_ItemCount($otrH_i)=4)
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetText($otrH_i; "before")="before-value")
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetText($otrH_i; "after")="after-value")
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetText($otrH_i; "first.second.middle")="middle-value")
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetText($otrH_i; "first.second.third.leaf")="leaf-value")
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetText($otrH_i; "sibling.siblingText")="sibling-value")
		End if 
		If ($pass_b)
			$pass_b:=(OTr_GetLong($otrH_i; "sibling.siblingLong")=777)
		End if 
		If ($pass_b)
			$pass_b:=((Size of array($gotTextArray_at)=2) & (Size of array($gotLongArray_ai)=2))
		End if 
		If ($pass_b)
			$pass_b:=(($gotTextArray_at{1}="left-one") & ($gotTextArray_at{2}="left-two"))
		End if 
		If ($pass_b)
			$pass_b:=(($gotLongArray_ai{1}=-1) & ($gotLongArray_ai{2}=-2))
		End if 
		
		If ($otrH_i>0)
			OTr_Clear($otrH_i)
		End if 
		If ($pass_b)
			$passed_i:=$passed_i+1
			$result_t:="Pass: sibling ordering and three-level dotted getters succeeded; "+$marker_t
		Else 
			$failed_i:=$failed_i+1
			$result_t:="Fail: sibling deep-object values did not match; "+$marker_t
		End if 
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char(Carriage return)
		
		$summary_t:="Phase 16b OT BLOB Deep Object Tests"+Char(Carriage return)
		$summary_t:=$summary_t+"Total:  "+String($total_i)+Char(Carriage return)
		$summary_t:=$summary_t+"Passed: "+String($passed_i)+Char(Carriage return)
		$summary_t:=$summary_t+"Failed: "+String($failed_i)
	End if 
	
	$report_t:=$report_t+Char(Carriage return)+$summary_t
	$reportPath_t:=Get 4D folder(Logs folder; *)+"____Test_Phase_16b_OTBlobDeep.txt"
	TEXT TO DOCUMENT($reportPath_t; $report_t; "UTF-8")
	
	If ($hideAlert_b)
	Else 
		ALERT($summary_t+Char(Carriage return)+"Report written to: "+$reportPath_t)
		SET TEXT TO PASTEBOARD($report_t)
	End if 
	
Else 
	$ProcessID_i:=New process(Current method name; $StackSize_i; $DesiredProcessName_t; $hideAlert_b; *)
	RESUME PROCESS($ProcessID_i)
	SHOW PROCESS($ProcessID_i)
	BRING TO FRONT($ProcessID_i)
End if 

OTr_z_RemoveFromCallStack(Current method name)

*/
// ==== END OT BLOCK ====
