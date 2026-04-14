//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_16_OTBlob

// Phase 16 legacy ObjectTools BLOB importer discovery tests.
// Generates OT object BLOBs with one payload family per case, imports
// them through OTr_BLOBToObject, and writes raw BLOBs plus marker
// diagnostics for unsupported payload layouts.

// PLATFORM REQUIREMENT: ObjectTools 5.0 must be installed as a plugin.

#DECLARE($suppressAlert_b : Boolean)

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
	
	var $otH_i; $childH_i; $reg_i : Integer
	var $total_i; $passed_i; $failed_i : Integer
	var $caseName_t; $result_t; $summary_t; $report_t; $reportPath_t : Text
	var $legacyBlob_blob; $testBlob_blob : Blob
	var $testPic_pic : Picture
	
	ARRAY TEXT:C222($textArray_at; 0)
	ARRAY LONGINT:C221($longArray_ai; 0)
	ARRAY REAL:C219($realArray_ar; 0)
	ARRAY BOOLEAN:C223($booleanArray_ab; 0)
	ARRAY DATE:C224($dateArray_ad; 0)
	ARRAY TIME:C1223($timeArray_ah; 0)
	
	OTr_ClearAll
	$total_i:=0
	$passed_i:=0
	$failed_i:=0
	$report_t:="Phase 16 OT BLOB compatibility discovery"+Char:C90(Carriage return:K15:38)
	$report_t:=$report_t+"Raw generated BLOBs are written to the 4D Logs folder."+Char:C90(Carriage return:K15:38)+Char:C90(Carriage return:K15:38)
	
	$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")
	$otH_i:=OT New
	If ($otH_i=0)
		$summary_t:="Phase 16 OT BLOB Tests"+Char:C90(Carriage return:K15:38)+"Skip: ObjectTools 5.0 is not available or not registered."
	Else
		OT Clear($otH_i)
		
		// ====================================================
		//MARK:- Baseline supported payloads
		// ====================================================
		$total_i:=$total_i+1
		$caseName_t:="01 text scalar"
		$otH_i:=OT New
		OT PutText($otH_i; "text"; "phase16-text")
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="02 date scalar"
		$otH_i:=OT New
		OT PutDate($otH_i; "date"; !2026-04-14!)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="03 text array"
		ARRAY TEXT:C222($textArray_at; 3)
		$textArray_at{1}:="alpha"
		$textArray_at{2}:="bravo"
		$textArray_at{3}:="charlie"
		$otH_i:=OT New
		OT PutArray($otH_i; "textArray"; $textArray_at)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		// ====================================================
		//MARK:- Additional scalar payloads
		// ====================================================
		$total_i:=$total_i+1
		$caseName_t:="04 long scalar"
		$otH_i:=OT New
		OT PutLong($otH_i; "long"; 424242)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="05 real scalar"
		$otH_i:=OT New
		OT PutReal($otH_i; "real"; 3.14159)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="06 boolean scalar"
		$otH_i:=OT New
		OT PutBoolean($otH_i; "boolean"; Num:C11(True:C214))
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="07 time scalar"
		$otH_i:=OT New
		OT PutTime($otH_i; "time"; ?10:30:45?)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		// ====================================================
		//MARK:- Binary and media payloads
		// ====================================================
		$total_i:=$total_i+1
		$caseName_t:="08 blob scalar"
		SET BLOB SIZE:C606($testBlob_blob; 4)
		$testBlob_blob{0}:=0
		$testBlob_blob{1}:=65
		$testBlob_blob{2}:=0
		$testBlob_blob{3}:=255
		$otH_i:=OT New
		OT PutBLOB($otH_i; "blob"; $testBlob_blob)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="09 picture scalar png"
		$testPic_pic:=OTr_z_Wombat
		$otH_i:=OT New
		OT PutPicture($otH_i; "picture"; $testPic_pic)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)

		$total_i:=$total_i+1
		$caseName_t:="10 picture scalar jpg"
		$testPic_pic:=OTr_z_Echidna
		$otH_i:=OT New
		OT PutPicture($otH_i; "picture"; $testPic_pic)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		// ====================================================
		//MARK:- Additional array payloads
		// ====================================================
		$total_i:=$total_i+1
		$caseName_t:="11 long array"
		ARRAY LONGINT:C221($longArray_ai; 3)
		$longArray_ai{1}:=10
		$longArray_ai{2}:=-20
		$longArray_ai{3}:=3000
		$otH_i:=OT New
		OT PutArray($otH_i; "longArray"; $longArray_ai)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="12 real array"
		ARRAY REAL:C219($realArray_ar; 3)
		$realArray_ar{1}:=1.5
		$realArray_ar{2}:=-2.25
		$realArray_ar{3}:=9.75
		$otH_i:=OT New
		OT PutArray($otH_i; "realArray"; $realArray_ar)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="13 boolean array"
		ARRAY BOOLEAN:C223($booleanArray_ab; 3)
		$booleanArray_ab{1}:=True:C214
		$booleanArray_ab{2}:=False:C215
		$booleanArray_ab{3}:=True:C214
		$otH_i:=OT New
		OT PutArray($otH_i; "booleanArray"; $booleanArray_ab)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="14 date array"
		ARRAY DATE:C224($dateArray_ad; 3)
		$dateArray_ad{1}:=!2026-04-14!
		$dateArray_ad{2}:=!1863-06-22!
		$dateArray_ad{3}:=!2030-12-31!
		$otH_i:=OT New
		OT PutArray($otH_i; "dateArray"; $dateArray_ad)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="15 time array"
		ARRAY TIME:C1223($timeArray_ah; 3)
		$timeArray_ah{1}:=?00:00:00?
		$timeArray_ah{2}:=?10:30:45?
		$timeArray_ah{3}:=?23:59:58?
		$otH_i:=OT New
		OT PutArray($otH_i; "timeArray"; $timeArray_ah)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		// ====================================================
		//MARK:- Embedded object payloads
		// ====================================================
		$total_i:=$total_i+1
		$caseName_t:="16 embedded object text"
		$otH_i:=OT New
		$childH_i:=OT New
		OT PutText($childH_i; "text"; "embedded-text")
		OT PutObject($otH_i; "embeddedObject"; $childH_i)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($childH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$total_i:=$total_i+1
		$caseName_t:="17 embedded object text array"
		ARRAY TEXT:C222($textArray_at; 2)
		$textArray_at{1}:="child-alpha"
		$textArray_at{2}:="child-bravo"
		$otH_i:=OT New
		$childH_i:=OT New
		OT PutArray($childH_i; "textArray"; $textArray_at)
		OT PutObject($otH_i; "embeddedObject"; $childH_i)
		$legacyBlob_blob:=OT ObjectToNewBLOB($otH_i)
		OT Clear($childH_i)
		OT Clear($otH_i)
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		// ====================================================
		//MARK:- Mixed object ordering smoke test
		// ====================================================
		$total_i:=$total_i+1
		$caseName_t:="18 mixed scalar array embedded"
		ARRAY TEXT:C222($textArray_at; 2)
		$textArray_at{1}:="mix-alpha"
		$textArray_at{2}:="mix-bravo"
		ARRAY LONGINT:C221($longArray_ai; 2)
		$longArray_ai{1}:=100
		$longArray_ai{2}:=200
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
		$result_t:=____Test_Phase_16_OTBlob_Probe($legacyBlob_blob; $caseName_t)
		If (Substring:C12($result_t; 1; 4)="Pass")
			$passed_i:=$passed_i+1
		Else
			$failed_i:=$failed_i+1
		End if
		$report_t:=$report_t+$caseName_t+": "+$result_t+Char:C90(Carriage return:K15:38)
		
		$summary_t:="Phase 16 OT BLOB Tests"+Char:C90(Carriage return:K15:38)
		$summary_t:=$summary_t+"Total:  "+String:C10($total_i)+Char:C90(Carriage return:K15:38)
		$summary_t:=$summary_t+"Passed: "+String:C10($passed_i)+Char:C90(Carriage return:K15:38)
		$summary_t:=$summary_t+"Failed: "+String:C10($failed_i)
	End if
	
	$report_t:=$report_t+Char:C90(Carriage return:K15:38)+$summary_t
	$reportPath_t:=Get 4D folder:C485(Logs folder:K5:19)+"____Test_Phase_16_OTBlob.txt"
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
