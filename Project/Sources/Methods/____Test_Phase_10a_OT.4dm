//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10a_OT ($accum_i)

// Executes the OT half of the Phase 10a broad side-by-side
// sweep. For each scenario (in the same order as
// ____Test_Phase_10a_OTr), runs ObjectTools 5.0 and updates
// otCmd and otResult in the accumulator by sequential index.
//
// PLATFORM REQUIREMENT: ObjectTools 5.0 must be installed
// as a plugin. If unavailable, all OT rows are marked as
// skipped and the method returns.
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-07
// Refactored from ____Test_Phase_10a by Wayne Stewart.
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($accum_i : Integer)

// ====BEGIN OT BLOCK — comment out on Tahoe 26000.4+====

//var $otMain_i : Integer
//var $testOtH_i : Integer
//var $h2_i : Integer
//var $reg_i : Integer
//var $ready_b : Boolean
//var $count_i : Integer
//var $n_i : Integer
//var $gotLong_i : Integer
//var $gotReal_r : Real
//var $gotBool_i : Integer
//var $gotPic_pic : Picture
//var $roundBlob_blob : Blob
//var $ptrOut_ptr : Pointer
//var $version_t : Text
//var $opts_i : Integer
//var $compiled_i : Integer
//var $itemType_i : Integer
//var $itemCount_i : Integer
//var $arraySize_i : Integer
//var $compare_i : Integer
//var $gotBlob_blob : Blob
//var $testDate_d : Date
//var $testTime_h : Time
//var ptrTarget_t : Text
//var $wombat_pic : Picture
//var $varLong_i : Integer
//var $find_i : Integer
//var $otCmd_t : Text
//var $otResult_t : Text

//ARRAY TEXT($names_at; 0)
//ARRAY LONGINT($types_ai; 0)
//ARRAY LONGINT($itemSizes_ai; 0)
//ARRAY LONGINT($dataSizes_ai; 0)
//ARRAY LONGINT($longArr_ai; 0)
//ARRAY LONGINT($longArrOut_ai; 0)

//// Process variable required for OT GetArray
//ARRAY LONGINT(longArr_ai; 0)

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
//$testDate_d:=!2026-04-06!
//$testTime_h:=?10:30:45?
//ptrTarget_t:="phase10a"
//$wombat_pic:=OTr_z_Wombat
//TEXT TO BLOB("phase10a-blob"; $gotBlob_blob)
//$n_i:=0

//$n_i:=$n_i+1
//$otCmd_t:="OT Register / OT GetVersion / OT CompiledApplication / OT GetOptions"
//$version_t:=OT GetVersion
//$compiled_i:=OT CompiledApplication
//$opts_i:=OT GetOptions
//$otResult_t:="version="+$version_t+" compiled="+String($compiled_i)+" options="+String($opts_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OT PutString($otMain_i; "str"; "hello")
//OT PutLong($otMain_i; "num"; 42)
//OT PutReal($otMain_i; "real"; 3.5)
//OT PutBoolean($otMain_i; "bool"; 1)
//OT PutDate($otMain_i; "date"; $testDate_d)
//OT PutTime($otMain_i; "time"; $testTime_h)
//$gotLong_i:=OT GetLong($otMain_i; "num")
//$gotReal_r:=OT GetReal($otMain_i; "real")
//$gotBool_i:=OT GetBoolean($otMain_i; "bool")
//$n_i:=$n_i+1
//$otCmd_t:="OT Put/Get String Long Real Boolean Date Time"
//$otResult_t:=OT GetString($otMain_i; "str")+" / "+String($gotLong_i)+" / "+String($gotReal_r)+" / "+String($gotBool_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OT PutPointer($otMain_i; "ptr"; ->ptrTarget_t)
//OT PutBLOB($otMain_i; "blob"; $gotBlob_blob)
//OT PutPicture($otMain_i; "pic"; $wombat_pic)
//$ptrOut_ptr:=Null
//OT GetPointer($otMain_i; "ptr"; $ptrOut_ptr)
//$roundBlob_blob:=OT GetNewBLOB($otMain_i; "blob")
//$gotPic_pic:=OT GetPicture($otMain_i; "pic")
//$n_i:=$n_i+1
//$otCmd_t:="OT Put/GetPointer GetNewBLOB Put/GetPicture"
//$otResult_t:="ptrOK="+String(OK)+" blobSize="+String(BLOB size($roundBlob_blob))+" pic="+Choose($gotPic_pic#Null; "yes"; "no")
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$testOtH_i:=OT New
//OT PutString($testOtH_i; "childName"; "kid")
//OT PutObject($otMain_i; "child"; $testOtH_i)
//$h2_i:=OT GetObject($otMain_i; "child")
//$n_i:=$n_i+1
//$otCmd_t:="OT PutObject / OT GetObject"
//$otResult_t:="childHandle="+String($h2_i)+" childName="+OT GetString($h2_i; "childName")
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
//If ($testOtH_i#0)
//OT Clear($testOtH_i)
//End if 
//If ($h2_i#0)
//OT Clear($h2_i)
//End if 

//$varLong_i:=1234
//OT PutVariable($otMain_i; "varLong"; ->$varLong_i)
//$varLong_i:=0
//OT GetVariable($otMain_i; "varLong"; ->$varLong_i)
//$n_i:=$n_i+1
//$otCmd_t:="OT PutVariable / OT GetVariable"
//$otResult_t:="varLong="+String($varLong_i)+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//ARRAY LONGINT($longArr_ai; 3)
//$longArr_ai{1}:=10
//$longArr_ai{2}:=20
//$longArr_ai{3}:=30
//OT PutArray($otMain_i; "arr"; $longArr_ai)
//OT PutArrayLong($otMain_i; "arr"; 2; 99)
//OT InsertElement($otMain_i; "arr"; 2)
//OT PutArrayLong($otMain_i; "arr"; 2; 77)
//OT DeleteElement($otMain_i; "arr"; 4)
//$arraySize_i:=OT SizeOfArray($otMain_i; "arr")
//$gotLong_i:=OT GetArrayLong($otMain_i; "arr"; 2)
//$n_i:=$n_i+1
//$otCmd_t:="OT PutArray / PutArrayLong / InsertElement / DeleteElement / SizeOfArray / GetArrayLong"
//$otResult_t:="size="+String($arraySize_i)+" elem2="+String($gotLong_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//ARRAY LONGINT(longArr_ai; 3)
//longArr_ai{1}:=10
//longArr_ai{2}:=20
//longArr_ai{3}:=30
//OT ResizeArray($otMain_i; "arr"; 5)
//OT PutArrayLong($otMain_i; "arr"; 5; 555)
//OT GetArray($otMain_i; "arr"; longArr_ai)
//$find_i:=OT FindInArray($otMain_i; "arr"; String(555))
//$n_i:=$n_i+1
//$otCmd_t:="OT ResizeArray / GetArray / FindInArray"
//$otResult_t:="size="+String(Size of array(longArr_ai))+" find555="+String($find_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$itemCount_i:=OT ItemCount($otMain_i)
//$itemType_i:=OT ItemType($otMain_i; "str")
//$n_i:=$n_i+1
//$otCmd_t:="OT IsObject / ItemCount / ItemType / ObjectSize"
//$otResult_t:="isObject="+String(OT IsObject($otMain_i))+" itemCount="+String($itemCount_i)+" itemType(str)="+String($itemType_i)+" size="+String(OT ObjectSize($otMain_i))
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//ARRAY TEXT($names_at; 0)
//ARRAY LONGINT($types_ai; 0)
//ARRAY LONGINT($itemSizes_ai; 0)
//ARRAY LONGINT($dataSizes_ai; 0)
//OT GetAllProperties($otMain_i; $names_at; $types_ai; $itemSizes_ai; $dataSizes_ai)
//$n_i:=$n_i+1
//$otCmd_t:="OT GetAllProperties / ItemExists / IsEmbedded"
//$otResult_t:="allProps="+String(Size of array($names_at))+" exists(str)="+String(OT ItemExists($otMain_i; "str"))+" embedded(child)="+String(OT IsEmbedded($otMain_i; "child"))
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OT CopyItem($otMain_i; "str"; $otMain_i; "strCopy")
//$compare_i:=OT CompareItems($otMain_i; "str"; $otMain_i; "strCopy")
//OT RenameItem($otMain_i; "strCopy"; "strRenamed")
//OT DeleteItem($otMain_i; "strRenamed")
//$n_i:=$n_i+1
//$otCmd_t:="OT CopyItem / CompareItems / RenameItem / DeleteItem"
//$otResult_t:="compare="+String($compare_i)+" existsAfterDelete="+String(OT ItemExists($otMain_i; "strRenamed"))
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OT ObjectToBLOB($otMain_i; $gotBlob_blob)
//$testOtH_i:=OT BLOBToObject($gotBlob_blob)
//$n_i:=$n_i+1
//$otCmd_t:="OT ObjectToBLOB / BLOBToObject"
//$otResult_t:="blobSize="+String(BLOB size($gotBlob_blob))+" newHandle="+String($testOtH_i)+" getStr="+OT GetString($testOtH_i; "str")
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
//If ($testOtH_i#0)
//OT Clear($testOtH_i)
//End if 

//ARRAY LONGINT($longArrOut_ai; 0)
//OT GetHandleList($longArrOut_ai)
//$n_i:=$n_i+1
//$otCmd_t:="OT GetHandleList"
//$otResult_t:="handles="+String(Size of array($longArrOut_ai))
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OT Clear($otMain_i)
//End if 

// ==== END OT BLOCK ====
