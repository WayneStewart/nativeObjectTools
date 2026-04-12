//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_5

// Unit tests for all Phase 5 methods:
//   OTr_PutBLOB / OTr_GetBLOB / OTr_GetNewBLOB
//   OTr_PutPicture / OTr_GetPicture
//   OTr_PutPointer / OTr_GetPointer
//   OTr_PutRecord / OTr_GetRecord / OTr_GetRecordTable
//   OTr_PutVariable / OTr_GetVariable
//
// Skipped (require live record or external resource):
//   OTr_PutRecord / OTr_GetRecord full round-trip
//     (no suitable test table in this project)
//
// Access: Private

// Returns: Nothing (results shown via ALERT,
//          summary copied to pasteboard)

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-10 — Removed spurious If (OK=1) assertions
//     on happy paths (the legacy OTr contract sets OK=0 on error only
//     and does not guarantee OK=1 on success; see OTr-OK0-Conditions).
//     Replaced with semantic post-condition checks (OTr_ItemExists /
//     round-trip equality). Rewrote the obsolete GetBLOB stub test as
//     a proper pointer-parameter round-trip. Added a cross-idiom
//     Pointer round-trip via PutVariable/GetVariable.
// ----------------------------------------------------
var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t : Text

// ----------------------------------------------------

$StackSize_i:=0
$DesiredProcessName_t:=Current method name:C684

If (Current process name:C1392=$DesiredProcessName_t)
	
	var $h_i : Integer
	var $total_i; $passed_i; $failed_i : Integer
	var $failures_t : Text
	var $summary_t : Text
	
	// BLOB test vars
	var $testBlob_blob : Blob
	var $gotBlob_blob : Blob
	
	// Picture test vars
	var $pngB64_t : Text
	var $pngBlob_blob : Blob
	var $testPic_pic : Picture
	var $gotPic_pic : Picture
	
	// Pointer test vars
	var vtCC_Filename : Text
	
	// Record test vars
	var $snapObj_o : Object
	
	// Variable test vars
	var $longVar_i : Integer
	var $realVar_r : Real
	var $textVar_t : Text
	var $boolVar_b : Boolean
	var $dateVar_d : Date
	var $timeVar_h : Time
	var $ptrVar_ptr : Pointer
	var $longVarOut_i : Integer
	var $realVarOut_r : Real
	var $textVarOut_t : Text
	var $boolVarOut_b : Boolean
	var $dateVarOut_d : Date
	var $timeVarOut_h : Time
	
	// Expand/Collapse tests removed — OTr_u_ExpandBinaries/OTr_u_CollapseBinaries
	// retired in Phase 6; binary data now stored natively in 4D Objects.
	
	// ====================================================
	// SETUP
	// ====================================================
	OTr_ClearAll
	$h_i:=OTr_New
	$total_i:=0
	$passed_i:=0
	$failed_i:=0
	$failures_t:=""
	
	// ====================================================
	//MARK:- OTr_PutBLOB — basic store
	// ====================================================
	
	CONVERT FROM TEXT:C1011("hello-otr-blob-test"; "UTF-8"; $testBlob_blob)
	$total_i:=$total_i+1
	OTr_PutBLOB($h_i; "blobval"; $testBlob_blob)
	If (OTr_ItemExists($h_i; "blobval")=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutBLOB store — tag not created"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetBLOB — pointer-parameter round-trip
	// ====================================================
	
	$total_i:=$total_i+1
	CLEAR VARIABLE:C89($gotBlob_blob)
	OTr_GetBLOB($h_i; "blobval"; ->$gotBlob_blob)
	
	If (OTr_u_EqualBLOBs($testBlob_blob; $gotBlob_blob))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetBLOB pointer-parameter round-trip"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetNewBLOB — round-trip equality
	// ====================================================
	
	$total_i:=$total_i+1
	CONVERT FROM TEXT:C1011("hello-otr-blob-test"; "UTF-8"; $testBlob_blob)
	OTr_PutBLOB($h_i; "blobval2"; $testBlob_blob)
	$gotBlob_blob:=OTr_GetNewBLOB($h_i; "blobval2")
	If (OTr_u_EqualBLOBs($testBlob_blob; $gotBlob_blob))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetNewBLOB round-trip"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutBLOB — invalid handle
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_PutBLOB(9999; "blobval"; $testBlob_blob)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutBLOB invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutPicture / OTr_GetPicture — round-trip
	//
	// NOTE: A 1×1 black PNG is constructed from hardcoded 
	// Base64. If PutPicture fails (OK=0), the Base64 may
	// need replacing with a path to a real image resource.
	// ====================================================
	
	//$pngB64_t:="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
	//CONVERT FROM TEXT($pngB64_t; "US-ASCII"; $pngBlob_blob)
	//BASE64 DECODE($pngBlob_blob)
	//BLOB TO PICTURE($pngBlob_blob; $testPic_pic; ".png")
	
	$testPic_pic:=OTr_z_Wombat
	
	$total_i:=$total_i+1
	OTr_PutPicture($h_i; "picval"; $testPic_pic)
	If (OTr_ItemExists($h_i; "picval")=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutPicture store — tag not created"+Char:C90(Carriage return:K15:38)
	End if 
	
	$total_i:=$total_i+1
	$gotPic_pic:=OTr_GetPicture($h_i; "picval")
	If (OTr_u_EqualPictures($testPic_pic; $gotPic_pic))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetPicture round-trip"+Char:C90(Carriage return:K15:38)
	End if 
	
	// Checkpoint: inspect the stored "picval" raw value
	OTr_SaveToClipboard($h_i)
	
	// ====================================================
	//MARK:- OTr_PutPicture — invalid handle
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_PutPicture(9999; "picval"; $testPic_pic)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutPicture invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutPointer — store creates the tag
	// ====================================================
	
	vtCC_Filename:="pointer-round-trip"
	$total_i:=$total_i+1
	OTr_PutPointer($h_i; "ptrval"; ->vtCC_Filename)
	If (OTr_ItemExists($h_i; "ptrval")=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutPointer store — tag not created"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetPointer — pointer-parameter round-trip
	// ====================================================
	
	$ptrVar_ptr:=Null:C1517
	$total_i:=$total_i+1
	OTr_GetPointer($h_i; "ptrval"; ->$ptrVar_ptr)
	If (($ptrVar_ptr#Null:C1517) & ($ptrVar_ptr->="pointer-round-trip"))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetPointer round-trip"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetPointer — invalid handle
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_GetPointer(9999; "ptrval"; ->$ptrVar_ptr)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetPointer invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutRecord — invalid handle
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_PutRecord(9999; "rec"; 1)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutRecord invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutRecord — invalid table number
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_PutRecord($h_i; "rec"; -1)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutRecord invalid table should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetRecord — invalid handle
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_GetRecord(9999; "rec"; 1)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetRecord invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetRecord — invalid table number
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_GetRecord($h_i; "rec"; -1)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetRecord invalid table should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetRecordTable — hand-crafted snapshot
	//
	// Insert a fake snapshot sub-object directly into the
	// live OTr object (under the registry lock), then
	// verify OTr_GetRecordTable returns the __tableNum.
	// ====================================================
	
	OTr_z_Lock
	OB SET:C1220(<>OTR_Objects_ao{$h_i}; "snaptag"; New object:C1471("__tableNum"; 7; "SomeField"; "test-value"))
	OTr_z_Unlock
	
	$total_i:=$total_i+1
	If (OTr_GetRecordTable($h_i; "snaptag")=7)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetRecordTable hand-crafted snapshot"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetRecordTable — missing __tableNum
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_z_Lock
	OB SET:C1220(<>OTR_Objects_ao{$h_i}; "notasnap"; New object:C1471("x"; "y"))
	OTr_z_Unlock
	If (OTr_GetRecordTable($h_i; "notasnap")=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetRecordTable missing __tableNum should return 0"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable / OTr_GetVariable — LongInt
	// ====================================================
	
	$longVar_i:=12345
	OTr_PutVariable($h_i; "vlong"; ->$longVar_i)
	$longVarOut_i:=0
	OTr_GetVariable($h_i; "vlong"; ->$longVarOut_i)
	
	$total_i:=$total_i+1
	If ($longVarOut_i=12345)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable/GetVariable LongInt"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable / OTr_GetVariable — Real
	// ====================================================
	
	$realVar_r:=3.14159
	OTr_PutVariable($h_i; "vreal"; ->$realVar_r)
	$realVarOut_r:=0
	OTr_GetVariable($h_i; "vreal"; ->$realVarOut_r)
	
	$total_i:=$total_i+1
	If ($realVarOut_r>3.1415) & ($realVarOut_r<3.1417)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable/GetVariable Real"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable / OTr_GetVariable — Text
	// ====================================================
	
	$textVar_t:="hello-variable"
	OTr_PutVariable($h_i; "vtext"; ->$textVar_t)
	$textVarOut_t:=""
	OTr_GetVariable($h_i; "vtext"; ->$textVarOut_t)
	
	$total_i:=$total_i+1
	If ($textVarOut_t="hello-variable")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable/GetVariable Text"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable / OTr_GetVariable — Boolean True
	// ====================================================
	
	$boolVar_b:=True:C214
	OTr_PutVariable($h_i; "vboolt"; ->$boolVar_b)
	$boolVarOut_b:=False:C215
	OTr_GetVariable($h_i; "vboolt"; ->$boolVarOut_b)
	
	$total_i:=$total_i+1
	If ($boolVarOut_b=True:C214)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable/GetVariable Boolean True"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable / OTr_GetVariable — Boolean False
	// ====================================================
	
	$boolVar_b:=False:C215
	OTr_PutVariable($h_i; "vboolf"; ->$boolVar_b)
	$boolVarOut_b:=True:C214
	OTr_GetVariable($h_i; "vboolf"; ->$boolVarOut_b)
	
	$total_i:=$total_i+1
	If ($boolVarOut_b=False:C215)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable/GetVariable Boolean False"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable / OTr_GetVariable — Date
	// ====================================================
	
	$dateVar_d:=!2026-04-03!
	OTr_PutVariable($h_i; "vdate"; ->$dateVar_d)
	$dateVarOut_d:=!1900-01-01!
	OTr_GetVariable($h_i; "vdate"; ->$dateVarOut_d)
	
	$total_i:=$total_i+1
	If ($dateVarOut_d=!2026-04-03!)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable/GetVariable Date"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable / OTr_GetVariable — Time
	// ====================================================
	
	$timeVar_h:=?14:35:00?
	OTr_PutVariable($h_i; "vtime"; ->$timeVar_h)
	$timeVarOut_h:=?00:00:00?
	OTr_GetVariable($h_i; "vtime"; ->$timeVarOut_h)
	
	$total_i:=$total_i+1
	If ($timeVarOut_h=?14:35:00?)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable/GetVariable Time"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable / OTr_GetVariable — Pointer round-trip
	// ====================================================
	
	$ptrVar_ptr:=->vtCC_Filename
	OTr_PutVariable($h_i; "vptr"; ->$ptrVar_ptr)
	$ptrVar_ptr:=Null:C1517
	OTr_GetVariable($h_i; "vptr"; ->$ptrVar_ptr)
	
	$total_i:=$total_i+1
	If (($ptrVar_ptr#Null:C1517) & ($ptrVar_ptr->="pointer-round-trip"))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable/GetVariable Pointer round-trip"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable — BLOB round-trip via GetVariable
	// ====================================================
	
	CONVERT FROM TEXT:C1011("blob-via-putvariable"; "UTF-8"; $testBlob_blob)
	OTr_PutVariable($h_i; "vblob"; ->$testBlob_blob)
	
	$total_i:=$total_i+1
	If (OTr_ItemExists($h_i; "vblob")=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable BLOB store — tag not created"+Char:C90(Carriage return:K15:38)
	End if 
	
	CLEAR VARIABLE:C89($gotBlob_blob)
	OTr_GetVariable($h_i; "vblob"; ->$gotBlob_blob)
	
	$total_i:=$total_i+1
	If (OTr_u_EqualBLOBs($testBlob_blob; $gotBlob_blob))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetVariable BLOB round-trip"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable — Picture round-trip via GetVariable
	// ====================================================
	
	OTr_PutVariable($h_i; "vpic"; ->$testPic_pic)
	
	$total_i:=$total_i+1
	If (OTr_ItemExists($h_i; "vpic")=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable Picture store — tag not created"+Char:C90(Carriage return:K15:38)
	End if 
	
	OTr_GetVariable($h_i; "vpic"; ->$gotPic_pic)
	
	$total_i:=$total_i+1
	If (OTr_u_EqualPictures($testPic_pic; $gotPic_pic))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetVariable Picture round-trip"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_PutVariable — LongInt array delegation
	// ====================================================
	
	ARRAY LONGINT:C221($longArr_ai; 3)
	$longArr_ai{1}:=11
	$longArr_ai{2}:=22
	$longArr_ai{3}:=33
	OTr_PutVariable($h_i; "varr"; ->$longArr_ai)
	
	$total_i:=$total_i+1
	If (OTr_ArrayType($h_i; "varr")=LongInt array:K8:19)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable LongInt array delegation"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetVariable — LongInt array delegation
	// ====================================================
	
	ARRAY LONGINT:C221($longArr_ai; 0)
	OTr_GetVariable($h_i; "varr"; ->$longArr_ai)
	
	$total_i:=$total_i+1
	If (Size of array:C274($longArr_ai)=3) & ($longArr_ai{1}=11) & ($longArr_ai{3}=33)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetVariable LongInt array delegation"+Char:C90(Carriage return:K15:38)
	End if 
	
	// Checkpoint: inspect all variable tag values
	OTr_SaveToClipboard($h_i)
	
	// ====================================================
	//MARK:- OTr_PutVariable — invalid handle
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_PutVariable(9999; "vlong"; ->$longVar_i)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutVariable invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 
	
	// ====================================================
	//MARK:- OTr_GetVariable — invalid handle
	// ====================================================
	
	$total_i:=$total_i+1
	OTr_GetVariable(9999; "vlong"; ->$longVarOut_i)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetVariable invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 
	// ====================================================
	//MARK:- SUMMARY
	// ====================================================
	OTr_ClearAll
	
	$summary_t:="Phase 5 Tests"+Char:C90(Carriage return:K15:38)
	$summary_t:=$summary_t+"Total:  "+String:C10($total_i)+Char:C90(Carriage return:K15:38)
	$summary_t:=$summary_t+"Passed: "+String:C10($passed_i)+Char:C90(Carriage return:K15:38)
	$summary_t:=$summary_t+"Failed: "+String:C10($failed_i)
	
	If ($failed_i>0)
		$summary_t:=$summary_t+Char:C90(Carriage return:K15:38)+Char:C90(Carriage return:K15:38)+"Failures:"+Char:C90(Carriage return:K15:38)+$failures_t
	End if 
	
	ALERT:C41($summary_t)
	SET TEXT TO PASTEBOARD:C523($summary_t)
Else 
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 
