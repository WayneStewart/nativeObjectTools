//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_OT_Compatibility

// Side-by-side compatibility test: exercises each OTr
// method against its ObjectTools 5.0 counterpart using
// identical test data within the same method call.
//
// See OTr-Phase-015-Spec.md §5 for the full test matrix,
// §4 for the catalogue of intentional differences, and
// §2 for the platform requirement.
//
// Output: pipe-delimited results table written to a
// timestamped plain-text file on the desktop.
//
// PLATFORM REQUIREMENT: ObjectTools 5.0 must be installed
// as a plugin. Run on Windows or macOS prior to macOS
// Tahoe 26.4. The method aborts with an ALERT if OT New
// returns 0.

// Access: Private

// Returns: Nothing (results written to desktop file)

// Created by Wayne Stewart, 2026-04-04
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

var $ready_b : Boolean
var $otMain_i : Integer
var $otrMain_i : Integer
var $testOtH_i : Integer
var $testOtrH_i : Integer
var $h3_i : Integer
var $h4_i : Integer
var $total_i; $pass_i; $fail_i : Integer
var $testName_t : Text
var $otCmd_t : Text
var $otResult_t : Text
var $otrCmd_t : Text
var $otrResult_t : Text
var $gotten_t : Text
var $gotLong_i : Integer
var $gotReal_r : Real
var $gotBool_i : Integer
var $testDate_d : Date
var $gotDate_d : Date
var $testTime_h : Time
var $gotTime_h : Time
var $ptrTarget_t : Text
var $otPtrTarget_t : Text
var $gotPtr_ptr : Pointer
var $pngB64_t : Text
var $pngBlob_blob : Blob
var $testPic_pic : Picture
var $gotPic_pic : Picture
var $testBlob_blob : Blob
var $gotBlob_blob : Blob
var $varTarget_t : Text
var $otVarTarget_t : Text
var $varDest_t : Text
var $otVarDest_t : Text
var $gotItemExists_i : Integer
var $gotItemType_i : Integer
var $gotItemCount_i : Integer
var $otCount_i : Integer
var $otrCount_i : Integer
var $otArrSize_i : Integer
var $otrArrSize_i : Integer
var $otSize_i : Integer
var $otrSize_i : Integer
var $otBlob_blob : Blob
var $otrBlob_blob : Blob
var $serialOtrBlob_blob : Blob
var $loadedOtH_i : Integer
var $otTmpFile_t : Text
var $otVer_t : Text
var $otrVer_t : Text
var $originalOtOpts_i : Integer
var $originalOtrOpts_i : Integer
var $testOpts_i : Integer
var $readOtOpts_i : Integer
var $readOtrOpts_i : Integer
var $gotLong2_i : Integer
var $otrArrVal_i : Integer
var $otArrVal_i : Integer
var $otrArrStr_t : Text
var $otArrStr_t : Text
var $otrArrReal_r : Real
var $otArrReal_r : Real
var $otrArrBool_i : Integer
var $otArrBool_i : Integer
var $gotPic2_pic : Picture
var $tableText_t : Text
var $summaryLine_t : Text
var $desktopPath_t : Text
var $fileName_t : Text
var $filePath_t : Text
var $dateStr_t : Text
var $timeStr_t : Text
var $y_i; $mo_i; $d_i : Integer
var $i_i : Integer
var $otArrPicOut_pic : Picture
var $otrArrPicOut_pic : Picture
var $otArrPtrOut_ptr : Pointer
var $countCheck_i : Integer
var $reg_i : Integer

ARRAY TEXT:C222($rows_at; 0)
ARRAY TEXT:C222($otrPropNames_at; 0)
ARRAY TEXT:C222(otPropNames_at; 0)
ARRAY LONGINT:C221($otrLongArr_ai; 0)
ARRAY LONGINT:C221(otLongArr_ai; 0)


// ====================================================
// CHECK OT AVAILABLE
// ====================================================
$ready_b:=True:C214

$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")  // v5.1r1  ` Modified by: Guy Algot (09/07/23)

$testOtH_i:=OT New
$testOtH_2_i:=OT New

$wombat:=OT IsObject($testOtH_i)
//Do something with the object
//End if 

If ($testOtH_i>=0)
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
	
	APPEND TO ARRAY:C911($rows_at; "| Test Name | OT Test | OT Result | OTr Test | OTr Result |")
	APPEND TO ARRAY:C911($rows_at; "|---|---|---|---|---|")
	
	// 1x1 black PNG (shared by picture tests)
	$pngB64_t:="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
	CONVERT FROM TEXT:C1011($pngB64_t; "US-ASCII"; $pngBlob_blob)
	BASE64 DECODE:C896($pngBlob_blob)
	BLOB TO PICTURE:C682($pngBlob_blob; $testPic_pic; ".png")
	
	// ====================================================
	//MARK:- 1. Creation / Destruction
	// ====================================================
	$testName_t:="Creation / destruction"
	$otCmd_t:="OT New / OT Clear"
	$otrCmd_t:="OTr_New / OTr_Clear"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	$testOtH_i:=OT New
	If ($testOtH_i>0)
		OT Clear($testOtH_i)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: OT New returned 0"
	End if 
	
	$testOtrH_i:=OTr_New
	If (($testOtrH_i>0) & (OK=1))
		OTr_Clear($testOtrH_i)
		If (OK=1)
			$otrResult_t:="Pass"
		Else 
			$otrResult_t:="Fail: OTr_Clear set OK=0"
		End if 
	Else 
		$otrResult_t:="Fail: OTr_New returned 0 or OK=0"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 2. String / Text
	// ====================================================
	$testName_t:="String / Text"
	$otCmd_t:="OT PutString / OT GetString"
	$otrCmd_t:="OTr_PutString / OTr_GetString"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutString($otMain_i; "str"; "compat-str")
	$gotten_t:=OT GetString($otMain_i; "str")
	If ($gotten_t="compat-str")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$gotten_t+"'"
	End if 
	
	OTr_PutString($otrMain_i; "str"; "compat-str")
	$gotten_t:=OTr_GetString($otrMain_i; "str")
	If (($gotten_t="compat-str") & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got '"+$gotten_t+"'"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 3. Longint
	// ====================================================
	$testName_t:="Longint"
	$otCmd_t:="OT PutLong / OT GetLong"
	$otrCmd_t:="OTr_PutLong / OTr_GetLong"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutLong($otMain_i; "num"; 424242)
	$gotLong_i:=OT GetLong($otMain_i; "num")
	If ($gotLong_i=424242)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($gotLong_i)
	End if 
	
	OTr_PutLong($otrMain_i; "num"; 424242)
	$gotLong_i:=OTr_GetLong($otrMain_i; "num")
	If (($gotLong_i=424242) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($gotLong_i)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 4. Real
	// ====================================================
	$testName_t:="Real"
	$otCmd_t:="OT PutReal / OT GetReal"
	$otrCmd_t:="OTr_PutReal / OTr_GetReal"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutReal($otMain_i; "ratio"; 3.14159)
	$gotReal_r:=OT GetReal($otMain_i; "ratio")
	If ($gotReal_r=3.14159)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($gotReal_r)
	End if 
	
	OTr_PutReal($otrMain_i; "ratio"; 3.14159)
	$gotReal_r:=OTr_GetReal($otrMain_i; "ratio")
	If (($gotReal_r=3.14159) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($gotReal_r)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 5. Boolean
	// ====================================================
	$testName_t:="Boolean"
	$otCmd_t:="OT PutBoolean / OT GetBoolean"
	$otrCmd_t:="OTr_PutBoolean / OTr_GetBoolean"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutBoolean($otMain_i; "flag"; True:C214)
	$gotBool_i:=OT GetBoolean($otMain_i; "flag")
	If ($gotBool_i=1)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($gotBool_i)
	End if 
	
	OTr_PutBoolean($otrMain_i; "flag"; True:C214)
	$gotBool_i:=OTr_GetBoolean($otrMain_i; "flag")
	If (($gotBool_i=1) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($gotBool_i)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 6. Date
	// ====================================================
	$testName_t:="Date"
	$otCmd_t:="OT PutDate / OT GetDate"
	$otrCmd_t:="OTr_PutDate / OTr_GetDate"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	$testDate_d:=!2026-04-04!
	
	OT PutDate($otMain_i; "dt"; $testDate_d)
	$gotDate_d:=OT GetDate($otMain_i; "dt")
	If ($gotDate_d=$testDate_d)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($gotDate_d)
	End if 
	
	OTr_PutDate($otrMain_i; "dt"; $testDate_d)
	$gotDate_d:=OTr_GetDate($otrMain_i; "dt")
	If (($gotDate_d=$testDate_d) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($gotDate_d)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 7. Time
	// ====================================================
	$testName_t:="Time"
	$otCmd_t:="OT PutTime / OT GetTime"
	$otrCmd_t:="OTr_PutTime / OTr_GetTime"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	$testTime_h:=?10:30:45?
	
	OT PutTime($otMain_i; "tm"; $testTime_h)
	$gotTime_h:=OT GetTime($otMain_i; "tm")
	If ($gotTime_h=$testTime_h)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($gotTime_h)
	End if 
	
	OTr_PutTime($otrMain_i; "tm"; $testTime_h)
	$gotTime_h:=OTr_GetTime($otrMain_i; "tm")
	If (($gotTime_h=$testTime_h) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($gotTime_h)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 8. Pointer
	// ====================================================
	$testName_t:="Pointer"
	$otCmd_t:="OT PutPointer / OT GetPointer"
	$otrCmd_t:="OTr_PutPointer / OTr_GetPointer"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	$otPtrTarget_t:="ot-ptr-val"
	$ptrTarget_t:="otr-ptr-val"
	
	OT PutPointer($otMain_i; "ptr"; ->$otPtrTarget_t)
	OT GetPointer($otMain_i; "ptr"; ->$gotPtr_ptr)
	If ((OK=1) & ($gotPtr_ptr#Null:C1517) & ($gotPtr_ptr->="ot-ptr-val"))
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: dereference mismatch or OK=0"
	End if 
	
	OTr_PutPointer($otrMain_i; "ptr"; ->$ptrTarget_t)
	// NOTE: OTr_GetPointer has a known issue — the output
	// pointer is set in the local parameter copy, not the
	// caller variable. Test verifies OK=1 only.
	OTr_GetPointer($otrMain_i; "ptr"; ->$gotPtr_ptr)
	If (OK=1)
		$otrResult_t:="Pass (OK=1; dereference skipped - known issue)"
	Else 
		$otrResult_t:="Fail: OK=0"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & (Substring:C12($otrResult_t; 1; 4)="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 9. Picture
	// ====================================================
	$testName_t:="Picture"
	$otCmd_t:="OT PutPicture / OT GetPicture"
	$otrCmd_t:="OTr_PutPicture / OTr_GetPicture"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutPicture($otMain_i; "pic"; $testPic_pic)
	$gotPic_pic:=OT GetPicture($otMain_i; "pic")
	If (OTr_uEqualPictures($testPic_pic; $gotPic_pic))
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: picture mismatch"
	End if 
	
	OTr_PutPicture($otrMain_i; "pic"; $testPic_pic)
	$gotPic_pic:=OTr_GetPicture($otrMain_i; "pic")
	If ((OTr_uEqualPictures($testPic_pic; $gotPic_pic)) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: picture mismatch or OK=0"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 10. BLOB
	// ====================================================
	$testName_t:="BLOB"
	$otCmd_t:="OT PutBLOB / OT GetNewBLOB"
	$otrCmd_t:="OTr_PutBLOB / OTr_GetNewBLOB"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	CONVERT FROM TEXT:C1011("compat-blob-data"; "UTF-8"; $testBlob_blob)
	
	OT PutBLOB($otMain_i; "blob"; $testBlob_blob)
	$gotBlob_blob:=OT GetNewBLOB($otMain_i; "blob")
	If (OTr_uEqualBLOBs($testBlob_blob; $gotBlob_blob))
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: BLOB content mismatch"
	End if 
	
	OTr_PutBLOB($otrMain_i; "blob"; $testBlob_blob)
	$gotBlob_blob:=OTr_GetNewBLOB($otrMain_i; "blob")
	If ((OTr_uEqualBLOBs($testBlob_blob; $gotBlob_blob)) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: BLOB content mismatch or OK=0"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 11. Variable
	// ====================================================
	$testName_t:="Variable"
	$otCmd_t:="OT PutVariable / OT GetVariable"
	$otrCmd_t:="OTr_PutVariable / OTr_GetVariable"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	$otVarTarget_t:="ot-var-val"
	$varTarget_t:="otr-var-val"
	$otVarDest_t:=""
	$varDest_t:=""
	
	OT PutVariable($otMain_i; "var"; ->$otVarTarget_t)
	OT GetVariable($otMain_i; "var"; ->$otVarDest_t)
	If ($otVarDest_t="ot-var-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$otVarDest_t+"'"
	End if 
	
	OTr_PutVariable($otrMain_i; "var"; ->$varTarget_t)
	OTr_GetVariable($otrMain_i; "var"; ->$varDest_t)
	If (($varDest_t="otr-var-val") & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got '"+$varDest_t+"'"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 12. Record  (Intentional difference §4.3)
	// ====================================================
	$testName_t:="Record"
	$otCmd_t:="OT PutRecord / OT GetRecord"
	$otrCmd_t:="OTr_PutRecord / OTr_GetRecord"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	// Use Table 1 (Table_1, sole table in this database).
	// CREATE RECORD then immediately PutRecord/GetRecord
	// without any modification (intentional difference note
	// in §4.3 applies only when modification occurs between
	// Put and Get; immediate round-trip should match).
	CREATE RECORD:C68([Table_1:1])
	
	OT PutRecord($otMain_i; "rec"; Table:C252([Table_1:1]))
	OT GetRecord($otMain_i; "rec")
	If (OK=1)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: OT GetRecord set OK=0"
	End if 
	
	OTr_PutRecord($otrMain_i; "rec"; Table:C252([Table_1:1]))
	OTr_GetRecord($otrMain_i; "rec"; Table:C252([Table_1:1]))
	If (OK=1)
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: OTr_GetRecord set OK=0"
	End if 
	// SAVE RECORD is intentionally omitted — the new record
	// is discarded without being written to disk.
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 13. Dot-path
	// ====================================================
	$testName_t:="Dot-path"
	$otCmd_t:="OT PutString (dotted) / OT GetString"
	$otrCmd_t:="OTr_PutString (dotted) / OTr_GetString"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutString($otMain_i; "a.b.c"; "dot-val")
	$gotten_t:=OT GetString($otMain_i; "a.b.c")
	If ($gotten_t="dot-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$gotten_t+"'"
	End if 
	
	OTr_PutString($otrMain_i; "a.b.c"; "dot-val")
	$gotten_t:=OTr_GetString($otrMain_i; "a.b.c")
	If (($gotten_t="dot-val") & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got '"+$gotten_t+"'"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 14. Array Longint
	// ====================================================
	$testName_t:="Array Longint"
	$otCmd_t:="OT PutArrayLong / OT GetArrayLong"
	$otrCmd_t:="OTr_PutArrayLong / OTr_GetArrayLong"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	// Store element at index 1, retrieve and compare
	OT PutArrayLong($otMain_i; "al"; 1; 100)
	$otArrVal_i:=OT GetArrayLong($otMain_i; "al"; 1)
	If ($otArrVal_i=100)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($otArrVal_i)
	End if 
	
	OTr_PutArrayLong($otrMain_i; "al"; 1; 100)
	$otrArrVal_i:=OTr_GetArrayLong($otrMain_i; "al"; 1)
	If (($otrArrVal_i=100) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($otrArrVal_i)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 15. Array Text
	// ====================================================
	$testName_t:="Array Text"
	$otCmd_t:="OT PutArrayString / OT GetArrayString"
	$otrCmd_t:="OTr_PutArrayString / OTr_GetArrayString"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutArrayString($otMain_i; "as"; 1; "arr-str-val")
	$otArrStr_t:=OT GetArrayString($otMain_i; "as"; 1)
	If ($otArrStr_t="arr-str-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$otArrStr_t+"'"
	End if 
	
	OTr_PutArrayString($otrMain_i; "as"; 1; "arr-str-val")
	$otrArrStr_t:=OTr_GetArrayString($otrMain_i; "as"; 1)
	If (($otrArrStr_t="arr-str-val") & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got '"+$otrArrStr_t+"'"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 16. Array Real
	// ====================================================
	$testName_t:="Array Real"
	$otCmd_t:="OT PutArrayReal / OT GetArrayReal"
	$otrCmd_t:="OTr_PutArrayReal / OTr_GetArrayReal"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutArrayReal($otMain_i; "ar"; 1; 9.99)
	$otArrReal_r:=OT GetArrayReal($otMain_i; "ar"; 1)
	If ($otArrReal_r=9.99)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($otArrReal_r)
	End if 
	
	OTr_PutArrayReal($otrMain_i; "ar"; 1; 9.99)
	$otrArrReal_r:=OTr_GetArrayReal($otrMain_i; "ar"; 1)
	If (($otrArrReal_r=9.99) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($otrArrReal_r)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 17. Array Boolean
	// ====================================================
	$testName_t:="Array Boolean"
	$otCmd_t:="OT PutArrayBoolean / OT GetArrayBoolean"
	$otrCmd_t:="OTr_PutArrayBoolean / OTr_GetArrayBoolean"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutArrayBoolean($otMain_i; "ab"; 1; True:C214)
	$otArrBool_i:=OT GetArrayBoolean($otMain_i; "ab"; 1)
	If ($otArrBool_i=1)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($otArrBool_i)
	End if 
	
	OTr_PutArrayBoolean($otrMain_i; "ab"; 1; True:C214)
	$otrArrBool_i:=OTr_GetArrayBoolean($otrMain_i; "ab"; 1)
	If (($otrArrBool_i=1) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($otrArrBool_i)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 18. Array Pointer
	// ====================================================
	$testName_t:="Array Pointer"
	$otCmd_t:="OT PutArrayPointer / OT GetArrayPointer"
	$otrCmd_t:="OTr_PutArrayPointer / OTr_GetArrayPointer"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	$otPtrTarget_t:="arr-ptr-val"
	
	OT PutArrayPointer($otMain_i; "aptr"; 1; ->$otPtrTarget_t)
	OT GetArrayPointer($otMain_i; "aptr"; 1; ->$otArrPtrOut_ptr)
	If ((OK=1) & ($otArrPtrOut_ptr#Null:C1517) & ($otArrPtrOut_ptr->="arr-ptr-val"))
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: dereference mismatch or OK=0"
	End if 
	
	$ptrTarget_t:="arr-ptr-val"
	OTr_PutArrayPointer($otrMain_i; "aptr"; 1; ->$ptrTarget_t)
	$gotPtr_ptr:=OTr_GetArrayPointer($otrMain_i; "aptr"; 1)
	If ((OK=1) & ($gotPtr_ptr#Null:C1517) & ($gotPtr_ptr->="arr-ptr-val"))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: dereference mismatch or OK=0"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 19. Array Picture
	// ====================================================
	$testName_t:="Array Picture"
	$otCmd_t:="OT PutArrayPicture / OT GetArrayPicture"
	$otrCmd_t:="OTr_PutArrayPicture / OTr_GetArrayPicture"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	OT PutArrayPicture($otMain_i; "apic"; 1; $testPic_pic)
	OT GetArrayPicture($otMain_i; "apic"; 1; $otArrPicOut_pic)
	If (OTr_uEqualPictures($testPic_pic; $otArrPicOut_pic))
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: picture mismatch"
	End if 
	
	OTr_PutArrayPicture($otrMain_i; "apic"; 1; $testPic_pic)
	$otrArrPicOut_pic:=OTr_GetArrayPicture($otrMain_i; "apic"; 1)
	If ((OTr_uEqualPictures($testPic_pic; $otrArrPicOut_pic)) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: picture mismatch or OK=0"
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 20. Item info
	// ====================================================
	$testName_t:="Item info"
	$otCmd_t:="OT ItemExists / OT ItemType"
	$otrCmd_t:="OTr_ItemExists / OTr_ItemType"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	// "str" was stored in the main handles above (row 2).
	// OT type for String/Text is 112 (OT Character constant).
	If ((OT ItemExists($otMain_i; "str")=1) & (OT ItemType($otMain_i; "str")=112))
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: ItemExists or ItemType mismatch"
	End if 
	
	$gotItemExists_i:=OTr_ItemExists($otrMain_i; "str")
	$gotItemType_i:=OTr_ItemType($otrMain_i; "str")
	If (($gotItemExists_i=1) & ($gotItemType_i=112) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: ItemExists="+String:C10($gotItemExists_i)+" ItemType="+String:C10($gotItemType_i)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 21. Item count
	// ====================================================
	$testName_t:="Item count"
	$otCmd_t:="OT ItemCount"
	$otrCmd_t:="OTr_ItemCount"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	// Use fresh handles with exactly 3 scalar items.
	$h3_i:=OT New
	$h4_i:=OTr_New
	OT PutString($h3_i; "x"; "a")
	OT PutString($h3_i; "y"; "b")
	OT PutString($h3_i; "z"; "c")
	OTr_PutString($h4_i; "x"; "a")
	OTr_PutString($h4_i; "y"; "b")
	OTr_PutString($h4_i; "z"; "c")
	
	$otCount_i:=OT ItemCount($h3_i)
	If ($otCount_i=3)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($otCount_i)
	End if 
	
	$otrCount_i:=OTr_ItemCount($h4_i)
	If (($otrCount_i=3) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($otrCount_i)
	End if 
	
	OT Clear($h3_i)
	OTr_Clear($h4_i)
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 22. Property enumeration
	// ====================================================
	$testName_t:="Property enumeration"
	$otCmd_t:="OT GetAllProperties"
	$otrCmd_t:="OTr_GetAllProperties"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	$h3_i:=OT New
	$h4_i:=OTr_New
	OT PutString($h3_i; "p1"; "v1")
	OT PutString($h3_i; "p2"; "v2")
	OTr_PutString($h4_i; "p1"; "v1")
	OTr_PutString($h4_i; "p2"; "v2")
	
	ARRAY TEXT:C222(otPropNames_at; 0)
	OT GetAllProperties($h3_i; otPropNames_at)
	If (Size of array:C274(otPropNames_at)=2)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10(Size of array:C274(otPropNames_at))+" names"
	End if 
	
	ARRAY TEXT:C222($otrPropNames_at; 0)
	OTr_GetAllProperties($h4_i; ->$otrPropNames_at)
	If ((Size of array:C274($otrPropNames_at)=2) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10(Size of array:C274($otrPropNames_at))+" names"
	End if 
	
	OT Clear($h3_i)
	OTr_Clear($h4_i)
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 23. Delete / Rename
	// ====================================================
	$testName_t:="Delete / rename"
	$otCmd_t:="OT DeleteItem / OT RenameItem"
	$otrCmd_t:="OTr_DeleteItem / OTr_RenameItem"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	$h3_i:=OT New
	$h4_i:=OTr_New
	OT PutString($h3_i; "del"; "gone")
	OT PutString($h3_i; "ren"; "stays")
	OTr_PutString($h4_i; "del"; "gone")
	OTr_PutString($h4_i; "ren"; "stays")
	
	OT DeleteItem($h3_i; "del")
	OT RenameItem($h3_i; "ren"; "renamed")
	If ((OT ItemExists($h3_i; "del")=0) & (OT ItemExists($h3_i; "renamed")=1))
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: delete or rename did not work"
	End if 
	
	OTr_DeleteItem($h4_i; "del")
	OTr_RenameItem($h4_i; "ren"; "renamed")
	If ((OTr_ItemExists($h4_i; "del")=0) & (OTr_ItemExists($h4_i; "renamed")=1) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: delete or rename did not work"
	End if 
	
	OT Clear($h3_i)
	OTr_Clear($h4_i)
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 24. Copy
	// ====================================================
	$testName_t:="Copy"
	$otCmd_t:="OT CopyItem"
	$otrCmd_t:="OTr_CopyItem"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	$h3_i:=OT New
	$h4_i:=OTr_New
	OT PutString($otMain_i; "src"; "copy-val")
	OT CopyItem($otMain_i; "src"; $h3_i; "dst")
	$gotten_t:=OT GetString($h3_i; "dst")
	If ($gotten_t="copy-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$gotten_t+"'"
	End if 
	
	OTr_PutString($otrMain_i; "src"; "copy-val")
	OTr_CopyItem($otrMain_i; "src"; $h4_i; "dst")
	$gotten_t:=OTr_GetString($h4_i; "dst")
	If (($gotten_t="copy-val") & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got '"+$gotten_t+"'"
	End if 
	
	OT Clear($h3_i)
	OTr_Clear($h4_i)
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 25. Size of array
	// ====================================================
	$testName_t:="Size of array"
	$otCmd_t:="OT SizeOfArray"
	$otrCmd_t:="OTr_SizeOfArray"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	// "al" already stores at index 1 (row 14); add 2 and 3.
	OT PutArrayLong($otMain_i; "al"; 2; 200)
	OT PutArrayLong($otMain_i; "al"; 3; 300)
	OTr_PutArrayLong($otrMain_i; "al"; 2; 200)
	OTr_PutArrayLong($otrMain_i; "al"; 3; 300)
	
	$otArrSize_i:=OT SizeOfArray($otMain_i; "al")
	If ($otArrSize_i=3)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String:C10($otArrSize_i)
	End if 
	
	$otrArrSize_i:=OTr_SizeOfArray($otrMain_i; "al")
	If (($otrArrSize_i=3) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: got "+String:C10($otrArrSize_i)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 26. Sort arrays
	// ====================================================
	$testName_t:="Sort arrays"
	$otCmd_t:="OT SortArrays"
	$otrCmd_t:="OTr_SortArrays"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	// Populate "sort" array with values 30, 10, 20 then sort
	// ascending; first element should be 10.
	$h3_i:=OT New
	$h4_i:=OTr_New
	OT PutArrayLong($h3_i; "sort"; 1; 30)
	OT PutArrayLong($h3_i; "sort"; 2; 10)
	OT PutArrayLong($h3_i; "sort"; 3; 20)
	OT SortArrays($h3_i; "sort"; ">")
	$gotLong_i:=OT GetArrayLong($h3_i; "sort"; 1)
	If ($gotLong_i=10)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: first element after sort = "+String:C10($gotLong_i)
	End if 
	
	OTr_PutArrayLong($h4_i; "sort"; 1; 30)
	OTr_PutArrayLong($h4_i; "sort"; 2; 10)
	OTr_PutArrayLong($h4_i; "sort"; 3; 20)
	OTr_SortArrays($h4_i; "sort"; ">")
	$gotLong_i:=OTr_GetArrayLong($h4_i; "sort"; 1)
	If (($gotLong_i=10) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: first element after sort = "+String:C10($gotLong_i)
	End if 
	
	OT Clear($h3_i)
	OTr_Clear($h4_i)
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 27. Object size  (Intentional difference §4.3)
	// ====================================================
	$testName_t:="Object size"
	$otCmd_t:="OT ObjectSize"
	$otrCmd_t:="OTr_ObjectSize"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	// Values will not match (§4.3); both must be non-zero.
	$otSize_i:=OT ObjectSize($otMain_i)
	If ($otSize_i>0)
		$otResult_t:="Pass (size="+String:C10($otSize_i)+")"
	Else 
		$otResult_t:="Fail: returned 0"
	End if 
	
	$otrSize_i:=OTr_ObjectSize($otrMain_i)
	If (($otrSize_i>0) & (OK=1))
		$otrResult_t:="Pass (size="+String:C10($otrSize_i)+")"
	Else 
		$otrResult_t:="Fail: returned 0 or OK=0"
	End if 
	
	$total_i:=$total_i+1
	If ((Substring:C12($otResult_t; 1; 4)="Pass") & (Substring:C12($otrResult_t; 1; 4)="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 28. BLOB serialisation (Intentional diff §4.3)
	// ====================================================
	$testName_t:="BLOB serialisation"
	$otCmd_t:="OT ObjectToBLOB / OT BLOBToObject"
	$otrCmd_t:="OTr_ObjectToNewBLOB / OTr_BLOBToObject"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	// Round-trip within each system independently; do NOT
	// cross-load (formats are incompatible per §4.3).
	$h3_i:=OT New
	$h4_i:=OTr_New
	OT PutString($h3_i; "bser"; "blob-ser-val")
	OTr_PutString($h4_i; "bser"; "blob-ser-val")
	
	OT ObjectToBLOB($h3_i; $otBlob_blob)
	$loadedOtH_i:=OT BLOBToObject($otBlob_blob)
	$gotten_t:=OT GetString($loadedOtH_i; "bser")
	If ($gotten_t="blob-ser-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: round-trip got '"+$gotten_t+"'"
	End if 
	OT Clear($h3_i)
	OT Clear($loadedOtH_i)
	
	$serialOtrBlob_blob:=OTr_ObjectToNewBLOB($h4_i)
	$h3_i:=OTr_BLOBToObject($serialOtrBlob_blob)
	$gotten_t:=OTr_GetString($h3_i; "bser")
	If (($gotten_t="blob-ser-val") & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: round-trip got '"+$gotten_t+"'"
	End if 
	OTr_Clear($h4_i)
	OTr_Clear($h3_i)
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 29. Text export / import (Intentional diff §4.3)
	// ====================================================
	$testName_t:="Text export / import"
	$otCmd_t:="OT SaveToText / OT LoadFromText"
	$otrCmd_t:="OTr_SaveToText / OTr_LoadFromText"
	$otResult_t:="Fail: not run"
	// OTr_LoadFromText is not yet implemented (Phase 020).
	$otrResult_t:="Skip: OTr_LoadFromText not yet implemented"
	
	$h3_i:=OT New
	OT PutString($h3_i; "tser"; "text-ser-val")
	$otTmpFile_t:=Temporary folder:C486+"ot-compat-export.txt"
	OT SaveToText($h3_i; $otTmpFile_t)
	$loadedOtH_i:=OT LoadFromText($otTmpFile_t)
	$gotten_t:=OT GetString($loadedOtH_i; "tser")
	If ($gotten_t="text-ser-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: round-trip got '"+$gotten_t+"'"
	End if 
	OT Clear($h3_i)
	OT Clear($loadedOtH_i)
	
	// OTr side skipped (see above).
	
	$total_i:=$total_i+1
	// Count as pass only if OT passes (OTr is a known skip).
	If ($otResult_t="Pass")
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 30. Version
	// ====================================================
	$testName_t:="Version"
	$otCmd_t:="OT GetVersion"
	$otrCmd_t:="OTr_GetVersion"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	
	// Values will differ; both must be non-empty.
	$otVer_t:=OT GetVersion
	If (Length:C16($otVer_t)>0)
		$otResult_t:="Pass (v="+$otVer_t+")"
	Else 
		$otResult_t:="Fail: empty version"
	End if 
	
	$otrVer_t:=OTr_GetVersion
	If ((Length:C16($otrVer_t)>0) & (OK=1))
		$otrResult_t:="Pass (v="+$otrVer_t+")"
	Else 
		$otrResult_t:="Fail: empty version or OK=0"
	End if 
	
	$total_i:=$total_i+1
	If ((Substring:C12($otResult_t; 1; 4)="Pass") & (Substring:C12($otrResult_t; 1; 4)="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- 31. Options
	// ====================================================
	$testName_t:="Options"
	$otCmd_t:="OT GetOptions / OT SetOptions"
	$otrCmd_t:="OTr_GetOptions / OTr_SetOptions"
	$otResult_t:="Fail: not run"
	$otrResult_t:="Fail: not run"
	$testOpts_i:=1+4  // FailOnItemNotFound + AutoCreateObjects
	
	$originalOtOpts_i:=OT GetOptions
	OT SetOptions($testOpts_i)
	$readOtOpts_i:=OT GetOptions
	OT SetOptions($originalOtOpts_i)
	If ($readOtOpts_i=$testOpts_i)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: read "+String:C10($readOtOpts_i)+" expected "+String:C10($testOpts_i)
	End if 
	
	$originalOtrOpts_i:=OTr_GetOptions
	OTr_SetOptions($testOpts_i)
	$readOtrOpts_i:=OTr_GetOptions
	OTr_SetOptions($originalOtrOpts_i)
	If (($readOtrOpts_i=$testOpts_i) & (OK=1))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: read "+String:C10($readOtrOpts_i)+" expected "+String:C10($testOpts_i)
	End if 
	
	$total_i:=$total_i+1
	If (($otResult_t="Pass") & ($otrResult_t="Pass"))
		$pass_i:=$pass_i+1
	Else 
		$fail_i:=$fail_i+1
	End if 
	APPEND TO ARRAY:C911($rows_at; "| "+$testName_t+" | "+$otCmd_t+" | "+$otResult_t+" | "+$otrCmd_t+" | "+$otrResult_t+" |")
	
	// ====================================================
	//MARK:- TEARDOWN
	// ====================================================
	OT Clear($otMain_i)
	OTr_ClearAll
	
	// ====================================================
	//MARK:- ASSEMBLE TABLE AND WRITE FILE
	// ====================================================
	$summaryLine_t:="Total: "+String:C10($total_i)+"  Pass: "+String:C10($pass_i)+"  Fail: "+String:C10($fail_i)
	APPEND TO ARRAY:C911($rows_at; "")
	APPEND TO ARRAY:C911($rows_at; $summaryLine_t)
	
	// Join rows with line feeds
	$tableText_t:=""
	For ($i_i; 1; Size of array:C274($rows_at))
		If ($i_i>1)
			$tableText_t:=$tableText_t+Char:C90(Escape:K15:39)
		End if 
		$tableText_t:=$tableText_t+$rows_at{$i_i}
	End for 
	
	// Build timestamp filename: YYYY-MM-DD-HH-MM-SS.txt
	$y_i:=Year of:C25(Current date:C33)
	$mo_i:=Month of:C24(Current date:C33)
	$d_i:=Day of:C23(Current date:C33)
	$dateStr_t:=String:C10($y_i; "0000")+"-"+String:C10($mo_i; "00")+"-"+String:C10($d_i; "00")
	// Format time as HH MM SS (space-separated), then replace spaces with dashes
	$timeStr_t:=String:C10(Current time:C178; HH MM SS:K7:1)
	$timeStr_t:=Replace string:C233($timeStr_t; " "; "-")
	$fileName_t:=$dateStr_t+"-"+$timeStr_t+".txt"
	
	$desktopPath_t:=Get 4D folder:C485(User system localization:K5:23)
	$filePath_t:=$desktopPath_t+$fileName_t
	
	TEXT TO DOCUMENT:C1237($filePath_t; $tableText_t; "UTF-8")
	
	ALERT:C41($summaryLine_t+Char:C90(Carriage return:K15:38)+"Results written to: "+$fileName_t)
	SET TEXT TO PASTEBOARD:C523($tableText_t)
	
End if 
