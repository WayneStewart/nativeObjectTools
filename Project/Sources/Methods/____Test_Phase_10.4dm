//%attributes = {"invisible":true,"shared":false}

// Entire method commented out to allow for compiling when plugin is not present.

/*
// ----------------------------------------------------
// Project Method: ____Test_Phase_10

// Logging-focused side-by-side test. Deliberately performs
// valid 4D calls that are logically wrong, so the legacy
// ObjectTools plugin and OTr both encounter runtime error
// conditions that may be emitted to their respective logs.
//
// The intention is not pass/fail compatibility. The main
// goal is to generate representative log entries, especially
// error cases, whilst also capturing the immediate return
// values and OK state for reference.
//
// Output: TAB-delimited results table written to the Logs
// folder with a timestamped filename, then shown on disk.
//
// PLATFORM REQUIREMENT: ObjectTools 5.0 must be installed
// as a plugin. The method aborts with an ALERT if OT New
// returns 0.
//
// Access: Private
//
// Returns: Nothing (results written to logs folder)
//
// Created by Wayne Stewart / Codex, 2026-04-06
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t : Text

// ----------------------------------------------------

$StackSize_i:=0
$DesiredProcessName_t:=Current method name:C684

If (Current process name:C1392=$DesiredProcessName_t)

	var $ready_b : Boolean
	var $otMain_i : Integer
	var $otrMain_i : Integer
	var $testOtH_i : Integer
	var $total_i; $pass_i; $fail_i : Integer
	var $testName_t : Text
	var $otCmd_t : Text
	var $otrCmd_t : Text
	var $otResult_t : Text
	var $otrResult_t : Text
	var $summaryLine_t : Text
	var $tableText_t : Text
	var $desktopPath_t : Text
	var $fileName_t : Text
	var $filePath_t : Text
	var $dateStr_t : Text
	var $timeStr_t : Text
	var $y_i; $mo_i; $d_i : Integer
	var $i_i : Integer
	var $reg_i : Integer
	var $gotLong_i : Integer
	var $size_i : Integer
	var $compare_i : Integer
	var $dummy_t : Text
	var $gotPtr_ptr : Pointer
	var $TAB; $LF : Text

	$TAB:=Char:C90(Tab:K15:37)
	$LF:=Char:C90(Line feed:K15:40)

	ARRAY TEXT:C222($rows_at; 0)

	// ====================================================
	// CHECK OT AVAILABLE
	// ====================================================
	$ready_b:=True:C214

	$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")
	$testOtH_i:=OT New

	If ($testOtH_i=0)
		ALERT:C41("ObjectTools 5.0 is not available or not registered. "+Char:C90(Carriage return:K15:38)+"Ensure the plugin is installed and this method runs on a compatible platform. Test aborted.")
		$ready_b:=False:C215
	End if

	If ($ready_b)

		OT Clear($testOtH_i)

		// ====================================================
		// INIT
		// ====================================================
		OTr_ClearAll
		$total_i:=0
		$pass_i:=0
		$fail_i:=0

		$otMain_i:=OT New
		$otrMain_i:=OTr_New

		APPEND TO ARRAY:C911($rows_at; "Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF)

		// Seed known scalar values so later array/path misuse is deliberate.
		OT PutLong($otMain_i; "scalar"; 123)
		OT PutString($otMain_i; "textItem"; "abc")
		OTr_PutLong($otrMain_i; "scalar"; 123)
		OTr_PutString($otrMain_i; "textItem"; "abc")

		// ====================================================
		//MARK:- 1. Invalid handle on getter
		// ====================================================
		$testName_t:="Invalid handle on getter"
		$otCmd_t:="OT GetLong(99999; ""missing"")"
		$otrCmd_t:="OTr_GetLong(99999; ""missing"")"

		$gotLong_i:=OT GetLong(99999; "missing")
		$otResult_t:="returned "+String:C10($gotLong_i)+" OK="+String:C10(OK)

		$gotLong_i:=OTr_GetLong(99999; "missing")
		$otrResult_t:="returned "+String:C10($gotLong_i)+" OK="+String:C10(OK)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		//MARK:- 2. Missing tag on getter
		// ====================================================
		$testName_t:="Missing tag on getter"
		$otCmd_t:="OT GetLong($otMain_i; ""doesNotExist"")"
		$otrCmd_t:="OTr_GetLong($otrMain_i; ""doesNotExist"")"

		$gotLong_i:=OT GetLong($otMain_i; "doesNotExist")
		$otResult_t:="returned "+String:C10($gotLong_i)+" OK="+String:C10(OK)

		$gotLong_i:=OTr_GetLong($otrMain_i; "doesNotExist")
		$otrResult_t:="returned "+String:C10($gotLong_i)+" OK="+String:C10(OK)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		//MARK:- 3. Array write against scalar
		// ====================================================
		$testName_t:="Array write against scalar"
		$otCmd_t:="OT PutArrayLong($otMain_i; ""scalar""; 1; 777)"
		$otrCmd_t:="OTr_PutArrayLong($otrMain_i; ""scalar""; 1; 777)"

		OT PutArrayLong($otMain_i; "scalar"; 1; 777)
		$otResult_t:="OK="+String:C10(OK)

		OTr_PutArrayLong($otrMain_i; "scalar"; 1; 777)
		$otrResult_t:="OK="+String:C10(OK)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		//MARK:- 4. SizeOfArray against missing tag
		// ====================================================
		$testName_t:="SizeOfArray on missing tag"
		$otCmd_t:="OT SizeOfArray($otMain_i; ""missingArray"")"
		$otrCmd_t:="OTr_SizeOfArray($otrMain_i; ""missingArray"")"

		$size_i:=OT SizeOfArray($otMain_i; "missingArray")
		$otResult_t:="returned "+String:C10($size_i)+" OK="+String:C10(OK)

		$size_i:=OTr_SizeOfArray($otrMain_i; "missingArray")
		$otrResult_t:="returned "+String:C10($size_i)+" OK="+String:C10(OK)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		//MARK:- 5. CompareItems type mismatch
		// ====================================================
		$testName_t:="CompareItems type mismatch"
		$otCmd_t:="OT CompareItems($otMain_i; ""scalar""; $otMain_i; ""textItem"")"
		$otrCmd_t:="OTr_CompareItems($otrMain_i; ""scalar""; $otrMain_i; ""textItem"")"

		$compare_i:=OT CompareItems($otMain_i; "scalar"; $otMain_i; "textItem")
		$otResult_t:="returned "+String:C10($compare_i)+" OK="+String:C10(OK)

		$compare_i:=OTr_CompareItems($otrMain_i; "scalar"; $otrMain_i; "textItem")
		$otrResult_t:="returned "+String:C10($compare_i)+" OK="+String:C10(OK)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		//MARK:- 6. Invalid dotted path through scalar
		// ====================================================
		$testName_t:="Invalid dotted path through scalar"
		$otCmd_t:="OT PutLong($otMain_i; ""scalar.child""; 9)"
		$otrCmd_t:="OTr_PutLong($otrMain_i; ""scalar.child""; 9)"

		OT PutLong($otMain_i; "scalar.child"; 9)
		$otResult_t:="OK="+String:C10(OK)

		OTr_PutLong($otrMain_i; "scalar.child"; 9)
		$otrResult_t:="OK="+String:C10(OK)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		//MARK:- 7. Pointer getter on missing tag
		// ====================================================
		$testName_t:="Pointer getter on missing tag"
		$otCmd_t:="OT GetPointer($otMain_i; ""missingPtr""; $gotPtr_ptr)"
		$otrCmd_t:="OTr_GetPointer($otrMain_i; ""missingPtr""; ->$gotPtr_ptr)"

		$gotPtr_ptr:=Null:C1517
		OT GetPointer($otMain_i; "missingPtr"; $gotPtr_ptr)
		$otResult_t:="OK="+String:C10(OK)

		$gotPtr_ptr:=Null:C1517
		OTr_GetPointer($otrMain_i; "missingPtr"; ->$gotPtr_ptr)
		$otrResult_t:="OK="+String:C10(OK)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		//MARK:- 8. Delete missing tag
		// ====================================================
		$testName_t:="Delete missing tag"
		$otCmd_t:="OT DeleteItem($otMain_i; ""missingDelete"")"
		$otrCmd_t:="OTr_DeleteItem($otrMain_i; ""missingDelete"")"

		OT DeleteItem($otMain_i; "missingDelete")
		$otResult_t:="OK="+String:C10(OK)

		OTr_DeleteItem($otrMain_i; "missingDelete")
		$otrResult_t:="OK="+String:C10(OK)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		//MARK:- 9. Register call
		// ====================================================
		$testName_t:="Register call"
		$otCmd_t:="OT Register(""20C9-EMQv-BJBl-D20M"")"
		$otrCmd_t:="OTr_Register(""20C9-EMQv-BJBl-D20M"")"

		$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")
		$otResult_t:="returned "+String:C10($reg_i)+" OK="+String:C10(OK)

		$reg_i:=OTr_Register("20C9-EMQv-BJBl-D20M")
		$otrResult_t:="returned "+String:C10($reg_i)+" OK="+String:C10(OK)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// TEARDOWN
		// ====================================================
		OT Clear($otMain_i)
		OTr_ClearAll

		// ====================================================
		// ASSEMBLE TABLE AND WRITE FILE
		// ====================================================
		$summaryLine_t:="Total scenarios: "+String:C10($total_i)+"  Rows written: "+String:C10($pass_i)+"  Fail count reserved: "+String:C10($fail_i)
		APPEND TO ARRAY:C911($rows_at; "")
		APPEND TO ARRAY:C911($rows_at; $summaryLine_t)

		$tableText_t:=""
		For ($i_i; 1; Size of array:C274($rows_at))
			$tableText_t:=$tableText_t+$rows_at{$i_i}
		End for

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
		ALERT:C41($summaryLine_t+Char:C90(Carriage return:K15:38)+"Results written to: "+$fileName_t)
		SET TEXT TO PASTEBOARD:C523($tableText_t)

	End if

Else
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)

	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if
*/
