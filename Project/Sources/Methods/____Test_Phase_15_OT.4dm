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
// installed as a plugin. If OTr_New returns 0, all OT
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

//var $otMain_i : Integer
//var $testOtH_i : Integer
//var $loadedOtH_i : Integer
//var $h3_i : Integer
//var $reg_i : Integer
//var $ready_b : Boolean
//var $count_i : Integer
//var $n_i : Integer
//var $gotten_t : Text
//var $gotLong_i : Integer
//var $gotReal_r : Real
//var $gotBool_i : Integer
//var $testDate_d : Date
//var $gotDate_d : Date
//var $testTime_h : Time
//var $gotTime_h : Time
//var otPtrTarget_t : Text  // process variable -- required for Get pointer round-trip
//var $wombat_pic : Picture
//var $gotPic_pic : Picture
//var $otArrPicOut_pic : Picture
//var $testBlob_blob : Blob
//var $gotBlob_blob : Blob
//var $otBlob_blob : Blob
//var $otVarTarget_t : Text
//var $otVarDest_t : Text
//var $gotItemExists_i : Integer
//var $gotItemType_i : Integer
//var $otCount_i : Integer
//var $otArrSize_i : Integer
//var $otSize_i : Integer
//var $otVer_t : Text
//var $originalOtOpts_i : Integer
//var $testOpts_i : Integer
//var $readOtOpts_i : Integer
//var $otArrVal_i : Integer
//var $otArrStr_t : Text
//var $otArrReal_r : Real
//var $otArrBool_i : Integer
//var $otCmd_t : Text
//var $otResult_t : Text

//ARRAY LONGINT($setupAl_ai; 0)
//ARRAY TEXT($setupAs_at; 0)
//ARRAY REAL($setupAr_arr; 0)
//ARRAY BOOLEAN($setupAb_ab; 0)
//ARRAY POINTER($setupAptr_aptr; 0)
//ARRAY PICTURE($setupApic_apic; 0)
//ARRAY LONGINT($setupSort_ai; 0)

//// Arrays without $ are process variables (required for OT
//// commands that take untyped array parameters by reference).
//ARRAY TEXT(otPropNames_at; 0)

//// ----------------------------------------------------
//// Check plugin availability
//// ----------------------------------------------------
//$ready_b:=True
//$reg_i:=OTr_Register("20C9-EMQv-BJBl-D20M")
//$testOtH_i:=OTr_New

//If ($testOtH_i=0)
//ALERT("ObjectTools 5.0 is not available or nOTr_Registered."+Char(Carriage return)+"OT columns will be marked as skipped.")
//$ready_b:=False
//$count_i:=OTr_SizeOfArray($accum_i; "testNum")
//For ($n_i; 1; $count_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; "Plugin not available")
//OTr_PutArrayText($accum_i; "otResult"; $n_i; "Skip: plugin not available")
//End for 
//Else 
//OTr_Clear($testOtH_i)
//End if 

//If ($ready_b)

//$wombat_pic:=OTr_z_Wombat
//$otMain_i:=OTr_New
//$n_i:=0

//// ====================================================
////MARK:- 1. Creation / Destruction
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_New / OTr_Clear"
//$otResult_t:="Fail: not run"

//$testOtH_i:=OTr_New
//If ($testOtH_i#0)
//OTr_Clear($testOtH_i)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: OTr_New returned 0"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 2. String / Text
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutString / OTr_GetString"
//$otResult_t:="Fail: not run"

//OTr_PutString($otMain_i; "str"; "compat-str")
//$gotten_t:=OTr_GetString($otMain_i; "str")
//If ($gotten_t="compat-str")
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got '"+$gotten_t+"'"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 3. Longint
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutLong / OTr_GetLong"
//$otResult_t:="Fail: not run"

//OTr_PutLong($otMain_i; "num"; 424242)
//$gotLong_i:=OTr_GetLong($otMain_i; "num")
//If ($gotLong_i=424242)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($gotLong_i)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 4. Real
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutReal / OTr_GetReal"
//$otResult_t:="Fail: not run"

//OTr_PutReal($otMain_i; "ratio"; 3.14159)
//$gotReal_r:=OTr_GetReal($otMain_i; "ratio")
//If ($gotReal_r=3.14159)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($gotReal_r)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 5. Boolean
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutBoolean / OTr_GetBoolean"
//$otResult_t:="Fail: not run"

//OTr_PutBoolean($otMain_i; "flag"; Num(True))
//$gotBool_i:=OTr_GetBoolean($otMain_i; "flag")
//If ($gotBool_i=1)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($gotBool_i)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 6. Date
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutDate / OTr_GetDate"
//$otResult_t:="Fail: not run"
//$testDate_d:=!2026-04-04!

//OTr_PutDate($otMain_i; "dt"; $testDate_d)
//$gotDate_d:=OTr_GetDate($otMain_i; "dt")
//If ($gotDate_d=$testDate_d)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($gotDate_d)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 7. Time
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutTime / OTr_GetTime"
//$otResult_t:="Fail: not run"
//$testTime_h:=?10:30:45?

//OTr_PutTime($otMain_i; "tm"; $testTime_h)
//$gotTime_h:=OTr_GetTime($otMain_i; "tm")
//If ($gotTime_h=$testTime_h)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($gotTime_h)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 8. Pointer
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutPointer / OTr_GetPointer"
//$otResult_t:="Fail: not run"
//otPtrTarget_t:="ot-ptr-val"

//var $ptrVar : Pointer
//$ptrVar:=->otPtrTarget_t
//var $ptrVarOut : Pointer

//OTr_PutPointer($otMain_i; "ptr"; $ptrVar)
//OTr_GetPointer($otMain_i; "ptr"; $ptrVarOut)
//If (OK=1) & ($ptrVarOut#Null) & (($ptrVarOut->)=otPtrTarget_t)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: dereference mismatch or OK=0"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 9. Picture (empty picture)
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutPicture / OTr_GetPicture"
//$otResult_t:="Fail: not run"

//OTr_PutPicture($otMain_i; "pic"; $wombat_pic)
//$gotPic_pic:=OTr_GetPicture($otMain_i; "pic")
//If (OTr_uEqualPictures($wombat_pic; $gotPic_pic))
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: picture mismatch"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 9a. Picture (wombat)
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutPicture / OTr_GetPicture"
//$otResult_t:="Fail: not run"

//If (Picture size($wombat_pic)=0)
//$otResult_t:="Skip: Wombat picture not loaded"
//Else 
//OTr_PutPicture($otMain_i; "pic9a"; $wombat_pic)
//$gotPic_pic:=OTr_GetPicture($otMain_i; "pic9a")
//If (OTr_uEqualPictures($wombat_pic; $gotPic_pic))
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: picture mismatch"
//End if 
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 10. BLOB
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutBLOB / OTr_GetNewBLOB"
//$otResult_t:="Fail: not run"
//CONVERT FROM TEXT("compat-blob-data"; "UTF-8"; $testBlob_blob)

//OTr_PutBLOB($otMain_i; "blob"; $testBlob_blob)
//$gotBlob_blob:=OTr_GetNewBLOB($otMain_i; "blob")
//If (OTr_uEqualBLOBs($testBlob_blob; $gotBlob_blob))
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: BLOB content mismatch"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 11. Variable
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutVariable / OTr_GetVariable"
//$otResult_t:="Fail: not run"
//$otVarTarget_t:="ot-var-val"
//$otVarDest_t:=""

//OTr_PutVariable($otMain_i; "var"; ->$otVarTarget_t)
//OTr_GetVariable($otMain_i; "var"; ->$otVarDest_t)
//If ($otVarDest_t="ot-var-val")
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got '"+$otVarDest_t+"'"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 12. Record  (Intentional difference §4.3)
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutRecord / OTr_GetRecord"
//$otResult_t:="Fail: not run"

//// Create and save a record so OTr_PutRecord has a current record.
//CREATE RECORD([Table_1])
//[Table_1]Name:="Wayne"
//SAVE RECORD([Table_1])

//var $tablePtr : Pointer
//$tablePtr:=->[Table_1]
//OTr_PutRecord($otMain_i; "rec"; $tablePtr)

//CREATE RECORD([Table_1])
//OTr_GetRecord($otMain_i; "rec")
//[Table_1]ID:=Sequence number([Table_1])
//SAVE RECORD([Table_1])

//If (OK=1)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: OTr_GetRecord set OK=0"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 13. Dot-path
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutString (dotted) / OTr_GetString"
//$otResult_t:="Fail: not run"

//OTr_PutString($otMain_i; "a.b.c"; "dot-val")
//$gotten_t:=OTr_GetString($otMain_i; "a.b.c")
//If ($gotten_t="dot-val")
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got '"+$gotten_t+"'"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 14. Array Longint
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutArrayLong / OTr_GetArrayLong"
//$otResult_t:="Fail: not run"

//// Declare a 3-element LongInt array (§25 reuses indices 2 and 3)
//ARRAY LONGINT($setupAl_ai; 3)
//OTr_PutArray($otMain_i; "al"; $setupAl_ai)

//OTr_PutArrayLong($otMain_i; "al"; 1; 100)
//$otArrVal_i:=OTr_GetArrayLong($otMain_i; "al"; 1)
//If ($otArrVal_i=100)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($otArrVal_i)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 15. Array Text
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutArrayString / OTr_GetArrayString"
//$otResult_t:="Fail: not run"

//ARRAY TEXT($setupAs_at; 1)
//OTr_PutArray($otMain_i; "as"; $setupAs_at)

//OTr_PutArrayString($otMain_i; "as"; 1; "arr-str-val")
//$otArrStr_t:=OTr_GetArrayString($otMain_i; "as"; 1)
//If ($otArrStr_t="arr-str-val")
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got '"+$otArrStr_t+"'"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 16. Array Real
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutArrayReal / OTr_GetArrayReal"
//$otResult_t:="Fail: not run"

//ARRAY REAL($setupAr_arr; 1)
//OTr_PutArray($otMain_i; "ar"; $setupAr_arr)

//OTr_PutArrayReal($otMain_i; "ar"; 1; 9.99)
//$otArrReal_r:=OTr_GetArrayReal($otMain_i; "ar"; 1)
//If ($otArrReal_r=9.99)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($otArrReal_r)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 17. Array Boolean
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutArrayBoolean / OTr_GetArrayBoolean"
//$otResult_t:="Fail: not run"

//ARRAY BOOLEAN($setupAb_ab; 1)
//OTr_PutArray($otMain_i; "ab"; $setupAb_ab)

//OTr_PutArrayBoolean($otMain_i; "ab"; 1; Num(True))
//$otArrBool_i:=OTr_GetArrayBoolean($otMain_i; "ab"; 1)
//If ($otArrBool_i=1)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($otArrBool_i)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 18. Array Pointer
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutArrayPointer / OTr_GetArrayPointer"
//$otResult_t:="Fail: not run"
//otPtrTarget_t:="arr-ptr-val"

//var $otArrPtrOut_ptr : Pointer
//ARRAY POINTER($setupAptr_aptr; 1)
//OTr_PutArray($otMain_i; "aptr"; $setupAptr_aptr)

//OTr_PutArrayPointer($otMain_i; "aptr"; 1; ->otPtrTarget_t)
//OTr_GetArrayPointer($otMain_i; "aptr"; 1; $otArrPtrOut_ptr)
//If (OK=1)
//If ($otArrPtrOut_ptr#Null)
//If ($otArrPtrOut_ptr->="arr-ptr-val")
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: value mismatch"
//End if 
//Else 
//$otResult_t:="Fail: Null pointer"
//End if 
//Else 
//$otResult_t:="Fail: OK=0"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 19. Array Picture (empty picture)
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutArrayPicture / OTr_GetArrayPicture"
//$otResult_t:="Fail: not run"

//// Intentional difference: OT re-encodes array pictures
//// internally; exact equality cannot be assumed. Test checks
//// that a non-empty picture is returned (round-trip succeeds).
//ARRAY PICTURE($setupApic_apic; 1)
//OTr_PutArray($otMain_i; "apic"; $setupApic_apic)

//OTr_PutArrayPicture($otMain_i; "apic"; 1; $wombat_pic)
//$otArrPicOut_pic:=OTr_GetArrayPicture($otMain_i; "apic"; 1)
//If (Picture size($otArrPicOut_pic)>0)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: empty picture returned"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 19a. Array Picture (wombat)
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutArrayPicture / OTr_GetArrayPicture"
//$otResult_t:="Fail: not run"

//If (Picture size($wombat_pic)=0)
//$otResult_t:="Skip: Wombat picture not loaded"
//Else 
//OTr_PutArrayPicture($otMain_i; "apic"; 1; $wombat_pic)
//$otArrPicOut_pic:=OTr_GetArrayPicture($otMain_i; "apic"; 1)
//If (OTr_uEqualPictures($wombat_pic; $otArrPicOut_pic))
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: picture mismatch"
//End if 
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 20. Item info
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_ItemExists / OTr_ItemType"
//$otResult_t:="Fail: not run"

//// "str" was stored in §2; OT type for String/Text is 112.
//If (OTr_ItemExists($otMain_i; "str")=1) & (OTr_ItemType($otMain_i; "str")=112)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: ItemExists or ItemType mismatch"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 21. Item count
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_ItemCount"
//$otResult_t:="Fail: not run"

//// Use a fresh handle with exactly 3 scalar items.
//$h3_i:=OTr_New
//OTr_PutString($h3_i; "x"; "a")
//OTr_PutString($h3_i; "y"; "b")
//OTr_PutString($h3_i; "z"; "c")

//$otCount_i:=OTr_ItemCount($h3_i)
//If ($otCount_i=3)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($otCount_i)
//End if 

//OTr_Clear($h3_i)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 22. Property enumeration
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_GetAllProperties"
//$otResult_t:="Fail: not run"

//$h3_i:=OTr_New
//OTr_PutString($h3_i; "p1"; "v1")
//OTr_PutString($h3_i; "p2"; "v2")

//ARRAY TEXT(otPropNames_at; 0)
//OTr_GetAllProperties($h3_i; otPropNames_at)
//If (Size of array(otPropNames_at)=2)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String(Size of array(otPropNames_at))+" names"
//End if 

//OTr_Clear($h3_i)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 23. Delete / Rename
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_DeleteItem / OTr_RenameItem"
//$otResult_t:="Fail: not run"

//$h3_i:=OTr_New
//OTr_PutString($h3_i; "del"; "gone")
//OTr_PutString($h3_i; "ren"; "stays")

//OTr_DeleteItem($h3_i; "del")
//OTr_RenameItem($h3_i; "ren"; "renamed")
//If (OTr_ItemExists($h3_i; "del")=0) & (OTr_ItemExists($h3_i; "renamed")=1)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: delete or rename did not work"
//End if 

//OTr_Clear($h3_i)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 24. Copy
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_CopyItem"
//$otResult_t:="Fail: not run"

//$h3_i:=OTr_New
//OTr_PutString($otMain_i; "src"; "copy-val")
//OTr_CopyItem($otMain_i; "src"; $h3_i; "dst")
//$gotten_t:=OTr_GetString($h3_i; "dst")
//If ($gotten_t="copy-val")
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got '"+$gotten_t+"'"
//End if 

//OTr_Clear($h3_i)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 25. Size of array
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_SizeOfArray"
//$otResult_t:="Fail: not run"

//// "al" was seeded in §14 with element 1 = 100.
//// Add elements 2 and 3; size should now be 3.
//OTr_PutArrayLong($otMain_i; "al"; 2; 200)
//OTr_PutArrayLong($otMain_i; "al"; 3; 300)

//$otArrSize_i:=OTr_SizeOfArray($otMain_i; "al")
//If ($otArrSize_i=3)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: got "+String($otArrSize_i)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 26. Sort arrays
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_SortArrays"
//$otResult_t:="Fail: not run"

//$h3_i:=OTr_New
//ARRAY LONGINT($setupSort_ai; 3)
//OTr_PutArray($h3_i; "sort"; $setupSort_ai)

//OTr_PutArrayLong($h3_i; "sort"; 1; 30)
//OTr_PutArrayLong($h3_i; "sort"; 2; 10)
//OTr_PutArrayLong($h3_i; "sort"; 3; 20)
//OTr_SortArrays($h3_i; "sort"; ">")
//$gotLong_i:=OTr_GetArrayLong($h3_i; "sort"; 1)
//If ($gotLong_i=10)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: first element after sort = "+String($gotLong_i)
//End if 

//OTr_Clear($h3_i)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 27. Object size  (Intentional difference §4.3)
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_ObjectSize"
//$otResult_t:="Fail: not run"

//// Values will not match OTr (§4.3); both must be non-zero.
//$otSize_i:=OTr_ObjectSize($otMain_i)
//If ($otSize_i>0)
//$otResult_t:="Pass (size="+String($otSize_i)+")"
//Else 
//$otResult_t:="Fail: returned 0"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 28. BLOB serialisation (Intentional diff §4.3)
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_ObjectToBLOB / OTr_BLOBToObject"
//$otResult_t:="Fail: not run"

//// Round-trip within OT independently; do NOT cross-load
//// (OT and OTr formats are incompatible per §4.3).
//$h3_i:=OTr_New
//OTr_PutString($h3_i; "bser"; "blob-ser-val")
//OTr_ObjectToBLOB($h3_i; $otBlob_blob)
//$loadedOtH_i:=OTr_BLOBToObject($otBlob_blob)
//$gotten_t:=OTr_GetString($loadedOtH_i; "bser")
//If ($gotten_t="blob-ser-val")
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: round-trip got '"+$gotten_t+"'"
//End if 
//OTr_Clear($h3_i)
//OTr_Clear($loadedOtH_i)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 29. Version
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_GetVersion"
//$otResult_t:="Fail: not run"

//// Values will differ from OTr; both must be non-empty.
//$otVer_t:=OTr_GetVersion
//If (Length($otVer_t)>0)
//$otResult_t:="Pass (v="+$otVer_t+")"
//Else 
//$otResult_t:="Fail: empty version"
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 30. Options
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OTr_GetOptions / OTr_SetOptions"
//$otResult_t:="Fail: not run"
//$testOpts_i:=1+4  // FailOnItemNotFound + AutoCreateObjects

//$originalOtOpts_i:=OTr_GetOptions
//OTr_SetOptions($testOpts_i)
//$readOtOpts_i:=OTr_GetOptions
//OTr_SetOptions($originalOtOpts_i)
//If ($readOtOpts_i=$testOpts_i)
//$otResult_t:="Pass"
//Else 
//$otResult_t:="Fail: read "+String($readOtOpts_i)+" expected "+String($testOpts_i)
//End if 

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- TEARDOWN
//// ====================================================
//OTr_Clear($otMain_i)

//End if 

// ==== END OT BLOCK ====
