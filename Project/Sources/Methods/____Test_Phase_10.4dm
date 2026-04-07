//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10

// Controller for the Phase 10 logging-focused side-by-side
// test. Deliberately exercises OTr and ObjectTools 5.0 with
// logically wrong (but syntactically valid) calls so both
// implementations emit representative error-condition log
// entries. Delegates execution to:
//   ____Test_Phase_10_OTr ($accum_i) -- OTr execution
//   ____Test_Phase_10_OT  ($accum_i) -- OT  execution
//
// After both sub-methods return, assembles a five-column
// TAB-delimited table and writes a timestamped UTF-8 text
// file to the 4D Logs folder.
//
// PLATFORM NOTE: On macOS Tahoe 26.4+ where the ObjectTools
// plugin is absent, the body of ____Test_Phase_10_OT must be
// commented out. This controller and ____Test_Phase_10_OTr
// compile and run normally on all platforms.
//
// Output columns:
//   Test Name | OT Test | OT Result | OTr Test | OTr Result
//
// Access: Private
//
// Returns: Nothing (results written to Logs folder)
//
// Created by Wayne Stewart / Codex, 2026-04-06
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Refactored from monolithic
//   method into controller + OTr/OT sub-methods following
//   the same pattern as ____Test_Phase_15.
// ----------------------------------------------------
var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t : Text

// ----------------------------------------------------

$StackSize_i:=0
$DesiredProcessName_t:=Current method name

If (Current process name=$DesiredProcessName_t)

	// ====================================================
	// INIT ACCUMULATOR
	// ====================================================
	OTr_ClearAll
	var $accum_i : Integer
	$accum_i:=OTr_New

	// ====================================================
	// EXECUTE SUB-METHODS
	// OTr sub-method runs first; it bulk-loads three array
	// columns into the accumulator (otCmd and otResult are
	// pre-seeded as empty arrays of the correct length).
	// OT sub-method then updates otCmd and otResult by index.
	// ====================================================
	____Test_Phase_10_OTr ($accum_i)
	____Test_Phase_10_OT ($accum_i)

	// ====================================================
	// READ RESULTS FROM ACCUMULATOR
	// ====================================================
	var $total_i : Integer
	var $i_i : Integer
	var $testName_t : Text
	var $otCmd_t; $otResult_t; $otrCmd_t; $otrResult_t : Text
	var $TAB; $LF; $tableText_t; $summaryLine_t : Text
	var $desktopPath_t; $fileName_t; $filePath_t : Text
	var $dateStr_t; $timeStr_t : Text
	var $y_i; $mo_i; $d_i : Integer

	$TAB:=Char(Tab)
	$LF:=Char(Line feed)

	$total_i:=OTr_SizeOfArray($accum_i; "testName")

	// Header row
	$tableText_t:="Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF

	// Data rows
	For ($i_i; 1; $total_i)
		$testName_t:=OTr_GetArrayText($accum_i; "testName"; $i_i)
		$otCmd_t:=OTr_GetArrayText($accum_i; "otCmd"; $i_i)
		$otResult_t:=OTr_GetArrayText($accum_i; "otResult"; $i_i)
		$otrCmd_t:=OTr_GetArrayText($accum_i; "otrCmd"; $i_i)
		$otrResult_t:=OTr_GetArrayText($accum_i; "otrResult"; $i_i)
		$tableText_t:=$tableText_t+$testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF
	End for

	// ====================================================
	// TEARDOWN ACCUMULATOR
	// ====================================================
	OTr_Clear($accum_i)

	// ====================================================
	// ASSEMBLE SUMMARY AND WRITE FILE
	// ====================================================
	$summaryLine_t:="Total scenarios: "+String($total_i)
	$tableText_t:=$tableText_t+$LF+$summaryLine_t

	$y_i:=Year of(Current date)
	$mo_i:=Month of(Current date)
	$d_i:=Day of(Current date)
	$dateStr_t:=String($y_i; "0000")+"-"+String($mo_i; "00")+"-"+String($d_i; "00")
	$timeStr_t:=String(Current time; HH MM SS)
	$timeStr_t:=Replace string($timeStr_t; ":"; "-")
	$fileName_t:="____Test_Phase_10-"+$dateStr_t+"-"+$timeStr_t+".txt"

	$desktopPath_t:=Get 4D folder(Logs folder)
	$filePath_t:=$desktopPath_t+$fileName_t

	TEXT TO DOCUMENT($filePath_t; $tableText_t; "UTF-8")
	SHOW ON DISK($filePath_t)
	ALERT($summaryLine_t+Char(Carriage return)+"Results written to: "+$fileName_t)
	SET TEXT TO PASTEBOARD($tableText_t)

Else
	// This version allows for one unique process
	$ProcessID_i:=New process(Current method name; $StackSize_i; $DesiredProcessName_t; *)

	RESUME PROCESS($ProcessID_i)
	SHOW PROCESS($ProcessID_i)
	BRING TO FRONT($ProcessID_i)
End if

