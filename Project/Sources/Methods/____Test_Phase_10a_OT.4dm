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

//// Process variable required for OTr_GetArray
//ARRAY LONGINT(longArr_ai; 0)

//$ready_b:=True
//$reg_i:=OTr_Register("20C9-EMQv-BJBl-D20M")
//$testOtH_i:=OTr_New

//If ($testOtH_i=0)
//ALERT("ObjectTools 5.0 is not available or nOTr_Registered."+Char(Carriage return)+"OT columns will be marked as skipped.")
//$ready_b:=False
//$count_i:=OTr_SizeOfArray($accum_i; "testName")
//For ($n_i; 1; $count_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; "Plugin not available")
//OTr_PutArrayText($accum_i; "otResult"; $n_i; "Skip: plugin not available")
//End for 
//Else 
//OTr_Clear($testOtH_i)
//End if 

//If ($ready_b)
//$otMain_i:=OTr_New
//$testDate_d:=!2026-04-06!
//$testTime_h:=?10:30:45?
//ptrTarget_t:="phase10a"
//$wombat_pic:=OTr_z_Wombat
//TEXT TO BLOB("phase10a-blob"; $gotBlob_blob)
//$n_i:=0

//$n_i:=$n_i+1
//$otCmd_t:="OTr_Register / OTr_GetVersion / OTr_CompiledApplication / OTr_GetOptions"
//$version_t:=OTr_GetVersion
//$compiled_i:=OTr_CompiledApplication
//$opts_i:=OTr_GetOptions
//$otResult_t:="version="+$version_t+" compiled="+String($compiled_i)+" options="+String($opts_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OTr_PutString($otMain_i; "str"; "hello")
//OTr_PutLong($otMain_i; "num"; 42)
//OTr_PutReal($otMain_i; "real"; 3.5)
//OTr_PutBoolean($otMain_i; "bool"; 1)
//OTr_PutDate($otMain_i; "date"; $testDate_d)
//OTr_PutTime($otMain_i; "time"; $testTime_h)
//$gotLong_i:=OTr_GetLong($otMain_i; "num")
//$gotReal_r:=OTr_GetReal($otMain_i; "real")
//$gotBool_i:=OTr_GetBoolean($otMain_i; "bool")
//$n_i:=$n_i+1
//$otCmd_t:="OT Put/Get String Long Real Boolean Date Time"
//$otResult_t:=OTr_GetString($otMain_i; "str")+" / "+String($gotLong_i)+" / "+String($gotReal_r)+" / "+String($gotBool_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OTr_PutPointer($otMain_i; "ptr"; ->ptrTarget_t)
//OTr_PutBLOB($otMain_i; "blob"; $gotBlob_blob)
//OTr_PutPicture($otMain_i; "pic"; $wombat_pic)
//$ptrOut_ptr:=Null
//OTr_GetPointer($otMain_i; "ptr"; $ptrOut_ptr)
//$roundBlob_blob:=OTr_GetNewBLOB($otMain_i; "blob")
//$gotPic_pic:=OTr_GetPicture($otMain_i; "pic")
//$n_i:=$n_i+1
//$otCmd_t:="OT Put/GetPointer GetNewBLOB Put/GetPicture"
//$otResult_t:="ptrOK="+String(OK)+" blobSize="+String(BLOB size($roundBlob_blob))+" pic="+Choose($gotPic_pic#Null; "yes"; "no")
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$testOtH_i:=OTr_New
//OTr_PutString($testOtH_i; "childName"; "kid")
//OTr_PutObject($otMain_i; "child"; $testOtH_i)
//$h2_i:=OTr_GetObject($otMain_i; "child")
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutObject / OTr_GetObject"
//$otResult_t:="childHandle="+String($h2_i)+" childName="+OTr_GetString($h2_i; "childName")
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
//If ($testOtH_i#0)
//OTr_Clear($testOtH_i)
//End if 
//If ($h2_i#0)
//OTr_Clear($h2_i)
//End if 

//$varLong_i:=1234
//OTr_PutVariable($otMain_i; "varLong"; ->$varLong_i)
//$varLong_i:=0
//OTr_GetVariable($otMain_i; "varLong"; ->$varLong_i)
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutVariable / OTr_GetVariable"
//$otResult_t:="varLong="+String($varLong_i)+" OK="+String(OK)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//ARRAY LONGINT($longArr_ai; 3)
//$longArr_ai{1}:=10
//$longArr_ai{2}:=20
//$longArr_ai{3}:=30
//OTr_PutArray($otMain_i; "arr"; $longArr_ai)
//OTr_PutArrayLong($otMain_i; "arr"; 2; 99)
//OTr_InsertElement($otMain_i; "arr"; 2)
//OTr_PutArrayLong($otMain_i; "arr"; 2; 77)
//OTr_DeleteElement($otMain_i; "arr"; 4)
//$arraySize_i:=OTr_SizeOfArray($otMain_i; "arr")
//$gotLong_i:=OTr_GetArrayLong($otMain_i; "arr"; 2)
//$n_i:=$n_i+1
//$otCmd_t:="OTr_PutArray / PutArrayLong / InsertElement / DeleteElement / SizeOfArray / GetArrayLong"
//$otResult_t:="size="+String($arraySize_i)+" elem2="+String($gotLong_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//ARRAY LONGINT(longArr_ai; 3)
//longArr_ai{1}:=10
//longArr_ai{2}:=20
//longArr_ai{3}:=30
//OTr_ResizeArray($otMain_i; "arr"; 5)
//OTr_PutArrayLong($otMain_i; "arr"; 5; 555)
//OTr_GetArray($otMain_i; "arr"; longArr_ai)
//$find_i:=OTr_FindInArray($otMain_i; "arr"; String(555))
//$n_i:=$n_i+1
//$otCmd_t:="OTr_ResizeArray / GetArray / FindInArray"
//$otResult_t:="size="+String(Size of array(longArr_ai))+" find555="+String($find_i)
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$itemCount_i:=OTr_ItemCount($otMain_i)
//$itemType_i:=OTr_ItemType($otMain_i; "str")
//$n_i:=$n_i+1
//$otCmd_t:="OTr_IsObject / ItemCount / ItemType / ObjectSize"
//$otResult_t:="isObject="+String(OTr_IsObject($otMain_i))+" itemCount="+String($itemCount_i)+" itemType(str)="+String($itemType_i)+" size="+String(OTr_ObjectSize($otMain_i))
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//ARRAY TEXT($names_at; 0)
//ARRAY LONGINT($types_ai; 0)
//ARRAY LONGINT($itemSizes_ai; 0)
//ARRAY LONGINT($dataSizes_ai; 0)
//OTr_GetAllProperties($otMain_i; $names_at; $types_ai; $itemSizes_ai; $dataSizes_ai)
//$n_i:=$n_i+1
//$otCmd_t:="OTr_GetAllProperties / ItemExists / IsEmbedded"
//$otResult_t:="allProps="+String(Size of array($names_at))+" exists(str)="+String(OTr_ItemExists($otMain_i; "str"))+" embedded(child)="+String(OTr_IsEmbedded($otMain_i; "child"))
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OTr_CopyItem($otMain_i; "str"; $otMain_i; "strCopy")
//$compare_i:=OTr_CompareItems($otMain_i; "str"; $otMain_i; "strCopy")
//OTr_RenameItem($otMain_i; "strCopy"; "strRenamed")
//OTr_DeleteItem($otMain_i; "strRenamed")
//$n_i:=$n_i+1
//$otCmd_t:="OTr_CopyItem / CompareItems / RenameItem / DeleteItem"
//$otResult_t:="compare="+String($compare_i)+" existsAfterDelete="+String(OTr_ItemExists($otMain_i; "strRenamed"))
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OTr_ObjectToBLOB($otMain_i; $gotBlob_blob)
//$testOtH_i:=OTr_BLOBToObject($gotBlob_blob)
//$n_i:=$n_i+1
//$otCmd_t:="OTr_ObjectToBLOB / BLOBToObject"
//$otResult_t:="blobSize="+String(BLOB size($gotBlob_blob))+" newHandle="+String($testOtH_i)+" getStr="+OTr_GetString($testOtH_i; "str")
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
//If ($testOtH_i#0)
//OTr_Clear($testOtH_i)
//End if 

//ARRAY LONGINT($longArrOut_ai; 0)
//OTr_GetHandleList($longArrOut_ai)
//$n_i:=$n_i+1
//$otCmd_t:="OTr_GetHandleList"
//$otResult_t:="handles="+String(Size of array($longArrOut_ai))
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//$n_i:=$n_i+1
//$otCmd_t:="No equivalent function"
//$otResult_t:="Pass: no equivalent function"
//OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
//OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)

//OTr_Clear($otMain_i)
//End if 

// ==== END OT BLOCK ====
