//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10b

// Controller for the Phase 10b misuse suite.
// Delegates execution to:
//   ____Test_Phase_10b_OTr ($accum_i)
//   ____Test_Phase_10b_OT  ($accum_i)
//
// After both sub-methods return, writes a five-column
// TAB-delimited table to the Logs folder.
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
//   method into controller + OTr/OT sub-methods.
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
	OTr_ClearAll
	var $accum_i : Integer
	$accum_i:=OTr_New
	
	____Test_Phase_10b_OTr($accum_i)
	____Test_Phase_10b_OT($accum_i)
	
	var $total_i : Integer
	var $i_i : Integer
	var $testName_t : Text
	var $otCmd_t; $otResult_t; $otrCmd_t; $otrResult_t : Text
	var $TAB; $LF; $tableText_t; $summaryLine_t : Text
	var $folderPath_t; $fileName_t; $filePath_t : Text
	var $dateStr_t; $timeStr_t : Text
	var $y_i; $mo_i; $d_i : Integer
	
	$TAB:=Char:C90(Tab:K15:37)
	$LF:=Char:C90(Line feed:K15:40)
	$total_i:=OTr_SizeOfArray($accum_i; "testName")
	
	$tableText_t:="Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF
	
	For ($i_i; 1; $total_i)
		$testName_t:=OTr_GetArrayText($accum_i; "testName"; $i_i)
		$otCmd_t:=OTr_GetArrayText($accum_i; "otCmd"; $i_i)
		$otResult_t:=OTr_GetArrayText($accum_i; "otResult"; $i_i)
		$otrCmd_t:=OTr_GetArrayText($accum_i; "otrCmd"; $i_i)
		$otrResult_t:=OTr_GetArrayText($accum_i; "otrResult"; $i_i)
		$tableText_t:=$tableText_t+$testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF
	End for 
	
	OTr_Clear($accum_i)
	
	$summaryLine_t:="Total scenarios: "+String:C10($total_i)
	$tableText_t:=$tableText_t+$LF+$summaryLine_t
	
	$y_i:=Year of:C25(Current date:C33)
	$mo_i:=Month of:C24(Current date:C33)
	$d_i:=Day of:C23(Current date:C33)
	$dateStr_t:=String:C10($y_i; "0000")+"-"+String:C10($mo_i; "00")+"-"+String:C10($d_i; "00")
	$timeStr_t:=String:C10(Current time:C178; HH MM SS:K7:1)
	$timeStr_t:=Replace string:C233($timeStr_t; ":"; "-")
	$fileName_t:="____Test_Phase_10b-"+$dateStr_t+"-"+$timeStr_t+".txt"
	
	$folderPath_t:=Get 4D folder:C485(Logs folder:K5:19)
	$filePath_t:=$folderPath_t+$fileName_t
	
	TEXT TO DOCUMENT:C1237($filePath_t; $tableText_t; "UTF-8")
	// show on disk($filePath_t)
	If ($hideAlert_b)
	Else 
		ALERT:C41($summaryLine_t+Char:C90(Carriage return:K15:38)+"Results written to: "+$fileName_t)
		SET TEXT TO PASTEBOARD:C523($tableText_t)
	End if 
Else 
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; $hideAlert_b; *)
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 
