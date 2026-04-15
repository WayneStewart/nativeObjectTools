//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10b_OT ($accum_i)

// Executes the OT half of the Phase 10b misuse suite.
// Runs scenarios in the same order as ____Test_Phase_10b_OTr
// and writes OT command/result columns by index into the
// shared accumulator.
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-07
// Refactored from ____Test_Phase_10b by Wayne Stewart.
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
//var $badBlob_blob : Blob
//var $ptrOut_ptr : Pointer
//var $varText_t : Text
//var $otCmd_t : Text
//var $otResult_t : Text

//$ready_b:=True
//$reg_i:=OT Register(storage.OTr.registrationCode)
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
//OT PutLong($otMain_i; "scalar"; 123)
//OT PutString($otMain_i; "textItem"; "abc")
//$n_i:=0

//$n_i:=$n_i+1
//$otCmd_t:="OT GetLong(99999; \"missing\")"
//$gotLong_i:=OT GetLong(99999; "missing")
//$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT GetLong($otMain_i; \"missing\")"
//$gotLong_i:=OT GetLong($otMain_i; "missing")
//$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT PutArrayLong($otMain_i; \"scalar\"; 1; 777)"
//OT PutArrayLong($otMain_i; "scalar"; 1; 777)
//$otResult_t:="OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT GetArrayLong($otMain_i; \"scalar\"; 99)"
//$gotLong_i:=OT GetArrayLong($otMain_i; "scalar"; 99)
//$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT SizeOfArray($otMain_i; \"missingArray\")"
//$size_i:=OT SizeOfArray($otMain_i; "missingArray")
//$otResult_t:="returned "+String($size_i)+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT CompareItems($otMain_i; \"scalar\"; $otMain_i; \"textItem\")"
//$compare_i:=OT CompareItems($otMain_i; "scalar"; $otMain_i; "textItem")
//$otResult_t:="returned "+String($compare_i)+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT PutLong($otMain_i; scalar.child; 9)"
//OT PutLong($otMain_i; "scalar.child"; 9)
//$otResult_t:="OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT DeleteItem($otMain_i; \"missingDelete\")"
//OT DeleteItem($otMain_i; "missingDelete")
//$otResult_t:="OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT GetPointer($otMain_i; \"missingPtr\"; $ptrOut_ptr)"
//$ptrOut_ptr:=Null
//OT GetPointer($otMain_i; "missingPtr"; $ptrOut_ptr)
//$otResult_t:="OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT BLOBToObject($badBlob_blob)"
//TEXT TO BLOB("this is not a serialised object"; $badBlob_blob)
//$gotLong_i:=OT BLOBToObject($badBlob_blob)
//$otResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT PutVariable long / OT GetVariable into text"
//$gotLong_i:=123
//OT PutVariable($otMain_i; "varMixed"; ->$gotLong_i)
//$varText_t:=""
//OT GetVariable($otMain_i; "varMixed"; ->$varText_t)
//$otResult_t:="text="+$varText_t+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="OT ItemCount(99999)"
//$size_i:=OT ItemCount(99999)
//$otResult_t:="returned "+String($size_i)+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OT Clear($otMain_i)
//End if 

// ==== END OT BLOCK ====
