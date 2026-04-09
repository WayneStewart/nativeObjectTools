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
#DECLARE($suppressAlert_b : Boolean)

var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t : Text

$StackSize_i:=0
$DesiredProcessName_t:=Current method name:C684

$suppressAlert_b:=Choose:C955(Count parameters:C259=1; $suppressAlert_b; False:C215)


If (Current process name:C1392=$DesiredProcessName_t)
	
	// ====================================================
	// INIT ACCUMULATOR
	// ====================================================
	OT ClearAll
	var $accum_i : Integer
	$accum_i:=OT New
	
	// ====================================================
	// EXECUTE SUB-METHODS
	// OTr sub-method runs first; it bulk-loads three array
	// columns into the accumulator (otCmd and otResult are
	// pre-seeded as empty arrays of the correct length).
	// OT sub-method then updates otCmd and otResult by index.
	// ====================================================
	____Test_Phase_10_OTr($accum_i)
	____Test_Phase_10_OT($accum_i)
	
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
	
	$TAB:=Char:C90(Tab:K15:37)
	$LF:=Char:C90(Line feed:K15:40)
	
	$total_i:=OT SizeOfArray($accum_i; "testName")
	
	// Header row
	$tableText_t:="Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	
	// Data rows
	For ($i_i; 1; $total_i)
		$testName_t:=OT GetArrayText($accum_i; "testName"; $i_i)
		$otCmd_t:=OT GetArrayText($accum_i; "otCmd"; $i_i)
		$otResult_t:=OT GetArrayText($accum_i; "otResult"; $i_i)
		$otrCmd_t:=OT GetArrayText($accum_i; "otrCmd"; $i_i)
		$otrResult_t:=OT GetArrayText($accum_i; "otrResult"; $i_i)
		$tableText_t:=$tableText_t+$testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF
	End for 
	
	// ====================================================
	// TEARDOWN ACCUMULATOR
	// ====================================================
	OT Clear($accum_i)
	
	// ====================================================
	// ASSEMBLE SUMMARY AND WRITE FILE
	// ====================================================
	$summaryLine_t:="Total scenarios: "+String:C10($total_i)
	$tableText_t:=$tableText_t+$LF+$summaryLine_t
	
	$y_i:=Year of:C25(Current date:C33)
	$mo_i:=Month of:C24(Current date:C33)
	$d_i:=Day of:C23(Current date:C33)
	$dateStr_t:=String:C10($y_i; "0000")+"-"+String:C10($mo_i; "00")+"-"+String:C10($d_i; "00")
	$timeStr_t:=String:C10(Current time:C178; HH MM SS:K7:1)
	$timeStr_t:=Replace string:C233($timeStr_t; ":"; "-")
	$fileName_t:="____Test_Phase_10-"+$dateStr_t+"-"+$timeStr_t+".txt"
	
	$desktopPath_t:=Get 4D folder:C485(Logs folder:K5:19)
	$filePath_t:=$desktopPath_t+$fileName_t
	
	TEXT TO DOCUMENT:C1237($filePath_t; $tableText_t; "UTF-8")
	SHOW ON DISK:C922($filePath_t)
	If ($suppressAlert_b)
	Else 
		ALERT:C41($summaryLine_t+Char:C90(Carriage return:K15:38)+"Results written to: "+$fileName_t)
		SET TEXT TO PASTEBOARD:C523($tableText_t)
	End if 
Else 
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; $suppressAlert_b; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 

