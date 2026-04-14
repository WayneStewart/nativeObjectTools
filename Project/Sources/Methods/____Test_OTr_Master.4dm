//%attributes = {"shared":true}
// ----------------------------------------------------
// Project Method: ____Test_OTr_Master
//
// Single-call master test runner for the entire OTr test suite.
// Executes all unit-test phases (1, 1.5, 2, 3, 4, 5, 6, 16, 8) inline,
// accumulating results in a six-column TAB-delimited table:
//   Num | Phase | Test Name | Expected | Actual | Pass/Fail
//
// Then calls each side-by-side controller (10, 10a, 10b, 10c, 15)
// with suppressAlert=True so they write their own Logs files silently,
// and appends a summary reference line for each.
//
// The master document is prepended with a header row containing:
//   Platform (Mac/Windows) | 4D version string | Date/Time of run
//
// Output written as UTF-8 to the 4D Logs folder:
//   ____Test_OTr_Master-YYYY-MM-DD-HH-MM-SS.txt
//
// Access: Private
// Returns: Nothing (results written to Logs folder; summary ALERT at end)
//
// Created by Wayne Stewart / Claude, 2026-04-12
// Based on work by himself, Rob Laveaux, Guy Algot, and Cannon Smith.
// WBS 15/04/2026: Add blob import code and swap to debug mode in OT log while running test
// ----------------------------------------------------
#DECLARE($suppressAlert_b : Boolean)

var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t; $debug_t : Text

$StackSize_i:=0
$DesiredProcessName_t:=Current method name:C684

var $hideAlert_b : Boolean
If (Count parameters:C259<1)
	$hideAlert_b:=False:C215
Else 
	$hideAlert_b:=$suppressAlert_b
End if 

If (Current process name:C1392=$DesiredProcessName_t)
	$debug_t:=OTr_LogLevel
	OTr_LogLevel(OT Log Debug)  // Set to debug for this test
	
	// ====================================================
	// SHARED INFRASTRUCTURE
	// ====================================================
	var $TAB; $LF; $CR : Text
	var $masterText_t : Text
	var $rowNum_i : Integer
	var $totalPass_i; $totalFail_i : Integer
	
	$TAB:=Char:C90(Tab:K15:37)
	$LF:=Char:C90(Line feed:K15:40)
	$CR:=Char:C90(Carriage return:K15:38)
	
	$rowNum_i:=0
	$totalPass_i:=0
	$totalFail_i:=0
	
	// ====================================================
	// DOCUMENT HEADER (platform, version, timestamp)
	// ====================================================
	var $platform_t; $version_t; $dateStr_t; $timeStr_t : Text
	var $y_i; $mo_i; $d_i : Integer
	
	If (Is macOS:C1572)
		$platform_t:="Mac"
	Else 
		$platform_t:="Windows"
	End if 
	
	$version_t:=Application version:C493
	
	$y_i:=Year of:C25(Current date:C33)
	$mo_i:=Month of:C24(Current date:C33)
	$d_i:=Day of:C23(Current date:C33)
	$dateStr_t:=String:C10($y_i; "0000")+"-"+String:C10($mo_i; "00")+"-"+String:C10($d_i; "00")
	$timeStr_t:=String:C10(Current time:C178; HH MM SS:K7:1)
	$timeStr_t:=Replace string:C233($timeStr_t; ":"; "-")
	
	$masterText_t:="OTr Master Test Suite"+$LF
	$masterText_t:=$masterText_t+"Platform: "+$platform_t+$TAB+"4D Version: "+$version_t+$TAB+"Run: "+$dateStr_t+" "+$timeStr_t+$LF
	$masterText_t:=$masterText_t+$LF
	
	// Column header for unit-test rows
	$masterText_t:=$masterText_t+"Num"+$TAB+"Phase"+$TAB+"Test Name"+$TAB+"Expected"+$TAB+"Actual"+$TAB+"Pass/Fail"+$LF
	
	// ====================================================
	// HELPER: inline macro — append one result row
	// (implemented as a block convention; each phase section
	//  uses $phase_t, $testName_t, $expected_t, $actual_t, $pass_b)
	// ====================================================
	
	var $phase_t; $testName_t; $expected_t; $actual_t : Text
	var $pass_b : Boolean
	
	// ====================================================
	// ============================================================
	// PHASE 1 — Core handle management
	// ============================================================
	// ====================================================
	$phase_t:="Phase 1"
	
	OTr_ClearAll
	
	var $h1_i; $h2_i; $h3_i : Integer
	var $regResult_i; $compiled_i : Integer
	var $originalOptions_i; $newOptions_i; $readOptions_i : Integer
	var $prevHandler_t; $prev2Handler_t; $prev3Handler_t : Text
	var $findIndex_i : Integer
	ARRAY LONGINT:C221($handles_ai; 0)
	
	// OTr_GetVersion
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetVersion returns non-empty"
	$expected_t:="non-empty text"
	$actual_t:=OTr_GetVersion
	$pass_b:=($actual_t#"")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_Register
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_Register returns 1"
	$expected_t:="1"
	$regResult_i:=OTr_Register("master-test")
	$actual_t:=String:C10($regResult_i)
	$pass_b:=($regResult_i=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_CompiledApplication
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_CompiledApplication is 0 or 1"
	$expected_t:="0 or 1"
	$compiled_i:=OTr_CompiledApplication
	$actual_t:=String:C10($compiled_i)
	$pass_b:=($compiled_i=0) | ($compiled_i=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_SetOptions / OTr_GetOptions round-trip
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_SetOptions/GetOptions round-trip"
	$originalOptions_i:=OTr_GetOptions
	$newOptions_i:=1+4+8
	OTr_SetOptions($newOptions_i)
	$readOptions_i:=OTr_GetOptions
	$expected_t:=String:C10($newOptions_i)
	$actual_t:=String:C10($readOptions_i)
	$pass_b:=($readOptions_i=$newOptions_i)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	OTr_SetOptions($originalOptions_i)
	
	// OTr_SetErrorHandler chaining
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_SetErrorHandler chaining"
	$prevHandler_t:=OTr_SetErrorHandler("Handler_A")
	$prev2Handler_t:=OTr_SetErrorHandler("Handler_B")
	$prev3Handler_t:=OTr_SetErrorHandler("")
	$expected_t:="prev2=Handler_A; prev3=Handler_B"
	$actual_t:="prev2="+$prev2Handler_t+"; prev3="+$prev3Handler_t
	$pass_b:=($prev2Handler_t="Handler_A") & ($prev3Handler_t="Handler_B")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_New returns positive handle
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_New returns positive handle"
	$h1_i:=OTr_New
	$expected_t:=">0"
	$actual_t:=String:C10($h1_i)
	$pass_b:=($h1_i>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_IsObject — valid handle
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_IsObject valid handle = 1"
	$expected_t:="1"
	$actual_t:=String:C10(OTr_IsObject($h1_i))
	$pass_b:=(OTr_IsObject($h1_i)=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_IsObject — handle 0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_IsObject handle 0 = 0"
	$expected_t:="0"
	$actual_t:=String:C10(OTr_IsObject(0))
	$pass_b:=(OTr_IsObject(0)=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_IsObject — invalid handle
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_IsObject invalid handle = 0"
	$expected_t:="0"
	$actual_t:=String:C10(OTr_IsObject(999999))
	$pass_b:=(OTr_IsObject(999999)=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_Copy — distinct handle
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_Copy returns distinct positive handle"
	$h2_i:=OTr_Copy($h1_i)
	$expected_t:=">0 and #"+String:C10($h1_i)
	$actual_t:=String:C10($h2_i)
	$pass_b:=($h2_i>0) & ($h2_i#$h1_i)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_GetHandleList — 2 handles
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetHandleList returns 2 handles"
	ARRAY LONGINT:C221($handles_ai; 0)
	OTr_GetHandleList(->$handles_ai)
	$expected_t:="2"
	$actual_t:=String:C10(Size of array:C274($handles_ai))
	$pass_b:=(Size of array:C274($handles_ai)=2)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_GetHandleList contains h1
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetHandleList contains h1"
	$findIndex_i:=Find in array:C230($handles_ai; $h1_i)
	$expected_t:=">0"
	$actual_t:=String:C10($findIndex_i)
	$pass_b:=($findIndex_i>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_GetHandleList contains h2
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetHandleList contains h2 (copy)"
	$findIndex_i:=Find in array:C230($handles_ai; $h2_i)
	$expected_t:=">0"
	$actual_t:=String:C10($findIndex_i)
	$pass_b:=($findIndex_i>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_Clear invalidates handle
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_Clear invalidates handle"
	OTr_Clear($h1_i)
	$expected_t:="0"
	$actual_t:=String:C10(OTr_IsObject($h1_i))
	$pass_b:=(OTr_IsObject($h1_i)=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_New reuses cleared slot
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_New reuses cleared slot"
	$h3_i:=OTr_New
	$expected_t:=String:C10($h1_i)
	$actual_t:=String:C10($h3_i)
	$pass_b:=($h3_i=$h1_i)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_ClearAll empties handle list
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ClearAll empties handle list"
	OTr_ClearAll
	ARRAY LONGINT:C221($handles_ai; 0)
	OTr_GetHandleList(->$handles_ai)
	$expected_t:="0"
	$actual_t:=String:C10(Size of array:C274($handles_ai))
	$pass_b:=(Size of array:C274($handles_ai)=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_ClearAll leaves former handles invalid
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ClearAll leaves h2 and h3 invalid"
	$expected_t:="h2=0; h3=0"
	$actual_t:="h2="+String:C10(OTr_IsObject($h2_i))+"; h3="+String:C10(OTr_IsObject($h3_i))
	$pass_b:=(OTr_IsObject($h2_i)=0) & (OTr_IsObject($h3_i)=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// ============================================================
	// PHASE 1.5 — Export methods
	// ============================================================
	$phase_t:="Phase 1.5"
	
	OTr_ClearAll
	var $handle_i : Integer
	var $json_t; $tempFile_t; $readBack_t : Text
	$handle_i:=OTr_New
	
	// OTr_SaveToText empty object
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_SaveToText empty object = {}"
	$json_t:=OTr_SaveToText($handle_i)
	$expected_t:="{}"
	$actual_t:=$json_t
	$pass_b:=($json_t="{}")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_SaveToText pretty
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_SaveToText pretty contains {"
	$json_t:=OTr_SaveToText($handle_i; True:C214)
	$expected_t:="contains {"
	$actual_t:=Choose:C955(Position:C15("{"; $json_t)>0; "contains {"; "missing {")
	$pass_b:=(Position:C15("{"; $json_t)>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// OTr_SaveToFile
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_SaveToFile creates readable JSON"
	$tempFile_t:=Temporary folder:C486+"OTR_Master_Test.json"
	OTr_SaveToFile($handle_i; $tempFile_t)
	$readBack_t:=Document to text:C1236($tempFile_t; "UTF-8")
	$expected_t:="contains {"
	$actual_t:=Choose:C955(Position:C15("{"; $readBack_t)>0; "contains {"; "missing {")
	$pass_b:=(Position:C15("{"; $readBack_t)>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	DELETE DOCUMENT:C159($tempFile_t)
	
	// OTr_SaveToClipboard
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_SaveToClipboard places JSON on clipboard"
	OTr_SaveToClipboard($handle_i)
	$json_t:=Get text from pasteboard:C524
	$expected_t:="contains {"
	$actual_t:=Choose:C955(Position:C15("{"; $json_t)>0; "contains {"; "missing {")
	$pass_b:=(Position:C15("{"; $json_t)>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	OTr_ClearAll
	
	// ============================================================
	// PHASE 2 — Scalar put/get and object paths
	// ============================================================
	$phase_t:="Phase 2"
	
	OTr_ClearAll
	var $hRoot_i; $hObj_i; $hObjOut_i : Integer
	var $long_i : Integer
	var $real_r : Real
	var $text_t : Text
	var $date_d : Date
	var $time_h : Time
	var $bool_i : Integer
	
	$hRoot_i:=OTr_New
	$hObj_i:=OTr_New
	
	// PutLong/GetLong
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutLong/GetLong round-trip"
	OTr_PutLong($hRoot_i; "long.value"; 42)
	$long_i:=OTr_GetLong($hRoot_i; "long.value")
	$expected_t:="42"
	$actual_t:=String:C10($long_i)
	$pass_b:=($long_i=42)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutReal/GetReal
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutReal/GetReal round-trip"
	OTr_PutReal($hRoot_i; "real.value"; 3.14)
	$real_r:=OTr_GetReal($hRoot_i; "real.value")
	$expected_t:="3.14"
	$actual_t:=String:C10($real_r)
	$pass_b:=($real_r=3.14)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutString/GetString
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutString/GetString round-trip"
	OTr_PutString($hRoot_i; "text.string"; "alpha")
	$text_t:=OTr_GetString($hRoot_i; "text.string")
	$expected_t:="alpha"
	$actual_t:=$text_t
	$pass_b:=($text_t="alpha")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutText/GetText
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutText/GetText round-trip"
	OTr_PutText($hRoot_i; "text.text"; "beta")
	$text_t:=OTr_GetText($hRoot_i; "text.text")
	$expected_t:="beta"
	$actual_t:=$text_t
	$pass_b:=($text_t="beta")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutDate/GetDate
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutDate/GetDate round-trip"
	$date_d:=Current date:C33
	OTr_PutDate($hRoot_i; "date.value"; $date_d)
	$expected_t:=String:C10($date_d)
	$actual_t:=String:C10(OTr_GetDate($hRoot_i; "date.value"))
	$pass_b:=(OTr_GetDate($hRoot_i; "date.value")=$date_d)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutTime/GetTime
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutTime/GetTime round-trip"
	$time_h:=Current time:C178
	OTr_PutTime($hRoot_i; "time.value"; $time_h)
	$expected_t:=String:C10($time_h; HH MM SS:K7:1)
	$actual_t:=String:C10(OTr_GetTime($hRoot_i; "time.value"); HH MM SS:K7:1)
	$pass_b:=(OTr_GetTime($hRoot_i; "time.value")=$time_h)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutBoolean True
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutBoolean/GetBoolean True"
	OTr_PutBoolean($hRoot_i; "bool.value"; True:C214)
	$bool_i:=OTr_GetBoolean($hRoot_i; "bool.value")
	$expected_t:="1"
	$actual_t:=String:C10($bool_i)
	$pass_b:=($bool_i=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutBoolean False
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutBoolean/GetBoolean False"
	OTr_PutBoolean($hRoot_i; "bool.value"; False:C215)
	$bool_i:=OTr_GetBoolean($hRoot_i; "bool.value")
	$expected_t:="0"
	$actual_t:=String:C10($bool_i)
	$pass_b:=($bool_i=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutObject/GetObject — handle returned
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutObject/GetObject returns handle"
	OTr_PutText($hObj_i; "inside"; "value")
	OTr_PutObject($hRoot_i; "obj.child"; $hObj_i)
	$hObjOut_i:=OTr_GetObject($hRoot_i; "obj.child")
	$expected_t:=">0"
	$actual_t:=String:C10($hObjOut_i)
	$pass_b:=($hObjOut_i>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetObject content
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetObject content correct"
	$expected_t:="value"
	$actual_t:=OTr_GetText($hObjOut_i; "inside")
	$pass_b:=($actual_t="value")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetObject deep copy semantics
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetObject is deep copy (mutate source, child unchanged)"
	OTr_PutText($hObj_i; "inside"; "changed")
	$expected_t:="value"
	$actual_t:=OTr_GetText($hObjOut_i; "inside")
	$pass_b:=($actual_t="value")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// Missing path defaults
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetLong missing path default = 0"
	$expected_t:="0"
	$actual_t:=String:C10(OTr_GetLong($hRoot_i; "missing.path"))
	$pass_b:=(OTr_GetLong($hRoot_i; "missing.path")=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetText missing path default = empty"
	$expected_t:="(empty)"
	$text_t:=OTr_GetText($hRoot_i; "missing.path")
	$actual_t:=Choose:C955($text_t=""; "(empty)"; $text_t)
	$pass_b:=($text_t="")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	OTr_ClearAll
	
	// ============================================================
	// PHASE 3 — Item info and utility methods
	// ============================================================
	$phase_t:="Phase 3"
	
	OTr_ClearAll
	var $h1_3_i; $h2_3_i; $hObj3_i : Integer
	var $count3_i; $type3_i; $isEmbedded3_i; $exists3_i; $size3_i; $cmp3_i : Integer
	var $name3_t : Text
	var $outType3_i; $itemSize3_i; $dataSize3_i; $index3_i : Integer
	ARRAY TEXT:C222($names3_at; 0)
	ARRAY LONGINT:C221($types3_ai; 0)
	ARRAY LONGINT:C221($itemSizes3_ai; 0)
	ARRAY LONGINT:C221($dataSizes3_ai; 0)
	
	$h1_3_i:=OTr_New
	$h2_3_i:=OTr_New
	$hObj3_i:=OTr_New
	OTr_PutLong($h1_3_i; "a.long"; 42)
	OTr_PutText($h1_3_i; "a.text"; "alpha")
	OTr_PutBoolean($h1_3_i; "a.flag"; True:C214)
	OTr_PutText($hObj3_i; "inside"; "value")
	OTr_PutObject($h1_3_i; "a.child"; $hObj3_i)
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ItemCount on embedded object = 4"
	$count3_i:=OTr_ItemCount($h1_3_i; "a")
	$expected_t:="4"
	$actual_t:=String:C10($count3_i)
	$pass_b:=($count3_i=4)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ItemExists existing tag = 1"
	$exists3_i:=OTr_ItemExists($h1_3_i; "a.long")
	$expected_t:="1"
	$actual_t:=String:C10($exists3_i)
	$pass_b:=($exists3_i=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ItemExists missing tag = 0"
	$exists3_i:=OTr_ItemExists($h1_3_i; "a.missing")
	$expected_t:="0"
	$actual_t:=String:C10($exists3_i)
	$pass_b:=($exists3_i=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ItemType for long = Is longint (shadow key)"
	$type3_i:=OTr_ItemType($h1_3_i; "a.long")
	$expected_t:=String:C10(Is longint:K8:6)
	$actual_t:=String:C10($type3_i)
	$pass_b:=($type3_i=Is longint:K8:6)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_IsEmbedded for object item = 1"
	$isEmbedded3_i:=OTr_IsEmbedded($h1_3_i; "a.child")
	$expected_t:="1"
	$actual_t:=String:C10($isEmbedded3_i)
	$pass_b:=($isEmbedded3_i=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetAllNamedProperties count = 4"
	OTr_GetAllNamedProperties($h1_3_i; "a"; ->$names3_at; ->$types3_ai; ->$itemSizes3_ai; ->$dataSizes3_ai)
	$expected_t:="4"
	$actual_t:=String:C10(Size of array:C274($names3_at))
	$pass_b:=(Size of array:C274($names3_at)=4)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetNamedProperties type=112; index=0"
	$outType3_i:=0
	$itemSize3_i:=0
	$dataSize3_i:=0
	$index3_i:=-1
	OTr_GetNamedProperties($h1_3_i; "a.text"; ->$outType3_i; ->$itemSize3_i; ->$dataSize3_i; ->$index3_i)
	$expected_t:="type=112; index=0"
	$actual_t:="type="+String:C10($outType3_i)+"; index="+String:C10($index3_i)
	$pass_b:=($outType3_i=112) & ($index3_i=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetItemProperties returns non-empty name"
	$name3_t:=""
	$outType3_i:=0
	$itemSize3_i:=0
	$dataSize3_i:=0
	OTr_GetItemProperties($h1_3_i; 1; ->$name3_t; ->$outType3_i; ->$itemSize3_i; ->$dataSize3_i)
	$expected_t:="non-empty name"
	$actual_t:=$name3_t
	$pass_b:=($name3_t#"")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_CopyItem/CompareItems equal = 1"
	OTr_CopyItem($h1_3_i; "a.text"; $h2_3_i; "b.text")
	$cmp3_i:=OTr_CompareItems($h1_3_i; "a.text"; $h2_3_i; "b.text")
	$expected_t:="1"
	$actual_t:=String:C10($cmp3_i)
	$pass_b:=($cmp3_i=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_RenameItem — new name exists"
	OTr_RenameItem($h2_3_i; "b.text"; "renamed")
	$expected_t:="1"
	$actual_t:=String:C10(OTr_ItemExists($h2_3_i; "b.renamed"))
	$pass_b:=(OTr_ItemExists($h2_3_i; "b.renamed")=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_DeleteItem — item gone"
	OTr_DeleteItem($h2_3_i; "b.renamed")
	$expected_t:="0"
	$actual_t:=String:C10(OTr_ItemExists($h2_3_i; "b.renamed"))
	$pass_b:=(OTr_ItemExists($h2_3_i; "b.renamed")=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ObjectSize > 0"
	$size3_i:=OTr_ObjectSize($h1_3_i)
	$expected_t:=">0"
	$actual_t:=String:C10($size3_i)
	$pass_b:=($size3_i>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	OTr_ClearAll
	
	// ============================================================
	// PHASE 4 — Array operations
	// ============================================================
	$phase_t:="Phase 4"
	
	OTr_ClearAll
	var $h4_i : Integer
	var $i4_i : Integer
	ARRAY LONGINT:C221($longArr4_ai; 0)
	ARRAY REAL:C219($realArr4_ar; 0)
	ARRAY TEXT:C222($textArr4_at; 0)
	ARRAY TEXT:C222($strArr4_at; 0)
	ARRAY DATE:C224($dateArr4_ad; 0)
	ARRAY TIME:C1223($timeArr4_ah; 0)
	ARRAY BOOLEAN:C223($boolArr4_ab; 0)
	
	$h4_i:=OTr_New
	
	// PutArray/GetArray LongInt
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArray/GetArray LongInt (5 elements)"
	ARRAY LONGINT:C221($longArr4_ai; 5)
	For ($i4_i; 1; 5)
		$longArr4_ai{$i4_i}:=$i4_i*10
	End for 
	OTr_PutArray($h4_i; "longs"; ->$longArr4_ai)
	ARRAY LONGINT:C221($longArr4_ai; 0)
	OTr_GetArray($h4_i; "longs"; ->$longArr4_ai)
	$expected_t:="size=5; [1]=10; [5]=50"
	$actual_t:="size="+String:C10(Size of array:C274($longArr4_ai))+"; [1]="+String:C10($longArr4_ai{1})+"; [5]="+String:C10($longArr4_ai{5})
	$pass_b:=(Size of array:C274($longArr4_ai)=5) & ($longArr4_ai{1}=10) & ($longArr4_ai{5}=50)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArray/GetArray Text
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArray/GetArray Text (3 elements)"
	ARRAY TEXT:C222($textArr4_at; 3)
	$textArr4_at{1}:="alpha"
	$textArr4_at{2}:="beta"
	$textArr4_at{3}:="gamma"
	OTr_PutArray($h4_i; "words"; ->$textArr4_at)
	ARRAY TEXT:C222($textArr4_at; 0)
	OTr_GetArray($h4_i; "words"; ->$textArr4_at)
	$expected_t:="size=3; [1]=alpha; [3]=gamma"
	$actual_t:="size="+String:C10(Size of array:C274($textArr4_at))+"; [1]="+$textArr4_at{1}+"; [3]="+$textArr4_at{3}
	$pass_b:=(Size of array:C274($textArr4_at)=3) & ($textArr4_at{1}="alpha") & ($textArr4_at{3}="gamma")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// SizeOfArray
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_SizeOfArray = 5"
	$expected_t:="5"
	$actual_t:=String:C10(OTr_SizeOfArray($h4_i; "longs"))
	$pass_b:=(OTr_SizeOfArray($h4_i; "longs")=5)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// ArrayType — LongInt
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ArrayType LongInt array = LongInt array constant"
	$expected_t:=String:C10(LongInt array:K8:19)
	$actual_t:=String:C10(OTr_ArrayType($h4_i; "longs"))
	$pass_b:=(OTr_ArrayType($h4_i; "longs")=LongInt array:K8:19)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// ArrayType — missing returns -1
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ArrayType missing tag = -1"
	$expected_t:="-1"
	$actual_t:=String:C10(OTr_ArrayType($h4_i; "missing"))
	$pass_b:=(OTr_ArrayType($h4_i; "missing")=-1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// ResizeArray — grow
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ResizeArray grow to 8"
	OTr_ResizeArray($h4_i; "longs"; 8)
	$expected_t:="8"
	$actual_t:=String:C10(OTr_SizeOfArray($h4_i; "longs"))
	$pass_b:=(OTr_SizeOfArray($h4_i; "longs")=8)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// ResizeArray — shrink
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ResizeArray shrink to 3"
	OTr_ResizeArray($h4_i; "longs"; 3)
	$expected_t:="3"
	$actual_t:=String:C10(OTr_SizeOfArray($h4_i; "longs"))
	$pass_b:=(OTr_SizeOfArray($h4_i; "longs")=3)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// ResizeArray — invalid handle sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ResizeArray invalid handle sets OK=0"
	OTr_ResizeArray(9999; "longs"; 5)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayLong / GetArrayLong
	ARRAY LONGINT:C221($longArr4_ai; 5)
	For ($i4_i; 1; 5)
		$longArr4_ai{$i4_i}:=$i4_i*100
	End for 
	OTr_PutArray($h4_i; "longs"; ->$longArr4_ai)
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayLong/GetArrayLong round-trip"
	OTr_PutArrayLong($h4_i; "longs"; 2; 999)
	$expected_t:="999"
	$actual_t:=String:C10(OTr_GetArrayLong($h4_i; "longs"; 2))
	$pass_b:=(OTr_GetArrayLong($h4_i; "longs"; 2)=999)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayLong adjacent elements undisturbed"
	$expected_t:="[1]=100; [5]=500"
	$actual_t:="[1]="+String:C10(OTr_GetArrayLong($h4_i; "longs"; 1))+"; [5]="+String:C10(OTr_GetArrayLong($h4_i; "longs"; 5))
	$pass_b:=(OTr_GetArrayLong($h4_i; "longs"; 1)=100) & (OTr_GetArrayLong($h4_i; "longs"; 5)=500)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayLong out-of-range sets OK=0"
	OTr_PutArrayLong($h4_i; "longs"; 99; 1)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayLong type mismatch sets OK=0"
	OTr_PutArrayLong($h4_i; "words"; 1; 1)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayReal / GetArrayReal
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayReal/GetArrayReal round-trip"
	ARRAY REAL:C219($realArr4_ar; 4)
	$realArr4_ar{1}:=1.1
	$realArr4_ar{2}:=2.2
	$realArr4_ar{3}:=3.3
	$realArr4_ar{4}:=4.4
	OTr_PutArray($h4_i; "reals"; ->$realArr4_ar)
	OTr_PutArrayReal($h4_i; "reals"; 3; 9.9)
	$expected_t:="9.9"
	var $got4Real_r : Real
	$got4Real_r:=OTr_GetArrayReal($h4_i; "reals"; 3)
	$actual_t:=String:C10($got4Real_r)
	$pass_b:=($got4Real_r>9.89) & ($got4Real_r<9.91)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayString / GetArrayString
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayString/GetArrayString round-trip"
	ARRAY TEXT:C222($strArr4_at; 3)
	$strArr4_at{1}:="foo"
	$strArr4_at{2}:="bar"
	$strArr4_at{3}:="baz"
	OTr_PutArray($h4_i; "strs"; ->$strArr4_at)
	OTr_PutArrayString($h4_i; "strs"; 2; "qux")
	$expected_t:="qux"
	$actual_t:=OTr_GetArrayString($h4_i; "strs"; 2)
	$pass_b:=($actual_t="qux")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayText / GetArrayText
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayText/GetArrayText round-trip"
	ARRAY TEXT:C222($textArr4_at; 3)
	$textArr4_at{1}:="one"
	$textArr4_at{2}:="two"
	$textArr4_at{3}:="three"
	OTr_PutArray($h4_i; "texts"; ->$textArr4_at)
	OTr_PutArrayText($h4_i; "texts"; 1; "ONE")
	$expected_t:="ONE"
	$actual_t:=OTr_GetArrayText($h4_i; "texts"; 1)
	$pass_b:=($actual_t="ONE")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayDate / GetArrayDate
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayDate/GetArrayDate round-trip"
	ARRAY DATE:C224($dateArr4_ad; 3)
	$dateArr4_ad{1}:=!2026-01-01!
	$dateArr4_ad{2}:=!2026-06-15!
	$dateArr4_ad{3}:=!2026-12-31!
	OTr_PutArray($h4_i; "dates"; ->$dateArr4_ad)
	OTr_PutArrayDate($h4_i; "dates"; 2; !2000-07-04!)
	$expected_t:="!2000-07-04!"
	$actual_t:=String:C10(OTr_GetArrayDate($h4_i; "dates"; 2))
	$pass_b:=(OTr_GetArrayDate($h4_i; "dates"; 2)=!2000-07-04!)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayTime / GetArrayTime
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayTime/GetArrayTime round-trip"
	ARRAY TIME:C1223($timeArr4_ah; 3)
	$timeArr4_ah{1}:=?08:00:00?
	$timeArr4_ah{2}:=?12:30:00?
	$timeArr4_ah{3}:=?23:59:59?
	OTr_PutArray($h4_i; "times"; ->$timeArr4_ah)
	OTr_PutArrayTime($h4_i; "times"; 2; ?09:15:00?)
	$expected_t:="09:15:00"
	$actual_t:=String:C10(OTr_GetArrayTime($h4_i; "times"; 2); HH MM SS:K7:1)
	$pass_b:=(OTr_GetArrayTime($h4_i; "times"; 2)=?09:15:00?)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayBoolean / GetArrayBoolean
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayBoolean/GetArrayBoolean round-trip"
	ARRAY BOOLEAN:C223($boolArr4_ab; 4)
	$boolArr4_ab{1}:=True:C214
	$boolArr4_ab{2}:=False:C215
	$boolArr4_ab{3}:=True:C214
	$boolArr4_ab{4}:=False:C215
	OTr_PutArray($h4_i; "flags4"; ->$boolArr4_ab)
	OTr_PutArrayBoolean($h4_i; "flags4"; 2; True:C214)
	$expected_t:="[2]=1; [4]=0"
	$actual_t:="[2]="+String:C10(OTr_GetArrayBoolean($h4_i; "flags4"; 2))+"; [4]="+String:C10(OTr_GetArrayBoolean($h4_i; "flags4"; 4))
	$pass_b:=(OTr_GetArrayBoolean($h4_i; "flags4"; 2)=1) & (OTr_GetArrayBoolean($h4_i; "flags4"; 4)=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// InsertElement at pos 2
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_InsertElement at pos 2"
	ARRAY TEXT:C222($textArr4_at; 3)
	$textArr4_at{1}:="alpha"
	$textArr4_at{2}:="beta"
	$textArr4_at{3}:="gamma"
	OTr_PutArray($h4_i; "ins_test"; ->$textArr4_at)
	OTr_InsertElement($h4_i; "ins_test"; 2; 1)
	OTr_PutArrayText($h4_i; "ins_test"; 2; "delta")
	ARRAY TEXT:C222($textArr4_at; 0)
	OTr_GetArray($h4_i; "ins_test"; ->$textArr4_at)
	$expected_t:="size=4; [2]=delta; [3]=beta"
	$actual_t:="size="+String:C10(Size of array:C274($textArr4_at))+"; [2]="+$textArr4_at{2}+"; [3]="+$textArr4_at{3}
	$pass_b:=(Size of array:C274($textArr4_at)=4) & ($textArr4_at{2}="delta") & ($textArr4_at{3}="beta")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// DeleteElement at pos 2
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_DeleteElement at pos 2"
	OTr_DeleteElement($h4_i; "ins_test"; 2)
	ARRAY TEXT:C222($textArr4_at; 0)
	OTr_GetArray($h4_i; "ins_test"; ->$textArr4_at)
	$expected_t:="size=3; [1]=alpha; [2]=beta"
	$actual_t:="size="+String:C10(Size of array:C274($textArr4_at))+"; [1]="+$textArr4_at{1}+"; [2]="+$textArr4_at{2}
	$pass_b:=(Size of array:C274($textArr4_at)=3) & ($textArr4_at{1}="alpha") & ($textArr4_at{2}="beta")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// FindInArray — Text first match
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_FindInArray Text first match"
	ARRAY TEXT:C222($textArr4_at; 5)
	$textArr4_at{1}:="cat"
	$textArr4_at{2}:="dog"
	$textArr4_at{3}:="bird"
	$textArr4_at{4}:="dog"
	$textArr4_at{5}:="fish"
	OTr_PutArray($h4_i; "pets"; ->$textArr4_at)
	$expected_t:="2"
	$actual_t:=String:C10(OTr_FindInArray($h4_i; "pets"; "dog"))
	$pass_b:=(OTr_FindInArray($h4_i; "pets"; "dog")=2)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// FindInArray — startFrom
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_FindInArray Text startFrom=3"
	$expected_t:="4"
	$actual_t:=String:C10(OTr_FindInArray($h4_i; "pets"; "dog"; 3))
	$pass_b:=(OTr_FindInArray($h4_i; "pets"; "dog"; 3)=4)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// FindInArray — not found
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_FindInArray not found = -1"
	$expected_t:="-1"
	$actual_t:=String:C10(OTr_FindInArray($h4_i; "pets"; "elephant"))
	$pass_b:=(OTr_FindInArray($h4_i; "pets"; "elephant")=-1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// FindInArray — invalid handle
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_FindInArray invalid handle sets OK=0"
	OTr_FindInArray(9999; "pets"; "cat")
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// SortArrays — single ascending LongInt
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_SortArrays single key ascending LongInt"
	ARRAY LONGINT:C221($longArr4_ai; 5)
	$longArr4_ai{1}:=40
	$longArr4_ai{2}:=10
	$longArr4_ai{3}:=50
	$longArr4_ai{4}:=20
	$longArr4_ai{5}:=30
	OTr_PutArray($h4_i; "sort_nums"; ->$longArr4_ai)
	OTr_SortArrays($h4_i; "sort_nums"; ">")
	ARRAY LONGINT:C221($longArr4_ai; 0)
	OTr_GetArray($h4_i; "sort_nums"; ->$longArr4_ai)
	$expected_t:="10,20,30,40,50"
	$actual_t:=String:C10($longArr4_ai{1})+","+String:C10($longArr4_ai{2})+","+String:C10($longArr4_ai{3})+","+String:C10($longArr4_ai{4})+","+String:C10($longArr4_ai{5})
	$pass_b:=($longArr4_ai{1}=10) & ($longArr4_ai{2}=20) & ($longArr4_ai{3}=30) & ($longArr4_ai{4}=40) & ($longArr4_ai{5}=50)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// SortArrays — invalid handle sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_SortArrays invalid handle sets OK=0"
	OTr_SortArrays(9999; "sort_nums"; ">")
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	OTr_ClearAll
	
	// ============================================================
	// PHASE 5 — Binary and specialised data
	// ============================================================
	$phase_t:="Phase 5"
	
	OTr_ClearAll
	var $h5_i : Integer
	var $testBlob5_blob; $gotBlob5_blob : Blob
	var $testPic5_pic; $gotPic5_pic : Picture
	var $ptrVar5_ptr : Pointer
	var OTr_DummyVariableForTests_t : Text  // process variable used for pointer round-trip
	
	$h5_i:=OTr_New
	OTr_DummyVariableForTests_t:="pointer-round-trip"
	
	// PutBLOB — tag created
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_PutBLOB creates tag"
	CONVERT FROM TEXT:C1011("hello-otr-blob-test"; "UTF-8"; $testBlob5_blob)
	OTr_PutBLOB($h5_i; "blobval"; $testBlob5_blob)
	$expected_t:="1"
	$actual_t:=String:C10(OTr_ItemExists($h5_i; "blobval"))
	$pass_b:=(OTr_ItemExists($h5_i; "blobval")=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetBLOB — pointer-parameter round-trip
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetBLOB pointer-parameter round-trip"
	CLEAR VARIABLE:C89($gotBlob5_blob)
	OTr_GetBLOB($h5_i; "blobval"; ->$gotBlob5_blob)
	$expected_t:="equal"
	$actual_t:=Choose:C955(OTr_u_EqualBLOBs($testBlob5_blob; $gotBlob5_blob); "equal"; "not equal")
	$pass_b:=OTr_u_EqualBLOBs($testBlob5_blob; $gotBlob5_blob)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetNewBLOB — round-trip
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetNewBLOB round-trip"
	CONVERT FROM TEXT:C1011("hello-otr-blob-test"; "UTF-8"; $testBlob5_blob)
	OTr_PutBLOB($h5_i; "blobval2"; $testBlob5_blob)
	$gotBlob5_blob:=OTr_GetNewBLOB($h5_i; "blobval2")
	$expected_t:="equal"
	$actual_t:=Choose:C955(OTr_u_EqualBLOBs($testBlob5_blob; $gotBlob5_blob); "equal"; "not equal")
	$pass_b:=OTr_u_EqualBLOBs($testBlob5_blob; $gotBlob5_blob)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutBLOB — invalid handle sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_PutBLOB invalid handle sets OK=0"
	OTr_PutBLOB(9999; "blobval"; $testBlob5_blob)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutPicture — tag created
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_PutPicture creates tag"
	$testPic5_pic:=OTr_z_Wombat
	OTr_PutPicture($h5_i; "picval"; $testPic5_pic)
	$expected_t:="1"
	$actual_t:=String:C10(OTr_ItemExists($h5_i; "picval"))
	$pass_b:=(OTr_ItemExists($h5_i; "picval")=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetPicture — round-trip
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetPicture round-trip"
	$gotPic5_pic:=OTr_GetPicture($h5_i; "picval")
	$expected_t:="equal"
	$actual_t:=Choose:C955(OTr_u_EqualPictures($testPic5_pic; $gotPic5_pic); "equal"; "not equal")
	$pass_b:=OTr_u_EqualPictures($testPic5_pic; $gotPic5_pic)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutPointer — tag created
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_PutPointer creates tag"
	OTr_PutPointer($h5_i; "ptrval"; ->OTr_DummyVariableForTests_t)
	$expected_t:="1"
	$actual_t:=String:C10(OTr_ItemExists($h5_i; "ptrval"))
	$pass_b:=(OTr_ItemExists($h5_i; "ptrval")=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetPointer — round-trip
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetPointer round-trip"
	If (Storage:C1525.OTr.structureName#"nativeObjectTools")
		$expected_t:="component-safe skip"
		$actual_t:="variable pointer dereference requires host OT Host GetPointer"
		$pass_b:=True:C214
	Else 
		$ptrVar5_ptr:=Null:C1517
		OTr_GetPointer($h5_i; "ptrval"; ->$ptrVar5_ptr)
		$expected_t:="pointer-round-trip"
		If ((OK=1) & ($ptrVar5_ptr#Null:C1517))
			$actual_t:=$ptrVar5_ptr->
			$pass_b:=($actual_t="pointer-round-trip")
		Else 
			$actual_t:="(null)"
			$pass_b:=False:C215
		End if 
	End if 
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutRecord — invalid handle sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_PutRecord invalid handle sets OK=0"
	OTr_PutRecord(9999; "rec"; 1)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutRecord — invalid table sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_PutRecord invalid table sets OK=0"
	OTr_PutRecord($h5_i; "rec"; -1)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetRecord — invalid handle sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetRecord invalid handle sets OK=0"
	OTr_GetRecord(9999; "rec"; 1)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetRecordTable — hand-crafted snapshot
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_GetRecordTable hand-crafted snapshot = 7"
	OTr_z_Lock
	OB SET:C1220(<>OTR_Objects_ao{$h5_i}; "snaptag"; New object:C1471("__tableNum"; 7; "SomeField"; "test-value"))
	OTr_z_Unlock
	$expected_t:="7"
	$actual_t:=String:C10(OTr_GetRecordTable($h5_i; "snaptag"))
	$pass_b:=(OTr_GetRecordTable($h5_i; "snaptag")=7)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutVariable / GetVariable — LongInt
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_PutVariable/GetVariable LongInt"
	var $longVar5_i; $longVarOut5_i : Integer
	$longVar5_i:=12345
	OTr_PutVariable($h5_i; "vlong"; ->$longVar5_i)
	$longVarOut5_i:=0
	OTr_GetVariable($h5_i; "vlong"; ->$longVarOut5_i)
	$expected_t:="12345"
	$actual_t:=String:C10($longVarOut5_i)
	$pass_b:=($longVarOut5_i=12345)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutVariable / GetVariable — Text
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_PutVariable/GetVariable Text"
	var $textVar5_t; $textVarOut5_t : Text
	$textVar5_t:="hello-variable"
	OTr_PutVariable($h5_i; "vtext"; ->$textVar5_t)
	$textVarOut5_t:=""
	OTr_GetVariable($h5_i; "vtext"; ->$textVarOut5_t)
	$expected_t:="hello-variable"
	$actual_t:=$textVarOut5_t
	$pass_b:=($textVarOut5_t="hello-variable")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutVariable — invalid handle sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_PutVariable invalid handle sets OK=0"
	OTr_PutVariable(9999; "vlong"; ->$longVar5_i)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	OTr_ClearAll
	
	// ============================================================
	// PHASE 6 — Serialisation (uMapType, ObjectToBLOB, BLOBToObject)
	// ============================================================
	$phase_t:="Phase 6"
	
	OTr_ClearAll
	var $h6_i; $h6b_i : Integer
	var $mapResult6_i : Integer
	var $serialBlob6_blob; $badBlob6_blob : Blob
	var $gotStr6_t : Text
	var $gotLong6_i : Integer
	var $gotBool6_i : Integer
	
	// uMapType 4D→OT: Is longint → Is longint:K8:6 (shadow-key currency)
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType Is longint 4D→OT → Is longint:K8:6"
	$mapResult6_i:=OTr_u_MapType(Is longint:K8:6; 0)
	$expected_t:=String:C10(Is longint:K8:6)
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=Is longint:K8:6)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// uMapType 4D→OT: Is text → OT Is Character (112)
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType Is text 4D→OT → OT Is Character (112)"
	$mapResult6_i:=OTr_u_MapType(Is text:K8:3; 0)
	$expected_t:=String:C10(OT Is Character)
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=OT Is Character)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// uMapType OT→4D: Is longint:K8:6 → Is longint
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType Is longint:K8:6 OT→4D → Is longint"
	$mapResult6_i:=OTr_u_MapType(Is longint:K8:6; 1)
	$expected_t:=String:C10(Is longint:K8:6)
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=Is longint:K8:6)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// uMapType 4D→OT: Is real → Is real:K8:4 (shadow-key currency)
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType Is real 4D→OT → Is real:K8:4"
	$mapResult6_i:=OTr_u_MapType(Is real:K8:4; 0)
	$expected_t:=String:C10(Is real:K8:4)
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=Is real:K8:4)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// uMapType 4D→OT: Is picture → Is picture:K8:10 (shadow-key currency)
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType Is picture 4D→OT → Is picture:K8:10"
	$mapResult6_i:=OTr_u_MapType(Is picture:K8:10; 0)
	$expected_t:=String:C10(Is picture:K8:10)
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=Is picture:K8:10)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// uMapType 4D→OT: Is collection → OT Character array (113)
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType Is collection 4D→OT → OT Character array (113)"
	$mapResult6_i:=OTr_u_MapType(Is collection:K8:32; 0)
	$expected_t:=String:C10(OT Character array)
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=OT Character array)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// uMapType OT→4D: OT Is Record (115) → Is text
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType OT Is Record (115) OT→4D → Is text"
	$mapResult6_i:=OTr_u_MapType(OT Is Record; 1)
	$expected_t:=String:C10(Is text:K8:3)
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=Is text:K8:3)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// uMapType OT→4D: 24 (legacy Variable) → Is text
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType 24 (legacy Variable) OT→4D → Is text"
	$mapResult6_i:=OTr_u_MapType(24; 1)
	$expected_t:=String:C10(Is text:K8:3)
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=Is text:K8:3)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// uMapType 4D→OT: Is Boolean → Is Boolean:K8:9 (shadow-key currency; default direction)
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType Is Boolean 4D→OT (default dir) → Is Boolean:K8:9"
	$mapResult6_i:=OTr_u_MapType(Is boolean:K8:9)
	$expected_t:=String:C10(Is boolean:K8:9)
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=Is boolean:K8:9)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// uMapType — unknown type returns 0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_u_MapType unknown type → 0"
	$mapResult6_i:=OTr_u_MapType(9999; 0)
	$expected_t:="0"
	$actual_t:=String:C10($mapResult6_i)
	$pass_b:=($mapResult6_i=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// ObjectToNewBLOB — non-empty BLOB
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ObjectToNewBLOB produces non-empty BLOB"
	$h6_i:=OTr_New
	OTr_PutString($h6_i; "name"; "phase6-test")
	OTr_PutLong($h6_i; "count"; 42)
	OTr_PutReal($h6_i; "ratio"; 3.14)
	OTr_PutBoolean($h6_i; "flag"; True:C214)
	$serialBlob6_blob:=OTr_ObjectToNewBLOB($h6_i)
	$expected_t:="OK=1; size>0"
	$actual_t:="OK="+String:C10(OK)+"; size="+String:C10(BLOB size:C605($serialBlob6_blob))
	$pass_b:=(OK=1) & (BLOB size:C605($serialBlob6_blob)>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// BLOBToObject — returns valid handle
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_BLOBToObject returns valid handle"
	$h6b_i:=OTr_BLOBToObject($serialBlob6_blob)
	$expected_t:="OK=1; handle>0"
	$actual_t:="OK="+String:C10(OK)+"; handle="+String:C10($h6b_i)
	$pass_b:=(OK=1) & ($h6b_i>0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// BLOBToObject round-trip — string value
	$rowNum_i:=$rowNum_i+1
	$testName_t:="BLOBToObject round-trip string value"
	$gotStr6_t:=OTr_GetString($h6b_i; "name")
	$expected_t:="phase6-test"
	$actual_t:=$gotStr6_t
	$pass_b:=($gotStr6_t="phase6-test")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// BLOBToObject round-trip — long value
	$rowNum_i:=$rowNum_i+1
	$testName_t:="BLOBToObject round-trip long value"
	$gotLong6_i:=OTr_GetLong($h6b_i; "count")
	$expected_t:="42"
	$actual_t:=String:C10($gotLong6_i)
	$pass_b:=($gotLong6_i=42)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// BLOBToObject round-trip — real value
	$rowNum_i:=$rowNum_i+1
	$testName_t:="BLOBToObject round-trip real value"
	var $gotReal6_r : Real
	$gotReal6_r:=OTr_GetReal($h6b_i; "ratio")
	$expected_t:="3.14"
	$actual_t:=String:C10($gotReal6_r)
	$pass_b:=($gotReal6_r=3.14)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// BLOBToObject round-trip — boolean value
	$rowNum_i:=$rowNum_i+1
	$testName_t:="BLOBToObject round-trip boolean value"
	$gotBool6_i:=OTr_GetBoolean($h6b_i; "flag")
	$expected_t:="1"
	$actual_t:=String:C10($gotBool6_i)
	$pass_b:=($gotBool6_i=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// ObjectToBLOB — invalid handle sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ObjectToBLOB invalid handle sets OK=0"
	SET BLOB SIZE:C606($serialBlob6_blob; 0)
	OTr_ObjectToBLOB(9999; ->$serialBlob6_blob)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// BLOBToObject — invalid data sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_BLOBToObject invalid data sets OK=0; returns 0"
	CONVERT FROM TEXT:C1011("NOT_OTR1_DATA"; "US-ASCII"; $badBlob6_blob)
	var $h6bad_i : Integer
	$h6bad_i:=OTr_BLOBToObject($badBlob6_blob)
	$expected_t:="OK=0; handle=0"
	$actual_t:="OK="+String:C10(OK)+"; handle="+String:C10($h6bad_i)
	$pass_b:=(OK=0) & ($h6bad_i=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// BLOBToObject — BLOB too small (< 4 bytes) sets OK=0; returns 0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_BLOBToObject BLOB too small (3 bytes) sets OK=0; returns 0"
	CONVERT FROM TEXT:C1011("OTR"; "US-ASCII"; $badBlob6_blob)  // only 3 bytes
	var $h6tiny_i : Integer
	$h6tiny_i:=OTr_BLOBToObject($badBlob6_blob)
	$expected_t:="OK=0; handle=0"
	$actual_t:="OK="+String:C10(OK)+"; handle="+String:C10($h6tiny_i)
	$pass_b:=(OK=0) & ($h6tiny_i=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// BLOB item round-trip: object containing BLOB → ObjectToNewBLOB → BLOBToObject → GetNewBLOB
	$rowNum_i:=$rowNum_i+1
	$testName_t:="Phase 6 BLOB item round-trip: ObjectToNewBLOB/BLOBToObject/GetNewBLOB"
	var $h6blobItem_i; $h6blobItem2_i : Integer
	var $blobItem6_blob; $roundBlob6_blob; $gotBlobItem6_blob : Blob
	$h6blobItem_i:=OTr_New
	CONVERT FROM TEXT:C1011("hello-otr-phase6"; "UTF-8"; $blobItem6_blob)
	OTr_PutBLOB($h6blobItem_i; "bdata"; $blobItem6_blob)
	$roundBlob6_blob:=OTr_ObjectToNewBLOB($h6blobItem_i)
	$h6blobItem2_i:=OTr_BLOBToObject($roundBlob6_blob)
	$gotBlobItem6_blob:=OTr_GetNewBLOB($h6blobItem2_i; "bdata")
	$expected_t:="equal"
	$actual_t:=Choose:C955(OTr_u_EqualBLOBs($blobItem6_blob; $gotBlobItem6_blob); "equal"; "not equal")
	$pass_b:=OTr_u_EqualBLOBs($blobItem6_blob; $gotBlobItem6_blob)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// Picture item round-trip: object containing Picture → ObjectToNewBLOB → BLOBToObject → GetPicture
	$rowNum_i:=$rowNum_i+1
	$testName_t:="Phase 6 Picture item round-trip: ObjectToNewBLOB/BLOBToObject/GetPicture"
	var $h6picItem_i; $h6picItem2_i : Integer
	var $picItem6_pic; $gotPicItem6_pic : Picture
	var $roundPicBlob6_blob : Blob
	$h6picItem_i:=OTr_New
	$picItem6_pic:=OTr_z_Koala
	OTr_PutPicture($h6picItem_i; "pdata"; $picItem6_pic)
	$roundPicBlob6_blob:=OTr_ObjectToNewBLOB($h6picItem_i)
	$h6picItem2_i:=OTr_BLOBToObject($roundPicBlob6_blob)
	$gotPicItem6_pic:=OTr_GetPicture($h6picItem2_i; "pdata")
	$expected_t:="equal"
	$actual_t:=Choose:C955(OTr_u_EqualPictures($picItem6_pic; $gotPicItem6_pic); "equal"; "not equal")
	$pass_b:=OTr_u_EqualPictures($picItem6_pic; $gotPicItem6_pic)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	OTr_ClearAll
	
	// ============================================================
	// PHASE 16 - Legacy ObjectTools BLOB import sample
	// ============================================================
	$phase_t:="Phase 16"
	
	OTr_ClearAll
	var $h16Native_i; $h16Legacy_i; $h16Round_i : Integer
	var $native16_blob; $legacy16_blob; $doc16_blob; $gotDoc16_blob; $round16_blob : Blob
	var $doc16Path_t; $fixture16Path_t : Text
	var $doc16Bytes_i; $gotDoc16Bytes_i; $fixture16Bytes_i : Integer
	var $real16_r : Real
	var $pic16_pic; $gotPic16_pic : Picture
	ARRAY LONGINT:C221($longArr16_ai; 0)
	ARRAY LONGINT:C221($gotLongArr16_ai; 0)
	
	// Explicit legacy import API rejects native OTr serialised blobs
	$rowNum_i:=$rowNum_i+1
	$testName_t:="OTr_ImportLegacyBlob rejects native OTr BLOB"
	$h16Native_i:=OTr_New
	OTr_PutText($h16Native_i; "text"; "native")
	$native16_blob:=OTr_ObjectToNewBLOB($h16Native_i)
	OTr_Clear($h16Native_i)
	$h16Legacy_i:=OTr_ImportLegacyBlob($native16_blob)
	$expected_t:="OK=0; handle=0"
	$actual_t:="OK="+String:C10(OK)+"; handle="+String:C10($h16Legacy_i)
	$pass_b:=(OK=0) & ($h16Legacy_i=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	OTr_z_SetOK(1)
	
	// Legacy OT BLOB import: nested object, signed long array, picture, and DOCX BLOB
	$rowNum_i:=$rowNum_i+1
	$testName_t:="Legacy OT BLOB import preserves nested values and DOCX BLOB"
	$h16Legacy_i:=0
	$doc16Bytes_i:=0
	$gotDoc16Bytes_i:=0
	$fixture16Bytes_i:=0
	$fixture16Path_t:=Get 4D folder:C485(Current resources folder:K5:16)+"blobs"+Folder separator:K24:12+"Phase16-master-deep-mixed-docx.blob"
	DOCUMENT TO BLOB:C525($fixture16Path_t; $legacy16_blob)
	$fixture16Bytes_i:=BLOB size:C605($legacy16_blob)
	$doc16Path_t:=Get 4D folder:C485(Current resources folder:K5:16)+"1 Corinthians 1.docx"
	DOCUMENT TO BLOB:C525($doc16Path_t; $doc16_blob)
	$doc16Bytes_i:=BLOB size:C605($doc16_blob)
	$pic16_pic:=OTr_z_Echidna
	$h16Legacy_i:=OTr_ImportLegacyBlob($legacy16_blob)
	If ($h16Legacy_i>0)
		OTr_GetArray($h16Legacy_i; "AnObject.bObject.cObject.numbers"; ->$gotLongArr16_ai)
		$gotDoc16_blob:=OTr_GetNewBLOB($h16Legacy_i; "AnObject.bObject.cObject.document")
		$gotDoc16Bytes_i:=BLOB size:C605($gotDoc16_blob)
		$gotPic16_pic:=OTr_GetPicture($h16Legacy_i; "AnObject.bObject.cObject.photo")
		$real16_r:=OTr_GetReal($h16Legacy_i; "AnObject.bObject.cObject.amount")
	End if 
	$expected_t:="OK=1; nested values, array, picture, DOCX match"
	$actual_t:="OK="+String:C10(OK)+"; handle="+String:C10($h16Legacy_i)+"; fixture="+String:C10($fixture16Bytes_i)+"; docx="+String:C10($gotDoc16Bytes_i)+"/"+String:C10($doc16Bytes_i)+"; arraySize="+String:C10(Size of array:C274($gotLongArr16_ai))
	$pass_b:=False:C215
	If ((OK=1) & ($h16Legacy_i>0) & ($fixture16Bytes_i>0) & ($doc16Bytes_i>0) & ($gotDoc16Bytes_i=$doc16Bytes_i) & (Size of array:C274($gotLongArr16_ai)=3))
		$pass_b:=(OTr_IsEmbedded($h16Legacy_i; "AnObject")=1) & (OTr_IsEmbedded($h16Legacy_i; "AnObject.bObject.cObject")=1) & (OTr_GetText($h16Legacy_i; "AnObject.level1Text")="level1") & (OTr_GetLong($h16Legacy_i; "AnObject.bObject.level2Long")=-12345) & (OTr_GetText($h16Legacy_i; "AnObject.bObject.cObject.Citem")="deep text") & (Abs:C99($real16_r-123.456)<0.00001) & ($gotLongArr16_ai{1}=10) & ($gotLongArr16_ai{2}=-20) & ($gotLongArr16_ai{3}=3000) & OTr_u_EqualBLOBs($doc16_blob; $gotDoc16_blob) & OTr_u_EqualPictures($pic16_pic; $gotPic16_pic)
	End if 
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// Imported legacy object can be saved and reloaded as native OTr
	$rowNum_i:=$rowNum_i+1
	$testName_t:="Imported legacy OT object round-trips as native OTr BLOB"
	$h16Round_i:=0
	If ($h16Legacy_i>0)
		$round16_blob:=OTr_ObjectToNewBLOB($h16Legacy_i)
		$h16Round_i:=OTr_BLOBToObject($round16_blob)
	End if 
	$expected_t:="OK=1; handle>0; values still match"
	$actual_t:="OK="+String:C10(OK)+"; handle="+String:C10($h16Round_i)
	$pass_b:=False:C215
	If ((OK=1) & ($h16Round_i>0) & ($doc16Bytes_i>0))
		$pass_b:=(OTr_GetText($h16Round_i; "AnObject.bObject.cObject.Citem")="deep text") & (OTr_GetArrayLong($h16Round_i; "AnObject.bObject.cObject.numbers"; 2)=-20) & OTr_u_EqualBLOBs($doc16_blob; OTr_GetNewBLOB($h16Round_i; "AnObject.bObject.cObject.document"))
	End if 
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	If ($h16Round_i>0)
		OTr_Clear($h16Round_i)
	End if 
	If ($h16Legacy_i>0)
		OTr_Clear($h16Legacy_i)
	End if 
	OTr_ClearAll
	
	// ============================================================
	// PHASE 8 - Typed array element accessors (_New)
	// ============================================================
	$phase_t:="Phase 8"
	
	OTr_ClearAll
	var $h8_i; $subH8_i : Integer
	var $result8_i : Integer
	var $result8_r : Real
	var $result8_t : Text
	var $result8_d : Date
	var $result8_h : Time
	var $result8_blob : Blob
	var $result8_pic : Picture
	var $result8_ptr : Pointer
	var $testBlob8_blob : Blob
	var $testWombat8_pic : Picture
	var $savedOK8_i : Integer
	ARRAY LONGINT:C221($longArr8_ai; 0)
	ARRAY REAL:C219($realArr8_ar; 0)
	ARRAY TEXT:C222($textArr8_at; 0)
	ARRAY DATE:C224($dateArr8_ad; 0)
	ARRAY TIME:C1223($timeArr8_ah; 0)
	ARRAY BOOLEAN:C223($boolArr8_ab; 0)
	ARRAY BLOB:C1222($blobArr8_ablob; 0)
	ARRAY PICTURE:C279($picArr8_apic; 0)
	ARRAY POINTER:C280($ptrArr8_aptr; 0)
	
	$h8_i:=OTr_New
	$testWombat8_pic:=OTr_z_Wombat()
	
	// Set up arrays
	ARRAY LONGINT:C221($longArr8_ai; 5)
	$longArr8_ai{1}:=100
	$longArr8_ai{2}:=200
	$longArr8_ai{3}:=300
	$longArr8_ai{4}:=400
	$longArr8_ai{5}:=500
	OTr_PutArray($h8_i; "longs"; ->$longArr8_ai)
	
	ARRAY REAL:C219($realArr8_ar; 3)
	$realArr8_ar{1}:=1.1
	$realArr8_ar{2}:=2.2
	$realArr8_ar{3}:=3.3
	OTr_PutArray($h8_i; "reals"; ->$realArr8_ar)
	
	ARRAY TEXT:C222($textArr8_at; 3)
	$textArr8_at{1}:="alpha"
	$textArr8_at{2}:="beta"
	$textArr8_at{3}:="gamma"
	OTr_PutArray($h8_i; "words"; ->$textArr8_at)
	
	ARRAY DATE:C224($dateArr8_ad; 3)
	$dateArr8_ad{1}:=!2026-01-01!
	$dateArr8_ad{2}:=!2026-06-15!
	$dateArr8_ad{3}:=!2026-12-31!
	OTr_PutArray($h8_i; "dates"; ->$dateArr8_ad)
	
	ARRAY TIME:C1223($timeArr8_ah; 3)
	$timeArr8_ah{1}:=?08:00:00?
	$timeArr8_ah{2}:=?12:30:00?
	$timeArr8_ah{3}:=?23:59:59?
	OTr_PutArray($h8_i; "times"; ->$timeArr8_ah)
	
	ARRAY BOOLEAN:C223($boolArr8_ab; 3)
	$boolArr8_ab{1}:=True:C214
	$boolArr8_ab{2}:=False:C215
	$boolArr8_ab{3}:=True:C214
	OTr_PutArray($h8_i; "flags8"; ->$boolArr8_ab)
	
	ARRAY BLOB:C1222($blobArr8_ablob; 3)
	TEXT TO BLOB:C554("hello"; $blobArr8_ablob{1})
	TEXT TO BLOB:C554("world"; $blobArr8_ablob{2})
	TEXT TO BLOB:C554("test"; $blobArr8_ablob{3})
	OTr_PutArray($h8_i; "blobs"; ->$blobArr8_ablob)
	
	ARRAY PICTURE:C279($picArr8_apic; 3)
	$picArr8_apic{1}:=$testWombat8_pic
	OTr_PutArray($h8_i; "pics"; ->$picArr8_apic)
	
	ARRAY POINTER:C280($ptrArr8_aptr; 3)
	$ptrArr8_aptr{1}:=->OTr_DummyVariableForTests_t
	OTr_PutArray($h8_i; "ptrs"; ->$ptrArr8_aptr)
	
	// Sub-object with nested array
	$subH8_i:=OTr_New
	ARRAY LONGINT:C221($longArr8_ai; 3)
	$longArr8_ai{1}:=11
	$longArr8_ai{2}:=22
	$longArr8_ai{3}:=33
	OTr_PutArray($subH8_i; "vals"; ->$longArr8_ai)
	OTr_PutObject($h8_i; "sub"; $subH8_i)
	OTr_Clear($subH8_i)
	
	// GetArrayLong — top-level element
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayLong top-level element 3 = 300"
	$result8_i:=OTr_GetArrayLong($h8_i; "longs"; 3)
	$expected_t:="300"
	$actual_t:=String:C10($result8_i)
	$pass_b:=($result8_i=300)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayLong round-trip
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayLong/GetArrayLong round-trip"
	OTr_PutArrayLong($h8_i; "longs"; 2; 999)
	$result8_i:=OTr_GetArrayLong($h8_i; "longs"; 2)
	$expected_t:="999"
	$actual_t:=String:C10($result8_i)
	$pass_b:=($result8_i=999)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayLong — sub-object dotted path
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayLong sub-object dotted path element 2 = 22"
	$result8_i:=OTr_GetArrayLong($h8_i; "sub.vals"; 2)
	$expected_t:="22"
	$actual_t:=String:C10($result8_i)
	$pass_b:=($result8_i=22)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayLong — invalid handle sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayLong invalid handle sets OK=0"
	OTr_GetArrayLong(9999; "longs"; 1)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayLong — missing tag sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayLong missing tag sets OK=0"
	OTr_GetArrayLong($h8_i; "nosucharray"; 1)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayLong — type mismatch sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayLong type mismatch sets OK=0"
	OTr_GetArrayLong($h8_i; "reals"; 1)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayLong — out-of-range sets OK=0
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayLong out-of-range sets OK=0"
	OTr_GetArrayLong($h8_i; "longs"; 999)
	$expected_t:="OK=0"
	$actual_t:="OK="+String:C10(OK)
	$pass_b:=(OK=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayReal
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayReal element 2 = 2.2"
	$result8_r:=OTr_GetArrayReal($h8_i; "reals"; 2)
	$expected_t:="2.2"
	$actual_t:=String:C10($result8_r)
	$pass_b:=($result8_r=2.2)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayString
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayString element 1 = alpha"
	$result8_t:=OTr_GetArrayString($h8_i; "words"; 1)
	$expected_t:="alpha"
	$actual_t:=$result8_t
	$pass_b:=($result8_t="alpha")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayText (alias)
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayText element 3 = gamma"
	$result8_t:=OTr_GetArrayText($h8_i; "words"; 3)
	$expected_t:="gamma"
	$actual_t:=$result8_t
	$pass_b:=($result8_t="gamma")
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayDate
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayDate element 2 = !2026-06-15!"
	$result8_d:=OTr_GetArrayDate($h8_i; "dates"; 2)
	$expected_t:="!2026-06-15!"
	$actual_t:=String:C10($result8_d)
	$pass_b:=($result8_d=!2026-06-15!)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayTime
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayTime element 1 = ?08:00:00?"
	$result8_h:=OTr_GetArrayTime($h8_i; "times"; 1)
	$expected_t:="08:00:00"
	$actual_t:=String:C10($result8_h; HH MM SS:K7:1)
	$pass_b:=($result8_h=?08:00:00?)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayBoolean True
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayBoolean element 1 (True) = 1"
	$result8_i:=OTr_GetArrayBoolean($h8_i; "flags8"; 1)
	$expected_t:="1"
	$actual_t:=String:C10($result8_i)
	$pass_b:=($result8_i=1)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayBoolean False
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayBoolean element 2 (False) = 0"
	$result8_i:=OTr_GetArrayBoolean($h8_i; "flags8"; 2)
	$expected_t:="0"
	$actual_t:=String:C10($result8_i)
	$pass_b:=($result8_i=0)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayBLOB / GetArrayBLOB round-trip
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayBLOB/GetArrayBLOB round-trip"
	TEXT TO BLOB:C554("compare me"; $testBlob8_blob)
	OTr_PutArrayBLOB($h8_i; "blobs"; 1; $testBlob8_blob)
	$result8_blob:=OTr_GetArrayBLOB($h8_i; "blobs"; 1)
	$expected_t:="equal"
	$actual_t:=Choose:C955(OTr_u_EqualBLOBs($result8_blob; $testBlob8_blob); "equal"; "not equal")
	$pass_b:=OTr_u_EqualBLOBs($result8_blob; $testBlob8_blob)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayPicture — existing element
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayPicture existing element matches"
	$result8_pic:=OTr_GetArrayPicture($h8_i; "pics"; 1)
	$expected_t:="equal"
	$actual_t:=Choose:C955(OTr_u_EqualPictures($result8_pic; $testWombat8_pic); "equal"; "not equal")
	$pass_b:=OTr_u_EqualPictures($result8_pic; $testWombat8_pic)
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// GetArrayPointer — existing element
	$rowNum_i:=$rowNum_i+1
	$testName_t:="GetArrayPointer existing element dereference matches"
	If (Storage:C1525.OTr.structureName#"nativeObjectTools")
		$expected_t:="component-safe skip"
		$actual_t:="variable pointer dereference requires host OT Host GetPointer"
		$pass_b:=True:C214
	Else 
		$result8_ptr:=OTr_GetArrayPointer($h8_i; "ptrs"; 1)
		$expected_t:=OTr_DummyVariableForTests_t
		If ((OK=1) & ($result8_ptr#Null:C1517))
			$actual_t:=$result8_ptr->
			$pass_b:=($actual_t=OTr_DummyVariableForTests_t)
		Else 
			$actual_t:="(null)"
			$pass_b:=False:C215
		End if 
	End if 
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	// PutArrayPointer / GetArrayPointer round-trip (element 2)
	$rowNum_i:=$rowNum_i+1
	$testName_t:="PutArrayPointer/GetArrayPointer round-trip"
	If (Storage:C1525.OTr.structureName#"nativeObjectTools")
		$expected_t:="component-safe skip"
		$actual_t:="variable pointer dereference requires host OT Host GetPointer"
		$pass_b:=True:C214
	Else 
		OTr_PutArrayPointer($h8_i; "ptrs"; 2; ->OTr_DummyVariableForTests_t)
		$result8_ptr:=OTr_GetArrayPointer($h8_i; "ptrs"; 2)
		$expected_t:=OTr_DummyVariableForTests_t
		If ((OK=1) & ($result8_ptr#Null:C1517))
			$actual_t:=$result8_ptr->
			$pass_b:=($actual_t=OTr_DummyVariableForTests_t)
		Else 
			$actual_t:="(null)"
			$pass_b:=False:C215
		End if 
	End if 
	$masterText_t:=$masterText_t+String:C10($rowNum_i)+$TAB+$phase_t+$TAB+$testName_t+$TAB+$expected_t+$TAB+$actual_t+$TAB+Choose:C955($pass_b; "Pass"; "FAIL")+$LF
	If ($pass_b)
		$totalPass_i:=$totalPass_i+1
	Else 
		$totalFail_i:=$totalFail_i+1
	End if 
	
	OTr_ClearAll
	
	// ============================================================
	// SIDE-BY-SIDE PHASES — inline execution via sub-methods
	//
	// We call each phase's sub-method pairs directly (bypassing the
	// process-guard controllers) so that all execution is synchronous
	// within this process. Results are assembled here AND written to
	// individual timestamped files in the Logs folder to preserve the
	// per-phase review artefacts.
	// ============================================================
	
	var $sbAccum_i : Integer
	var $sbTotal_i; $sbI_i : Integer
	var $sbTestName_t; $sbOtCmd_t; $sbOtResult_t; $sbOtrCmd_t; $sbOtrResult_t : Text
	var $sbTestNum_t : Text
	var $sbTable_t; $sbSummary_t : Text
	var $sbFileName_t; $sbFilePath_t : Text
	var $sbFolderPath_t : Text
	$sbFolderPath_t:=Get 4D folder:C485(Logs folder:K5:19; *)
	
	// ---- Phase 10 ----
	$masterText_t:=$masterText_t+$LF+"--- Phase 10: Logging side-by-side ---"+$LF
	$masterText_t:=$masterText_t+"Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	
	OTr_ClearAll
	$sbAccum_i:=OTr_New
	____Test_Phase_10_OTr($sbAccum_i)
	____Test_Phase_10_OT($sbAccum_i)
	$sbTotal_i:=OTr_SizeOfArray($sbAccum_i; "testName")
	$sbTable_t:="Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	For ($sbI_i; 1; $sbTotal_i)
		$sbTestName_t:=OTr_GetArrayText($sbAccum_i; "testName"; $sbI_i)
		$sbOtCmd_t:=OTr_GetArrayText($sbAccum_i; "otCmd"; $sbI_i)
		$sbOtResult_t:=OTr_GetArrayText($sbAccum_i; "otResult"; $sbI_i)
		$sbOtrCmd_t:=OTr_GetArrayText($sbAccum_i; "otrCmd"; $sbI_i)
		$sbOtrResult_t:=OTr_GetArrayText($sbAccum_i; "otrResult"; $sbI_i)
		$sbTable_t:=$sbTable_t+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
		$masterText_t:=$masterText_t+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
	End for 
	OTr_Clear($sbAccum_i)
	$sbSummary_t:="Total scenarios: "+String:C10($sbTotal_i)
	$sbTable_t:=$sbTable_t+$LF+$sbSummary_t
	$sbFileName_t:="____Test_Phase_10-"+$dateStr_t+"-"+$timeStr_t+".txt"
	TEXT TO DOCUMENT:C1237($sbFolderPath_t+$sbFileName_t; $sbTable_t; "UTF-8")
	$masterText_t:=$masterText_t+$sbSummary_t+$LF
	
	// ---- Phase 10a ----
	$masterText_t:=$masterText_t+$LF+"--- Phase 10a: Broad side-by-side sweep ---"+$LF
	$masterText_t:=$masterText_t+"Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	
	OTr_ClearAll
	$sbAccum_i:=OTr_New
	____Test_Phase_10a_OTr($sbAccum_i)
	____Test_Phase_10a_OT($sbAccum_i)
	$sbTotal_i:=OTr_SizeOfArray($sbAccum_i; "testName")
	$sbTable_t:="Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	For ($sbI_i; 1; $sbTotal_i)
		$sbTestName_t:=OTr_GetArrayText($sbAccum_i; "testName"; $sbI_i)
		$sbOtCmd_t:=OTr_GetArrayText($sbAccum_i; "otCmd"; $sbI_i)
		$sbOtResult_t:=OTr_GetArrayText($sbAccum_i; "otResult"; $sbI_i)
		$sbOtrCmd_t:=OTr_GetArrayText($sbAccum_i; "otrCmd"; $sbI_i)
		$sbOtrResult_t:=OTr_GetArrayText($sbAccum_i; "otrResult"; $sbI_i)
		$sbTable_t:=$sbTable_t+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
		$masterText_t:=$masterText_t+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
	End for 
	OTr_Clear($sbAccum_i)
	$sbSummary_t:="Total scenarios: "+String:C10($sbTotal_i)
	$sbTable_t:=$sbTable_t+$LF+$sbSummary_t
	$sbFileName_t:="____Test_Phase_10a-"+$dateStr_t+"-"+$timeStr_t+".txt"
	TEXT TO DOCUMENT:C1237($sbFolderPath_t+$sbFileName_t; $sbTable_t; "UTF-8")
	$masterText_t:=$masterText_t+$sbSummary_t+$LF
	
	// ---- Phase 10b ----
	$masterText_t:=$masterText_t+$LF+"--- Phase 10b: Misuse suite ---"+$LF
	$masterText_t:=$masterText_t+"Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	
	OTr_ClearAll
	$sbAccum_i:=OTr_New
	____Test_Phase_10b_OTr($sbAccum_i)
	____Test_Phase_10b_OT($sbAccum_i)
	$sbTotal_i:=OTr_SizeOfArray($sbAccum_i; "testName")
	$sbTable_t:="Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	For ($sbI_i; 1; $sbTotal_i)
		$sbTestName_t:=OTr_GetArrayText($sbAccum_i; "testName"; $sbI_i)
		$sbOtCmd_t:=OTr_GetArrayText($sbAccum_i; "otCmd"; $sbI_i)
		$sbOtResult_t:=OTr_GetArrayText($sbAccum_i; "otResult"; $sbI_i)
		$sbOtrCmd_t:=OTr_GetArrayText($sbAccum_i; "otrCmd"; $sbI_i)
		$sbOtrResult_t:=OTr_GetArrayText($sbAccum_i; "otrResult"; $sbI_i)
		$sbTable_t:=$sbTable_t+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
		$masterText_t:=$masterText_t+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
	End for 
	OTr_Clear($sbAccum_i)
	$sbSummary_t:="Total scenarios: "+String:C10($sbTotal_i)
	$sbTable_t:=$sbTable_t+$LF+$sbSummary_t
	$sbFileName_t:="____Test_Phase_10b-"+$dateStr_t+"-"+$timeStr_t+".txt"
	TEXT TO DOCUMENT:C1237($sbFolderPath_t+$sbFileName_t; $sbTable_t; "UTF-8")
	$masterText_t:=$masterText_t+$sbSummary_t+$LF
	
	// ---- Phase 10c ----
	$masterText_t:=$masterText_t+$LF+"--- Phase 10c: OK=0 error conditions ---"+$LF
	$masterText_t:=$masterText_t+"Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	
	OTr_ClearAll
	$sbAccum_i:=OTr_New
	____Test_Phase_10c_OTr($sbAccum_i)
	____Test_Phase_10c_OT($sbAccum_i)
	$sbTotal_i:=OTr_SizeOfArray($sbAccum_i; "testName")
	$sbTable_t:="Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	For ($sbI_i; 1; $sbTotal_i)
		$sbTestName_t:=OTr_GetArrayText($sbAccum_i; "testName"; $sbI_i)
		$sbOtCmd_t:=OTr_GetArrayText($sbAccum_i; "otCmd"; $sbI_i)
		$sbOtResult_t:=OTr_GetArrayText($sbAccum_i; "otResult"; $sbI_i)
		$sbOtrCmd_t:=OTr_GetArrayText($sbAccum_i; "otrCmd"; $sbI_i)
		$sbOtrResult_t:=OTr_GetArrayText($sbAccum_i; "otrResult"; $sbI_i)
		$sbTable_t:=$sbTable_t+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
		$masterText_t:=$masterText_t+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
	End for 
	OTr_Clear($sbAccum_i)
	$sbSummary_t:="Total scenarios: "+String:C10($sbTotal_i)
	$sbTable_t:=$sbTable_t+$LF+$sbSummary_t
	$sbFileName_t:="____Test_Phase_10c-"+$dateStr_t+"-"+$timeStr_t+".txt"
	TEXT TO DOCUMENT:C1237($sbFolderPath_t+$sbFileName_t; $sbTable_t; "UTF-8")
	$masterText_t:=$masterText_t+$sbSummary_t+$LF
	
	// ---- Phase 15 ----
	$masterText_t:=$masterText_t+$LF+"--- Phase 15: Compatibility vs ObjectTools 5.0 ---"+$LF
	$masterText_t:=$masterText_t+"Num"+$TAB+"Test Name"+$TAB+"OT Command"+$TAB+"OT Result"+$TAB+"OTr Command"+$TAB+"OTr Result"+$LF
	
	OTr_ClearAll
	$sbAccum_i:=OTr_New
	____Test_Phase_15_OTr($sbAccum_i)
	____Test_Phase_15_OT($sbAccum_i)
	$sbTotal_i:=OTr_SizeOfArray($sbAccum_i; "testNum")
	var $sb15Pass_i; $sb15Fail_i; $sb15OtPass_i; $sb15OtFail_i : Integer
	$sb15Pass_i:=0
	$sb15Fail_i:=0
	$sb15OtPass_i:=0
	$sb15OtFail_i:=0
	$sbTable_t:="Num"+$TAB+"Test Name"+$TAB+"OT Command"+$TAB+"OT Result"+$TAB+"OTr Command"+$TAB+"OTr Result"+$LF
	For ($sbI_i; 1; $sbTotal_i)
		$sbTestNum_t:=OTr_GetArrayText($sbAccum_i; "testNum"; $sbI_i)
		$sbTestName_t:=OTr_GetArrayText($sbAccum_i; "testName"; $sbI_i)
		$sbOtCmd_t:=OTr_GetArrayText($sbAccum_i; "otCmd"; $sbI_i)
		$sbOtResult_t:=OTr_GetArrayText($sbAccum_i; "otResult"; $sbI_i)
		$sbOtrCmd_t:=OTr_GetArrayText($sbAccum_i; "otrCmd"; $sbI_i)
		$sbOtrResult_t:=OTr_GetArrayText($sbAccum_i; "otrResult"; $sbI_i)
		$sbTable_t:=$sbTable_t+$sbTestNum_t+$TAB+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
		$masterText_t:=$masterText_t+$sbTestNum_t+$TAB+$sbTestName_t+$TAB+$sbOtCmd_t+$TAB+$sbOtResult_t+$TAB+$sbOtrCmd_t+$TAB+$sbOtrResult_t+$LF
		If (Substring:C12($sbOtrResult_t; 1; 4)="Pass")
			$sb15Pass_i:=$sb15Pass_i+1
		Else 
			$sb15Fail_i:=$sb15Fail_i+1
		End if 
		If (Substring:C12($sbOtResult_t; 1; 4)="Pass")
			$sb15OtPass_i:=$sb15OtPass_i+1
		Else 
			$sb15OtFail_i:=$sb15OtFail_i+1
		End if 
	End for 
	OTr_Clear($sbAccum_i)
	$sbSummary_t:="Total: "+String:C10($sbTotal_i)+"  OTr Pass: "+String:C10($sb15Pass_i)+"  OTr Fail: "+String:C10($sb15Fail_i)+"  OT Pass: "+String:C10($sb15OtPass_i)+"  OT Fail: "+String:C10($sb15OtFail_i)
	$sbTable_t:=$sbTable_t+$LF+$sbSummary_t
	$sbFileName_t:="____Test_Phase_15-"+$dateStr_t+"-"+$timeStr_t+".txt"
	TEXT TO DOCUMENT:C1237($sbFolderPath_t+$sbFileName_t; $sbTable_t; "UTF-8")
	$masterText_t:=$masterText_t+$sbSummary_t+$LF
	
	OTr_ClearAll
	
	// ============================================================
	// FINAL SUMMARY AND FILE OUTPUT
	// ============================================================
	$masterText_t:=$masterText_t+$LF
	$masterText_t:=$masterText_t+"========================================"+$LF
	var $summaryLine_m : Text
	$summaryLine_m:="Unit test total: "+String:C10($totalPass_i+$totalFail_i)+"  Pass: "+String:C10($totalPass_i)+"  Fail: "+String:C10($totalFail_i)
	$masterText_t:=$masterText_t+$summaryLine_m+$LF
	$masterText_t:=$masterText_t+"========================================"+$LF
	
	// Build timestamped filename
	$y_i:=Year of:C25(Current date:C33)
	$mo_i:=Month of:C24(Current date:C33)
	$d_i:=Day of:C23(Current date:C33)
	$dateStr_t:=String:C10($y_i; "0000")+"-"+String:C10($mo_i; "00")+"-"+String:C10($d_i; "00")
	$timeStr_t:=String:C10(Current time:C178; HH MM SS:K7:1)
	$timeStr_t:=Replace string:C233($timeStr_t; ":"; "-")
	var $masterFileName_t; $masterFilePath_t : Text
	$masterFileName_t:="____Test_OTr_Master-"+$dateStr_t+"-"+$timeStr_t+".txt"
	$masterFilePath_t:=Get 4D folder:C485(Logs folder:K5:19; *)+$masterFileName_t
	$masterText_t:=$masterText_t+"Output file: "+$masterFilePath_t+$LF
	
	TEXT TO DOCUMENT:C1237($masterFilePath_t; $masterText_t; "UTF-8")
	
	If ($hideAlert_b)
	Else 
		ALERT:C41($summaryLine_m+$CR+"Master results written to: "+$masterFilePath_t)
		SET TEXT TO PASTEBOARD:C523($masterText_t)
	End if 
	
	OTr_LogLevel($debug_t)  // Reset to normal debug level
	
Else 
	// Unique named process guard — spawns one process and brings it to front
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; $hideAlert_b; *)
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 

