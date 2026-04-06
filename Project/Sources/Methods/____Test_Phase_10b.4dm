//%attributes = {"invisible":true,"shared":false}

// Entire method commented out to allow for compiling when plugin is not present.


// ----------------------------------------------------
// Project Method: ____Test_Phase_10b

// Logging-focused misuse suite paired with
// ____Test_Phase_10a. The scenarios are valid 4D calls
// but intentionally contain logical mistakes such as
// invalid handles, missing tags, type mismatches, array
// misuse, and bad serialised input.
//
// Output: TAB-delimited results table written to the
// Logs folder with a timestamped filename, then shown
// on disk.
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
/*
$StackSize_i:=0
$DesiredProcessName_t:=Current method name

If (Current process name=$DesiredProcessName_t)

var $ready_b : Boolean
var $otMain_i; $otrMain_i : Integer
var $testOtH_i : Integer
var $reg_i : Integer
var $total_i; $pass_i; $fail_i : Integer
var $testName_t : Text
var $otCmd_t; $otrCmd_t : Text
var $otResult_t; $otrResult_t : Text
var $summaryLine_t : Text
var $tableText_t : Text
var $folderPath_t : Text
var $fileName_t : Text
var $filePath_t : Text
var $dateStr_t : Text
var $timeStr_t : Text
var $y_i; $mo_i; $d_i : Integer
var $i_i : Integer
var $gotLong_i : Integer
var $size_i : Integer
var $compare_i : Integer
var $badBlob_blob : Blob
var $ptrOut_ptr : Pointer
var $TAB; $LF : Text
var $varText_t : Text

ARRAY TEXT($rows_at; 0)

$TAB:=Char(Tab)
$LF:=Char(Line feed)
$ready_b:=True

$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")
$testOtH_i:=OT New

If ($testOtH_i=0)
ALERT("ObjectTools 5.0 is not available or not registered. "+Char(Carriage return)+"Ensure the plugin is installed and this method runs on a compatible platform. Test aborted.")
$ready_b:=False
End if 

If ($ready_b)

OT Clear($testOtH_i)
OTr_ClearAll

$total_i:=0
$pass_i:=0
$fail_i:=0

$otMain_i:=OT New
$otrMain_i:=OTr_New

OT PutLong($otMain_i; "scalar"; 123)
OT PutString($otMain_i; "textItem"; "abc")
OTr_PutLong($otrMain_i; "scalar"; 123)
OTr_PutString($otrMain_i; "textItem"; "abc")

APPEND TO ARRAY($rows_at; "Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF)

// ====================================================
// 1. Invalid handle
// ====================================================
$testName_t:="Invalid handle"
$otCmd_t:="OT GetLong(99999; \"missing\")"
$otrCmd_t:="OTr_GetLong(99999; \"missing\")"
$gotLong_i:=OT GetLong(99999; "missing")
$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
$gotLong_i:=OTr_GetLong(99999; "missing")
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 2. Missing tag
// ====================================================
$testName_t:="Missing tag"
$otCmd_t:="OT GetLong($otMain_i; \"missing\")"
$otrCmd_t:="OTr_GetLong($otrMain_i; \"missing\")"
$gotLong_i:=OT GetLong($otMain_i; "missing")
$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
$gotLong_i:=OTr_GetLong($otrMain_i; "missing")
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 3. Array write against scalar
// ====================================================
$testName_t:="Array write against scalar"
$otCmd_t:="OT PutArrayLong($otMain_i; \"scalar\"; 1; 777)"
$otrCmd_t:="OTr_PutArrayLong($otrMain_i; \"scalar\"; 1; 777)"
OT PutArrayLong($otMain_i; "scalar"; 1; 777)
$otResult_t:="OK="+String(OK)
OTr_PutArrayLong($otrMain_i; "scalar"; 1; 777)
$otrResult_t:="OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 4. Out-of-range array access
// ====================================================
$testName_t:="Out-of-range array access"
$otCmd_t:="OT GetArrayLong($otMain_i; \"scalar\"; 99)"
$otrCmd_t:="OTr_GetArrayLong($otrMain_i; \"scalar\"; 99)"
$gotLong_i:=OT GetArrayLong($otMain_i; "scalar"; 99)
$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
$gotLong_i:=OTr_GetArrayLong($otrMain_i; "scalar"; 99)
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 5. SizeOfArray on missing tag
// ====================================================
$testName_t:="SizeOfArray on missing tag"
$otCmd_t:="OT SizeOfArray($otMain_i; \"missingArray\")"
$otrCmd_t:="OTr_SizeOfArray($otrMain_i; \"missingArray\")"
$size_i:=OT SizeOfArray($otMain_i; "missingArray")
$otResult_t:="returned "+String($size_i)+" OK="+String(OK)
$size_i:=OTr_SizeOfArray($otrMain_i; "missingArray")
$otrResult_t:="returned "+String($size_i)+" OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 6. CompareItems type mismatch
// ====================================================
$testName_t:="CompareItems type mismatch"
$otCmd_t:="OT CompareItems($otMain_i; \"scalar\"; $otMain_i; \"textItem\")"
$otrCmd_t:="OTr_CompareItems($otrMain_i; \"scalar\"; $otrMain_i; \"textItem\")"
$compare_i:=OT CompareItems($otMain_i; "scalar"; $otMain_i; "textItem")
$otResult_t:="returned "+String($compare_i)+" OK="+String(OK)
$compare_i:=OTr_CompareItems($otrMain_i; "scalar"; $otrMain_i; "textItem")
$otrResult_t:="returned "+String($compare_i)+" OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 7. Invalid dotted path through scalar
// ====================================================
$testName_t:="Invalid dotted path through scalar"
$otCmd_t:="OT PutLong($otMain_i; scalar.child; 9)"
$otrCmd_t:="OTr_PutLong($otrMain_i; \"scalar.child\"; 9)"
OT PutLong($otMain_i; "scalar.child"; 9)
$otResult_t:="OK="+String(OK)
OTr_PutLong($otrMain_i; "scalar.child"; 9)
$otrResult_t:="OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 8. Delete missing tag
// ====================================================
$testName_t:="Delete missing tag"
$otCmd_t:="OT DeleteItem($otMain_i; \"missingDelete\")"
$otrCmd_t:="OTr_DeleteItem($otrMain_i; \"missingDelete\")"
OT DeleteItem($otMain_i; "missingDelete")
$otResult_t:="OK="+String(OK)
OTr_DeleteItem($otrMain_i; "missingDelete")
$otrResult_t:="OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 9. Pointer getter on missing tag
// ====================================================
$testName_t:="Pointer getter on missing tag"
$otCmd_t:="OT GetPointer($otMain_i; \"missingPtr\"; $ptrOut_ptr)"
$otrCmd_t:="OTr_GetPointer($otrMain_i; \"missingPtr\"; ->$ptrOut_ptr)"
$ptrOut_ptr:=Null
OT GetPointer($otMain_i; "missingPtr"; $ptrOut_ptr)
$otResult_t:="OK="+String(OK)
$ptrOut_ptr:=Null
OTr_GetPointer($otrMain_i; "missingPtr"; ->$ptrOut_ptr)
$otrResult_t:="OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 10. Invalid BLOB deserialisation
// ====================================================
$testName_t:="Invalid BLOB deserialisation"
$otCmd_t:="OT BLOBToObject($badBlob_blob)"
$otrCmd_t:="OTr_BLOBToObject($badBlob_blob)"
TEXT TO BLOB("this is not a serialised object"; $badBlob_blob)
$gotLong_i:=OT BLOBToObject($badBlob_blob)
$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
$gotLong_i:=OTr_BLOBToObject($badBlob_blob)
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 11. Variable type mismatch
// ====================================================
$testName_t:="Variable type mismatch"
$otCmd_t:="OT PutVariable long / OT GetVariable into text"
$otrCmd_t:="OTr PutVariable long / OTr GetVariable into text"
$gotLong_i:=123
OT PutVariable($otMain_i; "varMixed"; ->$gotLong_i)
$varText_t:=""
OT GetVariable($otMain_i; "varMixed"; ->$varText_t)
$otResult_t:="text="+$varText_t+" OK="+String(OK)
$gotLong_i:=123
OTr_PutVariable($otrMain_i; "varMixed"; ->$gotLong_i)
$varText_t:=""
OTr_GetVariable($otrMain_i; "varMixed"; ->$varText_t)
$otrResult_t:="text="+$varText_t+" OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// 12. Invalid handle on object utility
// ====================================================
$testName_t:="Invalid handle on object utility"
$otCmd_t:="OT ItemCount(99999)"
$otrCmd_t:="OTr_ItemCount(99999)"
$size_i:=OT ItemCount(99999)
$otResult_t:="returned "+String($size_i)+" OK="+String(OK)
$size_i:=OTr_ItemCount(99999)
$otrResult_t:="returned "+String($size_i)+" OK="+String(OK)
$total_i:=$total_i+1
$pass_i:=$pass_i+1
APPEND TO ARRAY($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

// ====================================================
// TEARDOWN
// ====================================================
OT Clear($otMain_i)
OTr_ClearAll

$summaryLine_t:="Total scenarios: "+String($total_i)+"  Rows written: "+String($pass_i)+"  Fail count reserved: "+String($fail_i)
APPEND TO ARRAY($rows_at; "")
APPEND TO ARRAY($rows_at; $summaryLine_t)

$tableText_t:=""
For ($i_i; 1; Size of array($rows_at))
$tableText_t:=$tableText_t+$rows_at{$i_i}
End for 

$y_i:=Year of(Current date)
$mo_i:=Month of(Current date)
$d_i:=Day of(Current date)
$dateStr_t:=String($y_i; "0000")+"-"+String($mo_i; "00")+"-"+String($d_i; "00")
$timeStr_t:=String(Current time; HH MM SS)
$timeStr_t:=Replace string($timeStr_t; ":"; "-")
$fileName_t:="____Test_Phase_10b-"+$dateStr_t+"-"+$timeStr_t+".txt"

$folderPath_t:=Get 4D folder(Logs folder)
$filePath_t:=$folderPath_t+$fileName_t

TEXT TO DOCUMENT($filePath_t; $tableText_t; "UTF-8")
SHOW ON DISK($filePath_t)
ALERT($summaryLine_t+Char(Carriage return)+"Results written to: "+$fileName_t)
SET TEXT TO PASTEBOARD($tableText_t)

End if 

Else 
$ProcessID_i:=New process(Current method name; $StackSize_i; $DesiredProcessName_t; *)
RESUME PROCESS($ProcessID_i)
SHOW PROCESS($ProcessID_i)
BRING TO FRONT($ProcessID_i)
End if 

*/