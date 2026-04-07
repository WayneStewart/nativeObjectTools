//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10_OT ($accum_i)

// Executes the OT half of the Phase 10 logging-focused
// side-by-side test. For each of the 9 error-condition
// scenarios (in the same order as ____Test_Phase_10_OTr),
// runs the legacy ObjectTools 5.0 command and updates the
// otCmd and otResult columns in the accumulator by
// sequential index using OTr_PutArrayText.
//
// PLATFORM REQUIREMENT: ObjectTools 5.0 must be installed
// as a plugin. If OT New returns 0, all OT columns are set
// to "Skip: plugin not available" and the method returns.
//
// TAHOE COMPILATION: Comment out the entire method body
// below the #DECLARE line when building on macOS Tahoe
// 26.4 or later (plugin absent). The OTr accumulator is
// unaffected; only the OT columns remain empty.
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-07
// Refactored from ____Test_Phase_10 by Wayne Stewart.
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($accum_i : Integer)

// ==== BEGIN OT BLOCK — comment out on Tahoe 26.4+ ====

//var $otMain_i : Integer
//var $testOtH_i : Integer
//var $reg_i : Integer
//var $ready_b : Boolean
//var $count_i : Integer
//var $n_i : Integer
//var $gotLong_i : Integer
//var $size_i : Integer
//var $compare_i : Integer
//var $gotPtr_ptr : Pointer
//var $otCmd_t : Text
//var $otResult_t : Text

//// ----------------------------------------------------
//// Check plugin availability
//// ----------------------------------------------------
//$ready_b:=True
//$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")
//$testOtH_i:=OT New

//If ($testOtH_i=0)
//ALERT("ObjectTools 5.0 is not available or not registered."+Char(Carriage return)+"OT columns will be marked as skipped.")
//$ready_b:=False
//$count_i:=OTr_SizeOfArray($accum_i; "testName")
//For ($n_i; 1; $count_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; "Plugin not available")
//OTr_PutArrayText($accum_i; "otResult"; $n_i; "Skip: plugin not available")
//End for 
//Else 
//OT Clear($testOtH_i)
//End if 

//If ($ready_b)

//$otMain_i:=OT New
//$n_i:=0

//// Seed known scalar values so later misuse is deliberate.
//OT PutLong($otMain_i; "scalar"; 123)
//OT PutString($otMain_i; "textItem"; "abc")

//// ====================================================
////MARK:- 1. Invalid handle on getter
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OT GetLong(99999; \"missing\")"
//$otResult_t:="Fail: not run"

//$gotLong_i:=OT GetLong(99999; "missing")
//$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 2. Missing tag on getter
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OT GetLong($otMain_i; \"doesNotExist\")"
//$otResult_t:="Fail: not run"

//$gotLong_i:=OT GetLong($otMain_i; "doesNotExist")
//$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 3. Array write against scalar
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OT PutArrayLong($otMain_i; \"scalar\"; 1; 777)"
//$otResult_t:="Fail: not run"

//OT PutArrayLong($otMain_i; "scalar"; 1; 777)
//$otResult_t:="OK="+String(OK)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 4. SizeOfArray on missing tag
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OT SizeOfArray($otMain_i; \"missingArray\")"
//$otResult_t:="Fail: not run"

//$size_i:=OT SizeOfArray($otMain_i; "missingArray")
//$otResult_t:="returned "+String($size_i)+" OK="+String(OK)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 5. CompareItems type mismatch
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OT CompareItems($otMain_i; \"scalar\"; $otMain_i; \"textItem\")"
//$otResult_t:="Fail: not run"

//$compare_i:=OT CompareItems($otMain_i; "scalar"; $otMain_i; "textItem")
//$otResult_t:="returned "+String($compare_i)+" OK="+String(OK)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 6. Invalid dotted path through scalar
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OT PutLong($otMain_i; \"scalar.child\"; 9)"
//$otResult_t:="Fail: not run"

//OT PutLong($otMain_i; "scalar.child"; 9)
//$otResult_t:="OK="+String(OK)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 7. Pointer getter on missing tag
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OT GetPointer($otMain_i; \"missingPtr\"; $gotPtr_ptr)"
//$otResult_t:="Fail: not run"

//$gotPtr_ptr:=Null
//OT GetPointer($otMain_i; "missingPtr"; $gotPtr_ptr)
//$otResult_t:="OK="+String(OK)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 8. Delete missing tag
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OT DeleteItem($otMain_i; \"missingDelete\")"
//$otResult_t:="Fail: not run"

//OT DeleteItem($otMain_i; "missingDelete")
//$otResult_t:="OK="+String(OK)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- 9. Register call
//// ====================================================
//$n_i:=$n_i+1
//$otCmd_t:="OT Register(\"20C9-EMQv-BJBl-D20M\")"
//$otResult_t:="Fail: not run"

//$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")
//$otResult_t:="returned "+String($reg_i)+" OK="+String(OK)

//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//// ====================================================
////MARK:- TEARDOWN
//// ====================================================
//OT Clear($otMain_i)

//End if 

// ==== END OT BLOCK ====
