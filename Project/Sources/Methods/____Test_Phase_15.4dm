//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_15

// Controller for the Phase 15 side-by-side compatibility test.
// Exercises each OTr method against its ObjectTools 5.0 counterpart
// using identical test data, delegating the two halves to:
//   ____Test_Phase_15_OTr ($accum_i) -- OTr execution, bulk-loads accumulator
//   ____Test_Phase_15_OT  ($accum_i) -- OT  execution, updates accumulator by index
//
// After both sub-methods return, tallies results, assembles a
// six-column TAB-delimited table, and writes a timestamped UTF-8
// text file to the 4D Logs folder.
//
// PLATFORM NOTE: On macOS Tahoe 26.4+ where the ObjectTools plugin
// is absent, the body of ____Test_Phase_15_OT must be commented out.
// This controller and ____Test_Phase_15_OTr compile and run normally
// on all platforms.
//
// Output columns: Num | Test Name | OT Command | OT Result | OTr Command | OTr Result
//
// Access: Private
//
// Returns: Nothing (results written to Logs folder)
//
// Created by Wayne Stewart / Claude, 2026-04-07
// Refactored from monolithic ____Test_Phase_15 by Wayne Stewart.
// Based on work by himself, Rob Laveaux, Guy Algot, and Cannon Smith.
// ----------------------------------------------------
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
	
	// ====================================================
	// INIT ACCUMULATOR
	// ====================================================
	OTr_ClearAll
	var $accum_i : Integer
	$accum_i:=OTr_New
	
	// ====================================================
	// EXECUTE SUB-METHODS
	// OTr sub-method runs first; it bulk-loads all six
	// array columns into the accumulator (otCmd and otResult
	// are pre-seeded as empty arrays of the correct length).
	// OT sub-method then updates otCmd and otResult by index.
	// ====================================================
	____Test_Phase_15_OTr($accum_i)
	____Test_Phase_15_OT($accum_i)
	
	// ====================================================
	// READ RESULTS FROM ACCUMULATOR
	// ====================================================
	var $total_i; $otrPass_i; $otrFail_i; $otPass_i; $otFail_i : Integer
	var $i_i : Integer
	var $testNum_t; $testName_t : Text
	var $otCmd_t; $otResult_t; $otrCmd_t; $otrResult_t : Text
	var $TAB; $LF; $tableText_t; $summaryLine_t : Text
	var $desktopPath_t; $fileName_t; $filePath_t : Text
	var $dateStr_t; $timeStr_t : Text
	var $y_i; $mo_i; $d_i : Integer
	
	$TAB:=Char:C90(Tab:K15:37)
	$LF:=Char:C90(Line feed:K15:40)
	
	$total_i:=OTr_SizeOfArray($accum_i; "testNum")
	$otrPass_i:=0
	$otrFail_i:=0
	$otPass_i:=0
	$otFail_i:=0
	
	// Header row
	$tableText_t:="Num"+$TAB+"Test Name"+$TAB+"OT Command"+$TAB+"OT Result"+$TAB+"OTr Command"+$TAB+"OTr Result"+$LF
	
	// Data rows
	For ($i_i; 1; $total_i)
		
		$testNum_t:=OTr_GetArrayText($accum_i; "testNum"; $i_i)
		$testName_t:=OTr_GetArrayText($accum_i; "testName"; $i_i)
		$otCmd_t:=OTr_GetArrayText($accum_i; "otCmd"; $i_i)
		$otResult_t:=OTr_GetArrayText($accum_i; "otResult"; $i_i)
		$otrCmd_t:=OTr_GetArrayText($accum_i; "otrCmd"; $i_i)
		$otrResult_t:=OTr_GetArrayText($accum_i; "otrResult"; $i_i)
		
		$tableText_t:=$tableText_t+$testNum_t+$TAB+$testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF
		
		If (Substring:C12($otrResult_t; 1; 4)="Pass")
			$otrPass_i:=$otrPass_i+1
		Else 
			$otrFail_i:=$otrFail_i+1
		End if 
		
		If (Substring:C12($otResult_t; 1; 4)="Pass")
			$otPass_i:=$otPass_i+1
		Else 
			$otFail_i:=$otFail_i+1
		End if 
		
	End for 
	
	// ====================================================
	// TEARDOWN ACCUMULATOR
	// ====================================================
	OTr_Clear($accum_i)
	
	// ====================================================
	// ASSEMBLE SUMMARY AND WRITE FILE
	// ====================================================
	$summaryLine_t:="Total: "+String:C10($total_i)+"  OTr Pass: "+String:C10($otrPass_i)+"  OTr Fail: "+String:C10($otrFail_i)+"  OT Pass: "+String:C10($otPass_i)+"  OT Fail: "+String:C10($otFail_i)
	$tableText_t:=$tableText_t+$LF+$summaryLine_t
	
	// Build timestamp filename: ____Test_Phase_15-YYYY-MM-DD-HH-MM-SS.txt
	$y_i:=Year of:C25(Current date:C33)
	$mo_i:=Month of:C24(Current date:C33)
	$d_i:=Day of:C23(Current date:C33)
	$dateStr_t:=String:C10($y_i; "0000")+"-"+String:C10($mo_i; "00")+"-"+String:C10($d_i; "00")
	$timeStr_t:=String:C10(Current time:C178; HH MM SS:K7:1)
	$timeStr_t:=Replace string:C233($timeStr_t; ":"; "-")
	$fileName_t:="____Test_Phase_15-"+$dateStr_t+"-"+$timeStr_t+".txt"
	
	$desktopPath_t:=Get 4D folder:C485(Logs folder:K5:19; *)
	$filePath_t:=$desktopPath_t+$fileName_t
	
	TEXT TO DOCUMENT:C1237($filePath_t; $tableText_t; "UTF-8")
	// show on disk($filePath_t)
	If ($hideAlert_b)
	Else 
		ALERT:C41($summaryLine_t+Char:C90(Carriage return:K15:38)+"Results written to: "+$fileName_t)
		SET TEXT TO PASTEBOARD:C523($tableText_t)
	End if 
Else 
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; $hideAlert_b; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 

