//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_15_OT (accum)

// Executes the OT half of the Phase 15 side-by-side
// compatibility test. For each test scenario (in the
// same order as ____Test_Phase_15_OTr), runs the
// legacy ObjectTools 5.0 commands and updates the
// otCmd and otResult columns in the accumulator by
// sequential index using OTr_PutArrayText.
//
// PLATFORM REQUIREMENT: ObjectTools 5.0 must be
// installed as a plugin. If OT New returns 0, all OT
// columns are set to "Skip: plugin not available" and
// the method returns immediately.
//
// TAHOE COMPILATION: Comment out the entire method
// body below the #DECLARE line when building on
// macOS Tahoe 26.4 or later (plugin absent). The
// OTr accumulator is unaffected; only the OT columns
// remain empty.
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-07
// Refactored from ____Test_Phase_15 by Wayne Stewart.
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($accum_i : Integer)

// ==== BEGIN OT BLOCK — comment out on Tahoe 26.4+ ====
/*

var $otMain_i : Integer
var $testOtH_i : Integer
var $loadedOtH_i : Integer
var $h3_i : Integer
var $reg_i : Integer
var $ready_b : Boolean
var $count_i : Integer
var $n_i : Integer
var $gotten_t : Text
var $gotLong_i : Integer
var $gotReal_r : Real
var $gotBool_i : Integer
var $testDate_d : Date
var $gotDate_d : Date
var $testTime_h : Time
var $gotTime_h : Time
var OTr_DummyVariableForTests_t : Text  // process variable -- required for Get pointer round-trip
var $wombat_pic : Picture
var $gotPic_pic : Picture
var $otArrPicOut_pic : Picture
var $testBlob_blob : Blob
var $gotBlob_blob : Blob
var $otBlob_blob : Blob
var $otVarTarget_t : Text
var $otVarDest_t : Text
var $gotItemExists_i : Integer
var $gotItemType_i : Integer
var $otCount_i : Integer
var $otArrSize_i : Integer
var $otSize_i : Integer
var $otVer_t : Text
var $originalOtOpts_i : Integer
var $testOpts_i : Integer
var $readOtOpts_i : Integer
var $otArrVal_i : Integer
var $otArrStr_t : Text
var $otArrReal_r : Real
var $otArrBool_i : Integer
var $otCmd_t : Text
var $otResult_t : Text

ARRAY LONGINT($setupAl_ai; 0)
ARRAY TEXT($setupAs_at; 0)
ARRAY REAL($setupAr_arr; 0)
ARRAY BOOLEAN($setupAb_ab; 0)
ARRAY POINTER($setupAptr_aptr; 0)
ARRAY PICTURE($setupApic_apic; 0)
ARRAY LONGINT($setupSort_ai; 0)

// Arrays without $ are process variables (required for OT
// commands that take untyped array parameters by reference).
ARRAY TEXT(OTr_TextArrayForTests_at; 0)

// ----------------------------------------------------
// Check plugin availability
// ----------------------------------------------------
$ready_b:=True
$reg_i:=OT Register(Storage.OTr.registrationCode)
$testOtH_i:=OT New

If ($testOtH_i=0)
	ALERT("ObjectTools 5.0 is not available or not registered."+Char(Carriage return)+"OT columns will be marked as skipped.")
	$ready_b:=False
	$count_i:=OTr_SizeOfArray($accum_i; "testNum")
	For ($n_i; 1; $count_i)
		OTr_PutArrayText($accum_i; "otCmd"; $n_i; "Plugin not available")
		OTr_PutArrayText($accum_i; "otResult"; $n_i; "Skip: plugin not available")
	End for 
Else 
	OT Clear($testOtH_i)
End if 

If ($ready_b)
	
	$wombat_pic:=OTr_z_Wombat
	$otMain_i:=OT New
	$n_i:=0
	
	// ====================================================
	//MARK:- 1. Creation / Destruction
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT New / OT Clear"
	$otResult_t:="Fail: not run"
	
	$testOtH_i:=OT New
	If ($testOtH_i#0)
		OT Clear($testOtH_i)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: OT New returned 0"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 2. String / Text
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutString / OT GetString"
	$otResult_t:="Fail: not run"
	
	OT PutString($otMain_i; "str"; "compat-str")
	$gotten_t:=OT GetString($otMain_i; "str")
	If ($gotten_t="compat-str")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$gotten_t+"'"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 3. Longint
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutLong / OT GetLong"
	$otResult_t:="Fail: not run"
	
	OT PutLong($otMain_i; "num"; 424242)
	$gotLong_i:=OT GetLong($otMain_i; "num")
	If ($gotLong_i=424242)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($gotLong_i)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 4. Real
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutReal / OT GetReal"
	$otResult_t:="Fail: not run"
	
	OT PutReal($otMain_i; "ratio"; 3.14159)
	$gotReal_r:=OT GetReal($otMain_i; "ratio")
	If ($gotReal_r=3.14159)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($gotReal_r)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 5. Boolean
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutBoolean / OT GetBoolean"
	$otResult_t:="Fail: not run"
	
	OT PutBoolean($otMain_i; "flag"; Num(True))
	$gotBool_i:=OT GetBoolean($otMain_i; "flag")
	If ($gotBool_i=1)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($gotBool_i)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 6. Date
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutDate / OT GetDate"
	$otResult_t:="Fail: not run"
	$testDate_d:=!2026-04-04!
	
	OT PutDate($otMain_i; "dt"; $testDate_d)
	$gotDate_d:=OT GetDate($otMain_i; "dt")
	If ($gotDate_d=$testDate_d)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($gotDate_d)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 7. Time
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutTime / OT GetTime"
	$otResult_t:="Fail: not run"
	$testTime_h:=?10:30:45?
	
	OT PutTime($otMain_i; "tm"; $testTime_h)
	$gotTime_h:=OT GetTime($otMain_i; "tm")
	If ($gotTime_h=$testTime_h)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($gotTime_h)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 8. Pointer
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutPointer / OT GetPointer"
	$otResult_t:="Fail: not run"
	OTr_DummyVariableForTests_t:="ot-ptr-val"
	
	var $ptrVar : Pointer
	$ptrVar:=->OTr_DummyVariableForTests_t
	var $ptrVarOut : Pointer
	
	OT PutPointer($otMain_i; "ptr"; $ptrVar)
	OT GetPointer($otMain_i; "ptr"; $ptrVarOut)
	If (OK=1) & ($ptrVarOut#Null) & (($ptrVarOut->)=OTr_DummyVariableForTests_t)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: dereference mismatch or OK=0"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 9. Picture (empty picture)
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutPicture / OT GetPicture"
	$otResult_t:="Fail: not run"
	
	OT PutPicture($otMain_i; "pic"; $wombat_pic)
	$gotPic_pic:=OT GetPicture($otMain_i; "pic")
	If (OTr_u_EqualPictures($wombat_pic; $gotPic_pic))
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: picture mismatch"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 9a. Picture (wombat)
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutPicture / OT GetPicture"
	$otResult_t:="Fail: not run"
	
	If (Picture size($wombat_pic)=0)
		$otResult_t:="Skip: Wombat picture not loaded"
	Else 
		OT PutPicture($otMain_i; "pic9a"; $wombat_pic)
		$gotPic_pic:=OT GetPicture($otMain_i; "pic9a")
		If (OTr_u_EqualPictures($wombat_pic; $gotPic_pic))
			$otResult_t:="Pass"
		Else 
			$otResult_t:="Fail: picture mismatch"
		End if 
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 10. BLOB
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutBLOB / OT GetNewBLOB"
	$otResult_t:="Fail: not run"
	CONVERT FROM TEXT("compat-blob-data"; "UTF-8"; $testBlob_blob)
	
	OT PutBLOB($otMain_i; "blob"; $testBlob_blob)
	$gotBlob_blob:=OT GetNewBLOB($otMain_i; "blob")
	If (OTr_u_EqualBLOBs($testBlob_blob; $gotBlob_blob))
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: BLOB content mismatch"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 11. Variable
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutVariable / OT GetVariable"
	$otResult_t:="Fail: not run"
	$otVarTarget_t:="ot-var-val"
	$otVarDest_t:=""
	
	OT PutVariable($otMain_i; "var"; ->$otVarTarget_t)
	OT GetVariable($otMain_i; "var"; ->$otVarDest_t)
	If ($otVarDest_t="ot-var-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$otVarDest_t+"'"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 12. Record  (Intentional difference §4.3)
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutRecord / OT GetRecord"
	$otResult_t:="Fail: not run"
	
	// Create and save a record so OT PutRecord has a current record.
	CREATE RECORD([Table_1:1])
	[Table_1:1]Name:2:="Wayne"
	SAVE RECORD([Table_1:1])
	
	var $tablePtr : Pointer
	$tablePtr:=->[Table_1:1]
	OT PutRecord($otMain_i; "rec"; $tablePtr)
	
	CREATE RECORD([Table_1:1])
	OT GetRecord($otMain_i; "rec")
	[Table_1:1]ID:1:=Sequence number([Table_1:1])
	SAVE RECORD([Table_1:1])
	
	If (OK=1)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: OT GetRecord set OK=0"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 13. Dot-path
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutString (dotted) / OT GetString"
	$otResult_t:="Fail: not run"
	
	OT PutString($otMain_i; "a.b.c"; "dot-val")
	$gotten_t:=OT GetString($otMain_i; "a.b.c")
	If ($gotten_t="dot-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$gotten_t+"'"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 14. Array Longint
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutArrayLong / OT GetArrayLong"
	$otResult_t:="Fail: not run"
	
	// Declare a 3-element LongInt array (§25 reuses indices 2 and 3)
	ARRAY LONGINT($setupAl_ai; 3)
	OT PutArray($otMain_i; "al"; $setupAl_ai)
	
	OT PutArrayLong($otMain_i; "al"; 1; 100)
	$otArrVal_i:=OT GetArrayLong($otMain_i; "al"; 1)
	If ($otArrVal_i=100)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($otArrVal_i)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 15. Array Text
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutArrayString / OT GetArrayString"
	$otResult_t:="Fail: not run"
	
	ARRAY TEXT($setupAs_at; 1)
	OT PutArray($otMain_i; "as"; $setupAs_at)
	
	OT PutArrayString($otMain_i; "as"; 1; "arr-str-val")
	$otArrStr_t:=OT GetArrayString($otMain_i; "as"; 1)
	If ($otArrStr_t="arr-str-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$otArrStr_t+"'"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 16. Array Real
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutArrayReal / OT GetArrayReal"
	$otResult_t:="Fail: not run"
	
	ARRAY REAL($setupAr_arr; 1)
	OT PutArray($otMain_i; "ar"; $setupAr_arr)
	
	OT PutArrayReal($otMain_i; "ar"; 1; 9.99)
	$otArrReal_r:=OT GetArrayReal($otMain_i; "ar"; 1)
	If ($otArrReal_r=9.99)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($otArrReal_r)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 17. Array Boolean
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutArrayBoolean / OT GetArrayBoolean"
	$otResult_t:="Fail: not run"
	
	ARRAY BOOLEAN($setupAb_ab; 1)
	OT PutArray($otMain_i; "ab"; $setupAb_ab)
	
	OT PutArrayBoolean($otMain_i; "ab"; 1; Num(True))
	$otArrBool_i:=OT GetArrayBoolean($otMain_i; "ab"; 1)
	If ($otArrBool_i=1)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($otArrBool_i)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 18. Array Pointer
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutArrayPointer / OT GetArrayPointer"
	$otResult_t:="Fail: not run"
	OTr_DummyVariableForTests_t:="arr-ptr-val"
	
	var $otArrPtrOut_ptr : Pointer
	ARRAY POINTER($setupAptr_aptr; 1)
	OT PutArray($otMain_i; "aptr"; $setupAptr_aptr)
	
	OT PutArrayPointer($otMain_i; "aptr"; 1; ->OTr_DummyVariableForTests_t)
	OT GetArrayPointer($otMain_i; "aptr"; 1; $otArrPtrOut_ptr)
	If (OK=1)
		If ($otArrPtrOut_ptr#Null)
			If ($otArrPtrOut_ptr->="arr-ptr-val")
				$otResult_t:="Pass"
			Else 
				$otResult_t:="Fail: value mismatch"
			End if 
		Else 
			$otResult_t:="Fail: Null pointer"
		End if 
	Else 
		$otResult_t:="Fail: OK=0"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 19. Array Picture (empty picture)
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutArrayPicture / OT GetArrayPicture"
	$otResult_t:="Fail: not run"
	
	// Intentional difference: OT re-encodes array pictures
	// internally; exact equality cannot be assumed. Test checks
	// that a non-empty picture is returned (round-trip succeeds).
	ARRAY PICTURE($setupApic_apic; 1)
	OT PutArray($otMain_i; "apic"; $setupApic_apic)
	
	OT PutArrayPicture($otMain_i; "apic"; 1; $wombat_pic)
	$otArrPicOut_pic:=OT GetArrayPicture($otMain_i; "apic"; 1)
	If (Picture size($otArrPicOut_pic)>0)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: empty picture returned"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 19a. Array Picture (wombat)
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT PutArrayPicture / OT GetArrayPicture"
	$otResult_t:="Fail: not run"
	
	If (Picture size($wombat_pic)=0)
		$otResult_t:="Skip: Wombat picture not loaded"
	Else 
		OT PutArrayPicture($otMain_i; "apic"; 1; $wombat_pic)
		$otArrPicOut_pic:=OT GetArrayPicture($otMain_i; "apic"; 1)
		If (OTr_u_EqualPictures($wombat_pic; $otArrPicOut_pic))
			$otResult_t:="Pass"
		Else 
			$otResult_t:="Fail: picture mismatch"
		End if 
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 20. Item info
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT ItemExists / OT ItemType"
	$otResult_t:="Fail: not run"
	
	// "str" was stored in §2; OT type for String/Text is 112.
	If (OT ItemExists($otMain_i; "str")=1) & (OT ItemType($otMain_i; "str")=112)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: ItemExists or ItemType mismatch"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 21. Item count
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT ItemCount"
	$otResult_t:="Fail: not run"
	
	// Use a fresh handle with exactly 3 scalar items.
	$h3_i:=OT New
	OT PutString($h3_i; "x"; "a")
	OT PutString($h3_i; "y"; "b")
	OT PutString($h3_i; "z"; "c")
	
	$otCount_i:=OT ItemCount($h3_i)
	If ($otCount_i=3)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($otCount_i)
	End if 
	
	OT Clear($h3_i)
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 22. Property enumeration
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT GetAllProperties"
	$otResult_t:="Fail: not run"
	
	$h3_i:=OT New
	OT PutString($h3_i; "p1"; "v1")
	OT PutString($h3_i; "p2"; "v2")
	
	ARRAY TEXT(OTr_TextArrayForTests_at; 0)
	OT GetAllProperties($h3_i; OTr_TextArrayForTests_at)
	If (Size of array(OTr_TextArrayForTests_at)=2)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String(Size of array(OTr_TextArrayForTests_at))+" names"
	End if 
	
	OT Clear($h3_i)
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 23. Delete / Rename
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT DeleteItem / OT RenameItem"
	$otResult_t:="Fail: not run"
	
	$h3_i:=OT New
	OT PutString($h3_i; "del"; "gone")
	OT PutString($h3_i; "ren"; "stays")
	
	OT DeleteItem($h3_i; "del")
	OT RenameItem($h3_i; "ren"; "renamed")
	If (OT ItemExists($h3_i; "del")=0) & (OT ItemExists($h3_i; "renamed")=1)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: delete or rename did not work"
	End if 
	
	OT Clear($h3_i)
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 24. Copy
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT CopyItem"
	$otResult_t:="Fail: not run"
	
	$h3_i:=OT New
	OT PutString($otMain_i; "src"; "copy-val")
	OT CopyItem($otMain_i; "src"; $h3_i; "dst")
	$gotten_t:=OT GetString($h3_i; "dst")
	If ($gotten_t="copy-val")
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got '"+$gotten_t+"'"
	End if 
	
	OT Clear($h3_i)
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 25. Size of array
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT SizeOfArray"
	$otResult_t:="Fail: not run"
	
	// "al" was seeded in §14 with element 1 = 100.
	// Add elements 2 and 3; size should now be 3.
	OT PutArrayLong($otMain_i; "al"; 2; 200)
	OT PutArrayLong($otMain_i; "al"; 3; 300)
	
	$otArrSize_i:=OT SizeOfArray($otMain_i; "al")
	If ($otArrSize_i=3)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: got "+String($otArrSize_i)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 26. Sort arrays
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT SortArrays"
	$otResult_t:="Fail: not run"
	
	$h3_i:=OT New
	ARRAY LONGINT($setupSort_ai; 3)
	OT PutArray($h3_i; "sort"; $setupSort_ai)
	
	OT PutArrayLong($h3_i; "sort"; 1; 30)
	OT PutArrayLong($h3_i; "sort"; 2; 10)
	OT PutArrayLong($h3_i; "sort"; 3; 20)
	OT SortArrays($h3_i; "sort"; ">")
	$gotLong_i:=OT GetArrayLong($h3_i; "sort"; 1)
	If ($gotLong_i=10)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: first element after sort = "+String($gotLong_i)
	End if 
	
	OT Clear($h3_i)
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 27. Object size  (Intentional difference §4.3)
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT ObjectSize"
	$otResult_t:="Fail: not run"
	
	// Values will not match OTr (§4.3); both must be non-zero.
	$otSize_i:=OT ObjectSize($otMain_i)
	If ($otSize_i>0)
		$otResult_t:="Pass (size="+String($otSize_i)+")"
	Else 
		$otResult_t:="Fail: returned 0"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 28. BLOB serialisation (Intentional diff §4.3)
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT ObjectToBLOB / OT BLOBToObject"
	$otResult_t:="Fail: not run"
	
	// Round-trip within OT independently; do NOT cross-load
	// (OT and OTr formats are incompatible per §4.3).
	$h3_i:=OT New
	OT PutString($h3_i; "bser"; "blob-ser-val")
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
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 29. Version
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT GetVersion"
	$otResult_t:="Fail: not run"
	
	// Values will differ from OTr; both must be non-empty.
	$otVer_t:=OT GetVersion
	If (Length($otVer_t)>0)
		$otResult_t:="Pass (v="+$otVer_t+")"
	Else 
		$otResult_t:="Fail: empty version"
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- 30. Options
	// ====================================================
	$n_i:=$n_i+1
	$otCmd_t:="OT GetOptions / OT SetOptions"
	$otResult_t:="Fail: not run"
	$testOpts_i:=1+4  // FailOnItemNotFound + AutoCreateObjects
	
	$originalOtOpts_i:=OT GetOptions
	OT SetOptions($testOpts_i)
	$readOtOpts_i:=OT GetOptions
	OT SetOptions($originalOtOpts_i)
	If ($readOtOpts_i=$testOpts_i)
		$otResult_t:="Pass"
	Else 
		$otResult_t:="Fail: read "+String($readOtOpts_i)+" expected "+String($testOpts_i)
	End if 
	
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- TEARDOWN
	// ====================================================
	OT Clear($otMain_i)
	
End if 



*/
// ==== END OT BLOCK ====
