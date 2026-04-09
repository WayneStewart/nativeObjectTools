//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10a_OTr ($accum_i)

// Executes the OTr half of the Phase 10a broad
// side-by-side sweep. Runs mostly-correct scenarios and
// writes OTr command/result columns into local arrays,
// then bulk-loads them into the shared accumulator.
//
// Tags written to the accumulator:
//   testName
//   otrCmd
//   otrResult
//
// Also initialises otCmd and otResult arrays (empty,
// same length) so ____Test_Phase_10a_OT can update by index.
//
// Must NOT call OTr_ClearAll -- the accumulator handle
// is owned by the controller (____Test_Phase_10a).
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-07
// Refactored from ____Test_Phase_10a by Wayne Stewart.
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($accum_i : Integer)

var $otrMain_i : Integer
var $testOtrH_i : Integer
var $h2_i : Integer
var $gotLong_i : Integer
var $gotReal_r : Real
var $gotBool_i : Integer
var $gotPic_pic : Picture
var $roundBlob_blob : Blob
var $ptrOut_ptr : Pointer
var $version_t : Text
var $opts_i : Integer
var $compiled_i : Integer
var $itemType_i : Integer
var $itemCount_i : Integer
var $arraySize_i : Integer
var $compare_i : Integer
var $gotBlob_blob : Blob
var $testDate_d : Date
var $testTime_h : Time
var vtCC_Filename : Text
var $wombat_pic : Picture
var $varLong_i : Integer
var $find_i : Integer
var $otrCmd_t : Text
var $otrResult_t : Text
var $count_i : Integer

ARRAY TEXT:C222($testName_at; 0)
ARRAY TEXT:C222($otrCmd_at; 0)
ARRAY TEXT:C222($otrResult_at; 0)
ARRAY TEXT:C222($emptyArr_at; 0)
ARRAY TEXT:C222($names_at; 0)
ARRAY LONGINT:C221($types_ai; 0)
ARRAY LONGINT:C221($itemSizes_ai; 0)
ARRAY LONGINT:C221($dataSizes_ai; 0)
ARRAY LONGINT:C221($longArr_ai; 0)
ARRAY LONGINT:C221($longArrOut_ai; 0)

$otrMain_i:=OTr_New
$testDate_d:=!2026-04-06!
$testTime_h:=?10:30:45?
vtCC_Filename:="phase10a"
$wombat_pic:=OTr_z_Wombat
TEXT TO BLOB:C554("phase10a-blob"; $gotBlob_blob)

// ====================================================
// 1. Register / version / compiled / options
// ====================================================
$otrCmd_t:="OTr_Register / OTr_GetVersion / OTr_CompiledApplication / OTr_GetOptions"
$version_t:=OTr_GetVersion
$compiled_i:=OTr_CompiledApplication
$opts_i:=OTr_GetOptions
$otrResult_t:="version="+$version_t+" compiled="+String:C10($compiled_i)+" options="+String:C10($opts_i)
APPEND TO ARRAY:C911($testName_at; "Register / version / compiled / options")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
// 2. Scalar put/get group
// ====================================================
OTr_PutString($otrMain_i; "str"; "hello")
OTr_PutLong($otrMain_i; "num"; 42)
OTr_PutReal($otrMain_i; "real"; 3.5)
OTr_PutBoolean($otrMain_i; "bool"; True:C214)
OTr_PutDate($otrMain_i; "date"; $testDate_d)
OTr_PutTime($otrMain_i; "time"; $testTime_h)
$gotLong_i:=OTr_GetLong($otrMain_i; "num")
$gotReal_r:=OTr_GetReal($otrMain_i; "real")
$gotBool_i:=OTr_GetBoolean($otrMain_i; "bool")
$otrCmd_t:="OTr Put/Get String Long Real Boolean Date Time"
$otrResult_t:=OTr_GetString($otrMain_i; "str")+" / "+String:C10($gotLong_i)+" / "+String:C10($gotReal_r)+" / "+String:C10($gotBool_i)
APPEND TO ARRAY:C911($testName_at; "Scalar put/get")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
// 3. Pointer / BLOB / Picture
// ====================================================
OTr_PutPointer($otrMain_i; "ptr"; ->vtCC_Filename)
OTr_PutBLOB($otrMain_i; "blob"; $gotBlob_blob)
OTr_PutPicture($otrMain_i; "pic"; $wombat_pic)
$ptrOut_ptr:=Null:C1517
OTr_GetPointer($otrMain_i; "ptr"; ->$ptrOut_ptr)
$roundBlob_blob:=OTr_GetNewBLOB($otrMain_i; "blob")
$gotPic_pic:=OTr_GetPicture($otrMain_i; "pic")
$otrCmd_t:="OTr Put/GetPointer GetNewBLOB Put/GetPicture"
$otrResult_t:="ptrOK="+String:C10(OK)+" blobSize="+String:C10(BLOB size:C605($roundBlob_blob))+" pic="+Choose:C955($gotPic_pic#Null:C1517; "yes"; "no")
APPEND TO ARRAY:C911($testName_at; "Pointer / BLOB / Picture")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
// 4. Object copy and embedded object
// ====================================================
$testOtrH_i:=OTr_New
OTr_PutString($testOtrH_i; "childName"; "kid")
OTr_PutObject($otrMain_i; "child"; $testOtrH_i)
$h2_i:=OTr_GetObject($otrMain_i; "child")
$otrCmd_t:="OTr PutObject / OTr GetObject"
$otrResult_t:="childHandle="+String:C10($h2_i)+" childName="+OTr_GetString($h2_i; "childName")
APPEND TO ARRAY:C911($testName_at; "Embedded object")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)
If ($testOtrH_i#0)
	OTr_Clear($testOtrH_i)
End if 
If ($h2_i#0)
	OTr_Clear($h2_i)
End if 

// ====================================================
// 5. Variable
// ====================================================
$varLong_i:=1234
OTr_PutVariable($otrMain_i; "varLong"; ->$varLong_i)
$varLong_i:=0
OTr_GetVariable($otrMain_i; "varLong"; ->$varLong_i)
$otrCmd_t:="OTr PutVariable / OTr GetVariable"
$otrResult_t:="varLong="+String:C10($varLong_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "Variable round-trip")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
// 6. Bulk array + element operations
// ====================================================
ARRAY LONGINT:C221($longArr_ai; 3)
$longArr_ai{1}:=10
$longArr_ai{2}:=20
$longArr_ai{3}:=30
OTr_PutArray($otrMain_i; "arr"; ->$longArr_ai)
OTr_PutArrayLong($otrMain_i; "arr"; 2; 99)
OTr_InsertElement($otrMain_i; "arr"; 2)
OTr_PutArrayLong($otrMain_i; "arr"; 2; 77)
OTr_DeleteElement($otrMain_i; "arr"; 4)
$arraySize_i:=OTr_SizeOfArray($otrMain_i; "arr")
$gotLong_i:=OTr_GetArrayLong($otrMain_i; "arr"; 2)
$otrCmd_t:="OTr PutArray / PutArrayLong / InsertElement / DeleteElement / SizeOfArray / GetArrayLong"
$otrResult_t:="size="+String:C10($arraySize_i)+" elem2="+String:C10($gotLong_i)
APPEND TO ARRAY:C911($testName_at; "Array bulk + element ops")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
// 7. GetArray / ResizeArray / FindInArray
// ====================================================
OTr_ResizeArray($otrMain_i; "arr"; 5)
OTr_PutArrayLong($otrMain_i; "arr"; 5; 555)
ARRAY LONGINT:C221($longArrOut_ai; 0)
OTr_GetArray($otrMain_i; "arr"; ->$longArrOut_ai)
$find_i:=OTr_FindInArray($otrMain_i; "arr"; String:C10(555))
$otrCmd_t:="OTr ResizeArray / GetArray / FindInArray"
$otrResult_t:="size="+String:C10(Size of array:C274($longArrOut_ai))+" find555="+String:C10($find_i)
APPEND TO ARRAY:C911($testName_at; "Resize / GetArray / FindInArray")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
// 8. Object and item info
// ====================================================
$itemCount_i:=OTr_ItemCount($otrMain_i)
$itemType_i:=OTr_ItemType($otrMain_i; "str")
$otrCmd_t:="OTr IsObject / ItemCount / ItemType / ObjectSize"
$otrResult_t:="isObject="+String:C10(OTr_IsObject($otrMain_i))+" itemCount="+String:C10($itemCount_i)+" itemType(str)="+String:C10($itemType_i)+" size="+String:C10(OTr_ObjectSize($otrMain_i))
APPEND TO ARRAY:C911($testName_at; "Object / item info")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
// 9. Property queries
// ====================================================
ARRAY TEXT:C222($names_at; 0)
ARRAY LONGINT:C221($types_ai; 0)
ARRAY LONGINT:C221($itemSizes_ai; 0)
ARRAY LONGINT:C221($dataSizes_ai; 0)
OTr_GetAllProperties($otrMain_i; ->$names_at; ->$types_ai; ->$itemSizes_ai; ->$dataSizes_ai)
$otrCmd_t:="OTr GetAllProperties / ItemExists / IsEmbedded"
$otrResult_t:="allProps="+String:C10(Size of array:C274($names_at))+" exists(str)="+String:C10(OTr_ItemExists($otrMain_i; "str"))+" embedded(child)="+String:C10(OTr_IsEmbedded($otrMain_i; "child"))
APPEND TO ARRAY:C911($testName_at; "Property queries")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
// 10. Item utility routines
// ====================================================
OTr_CopyItem($otrMain_i; "str"; $otrMain_i; "strCopy")
$compare_i:=OTr_CompareItems($otrMain_i; "str"; $otrMain_i; "strCopy")
OTr_RenameItem($otrMain_i; "strCopy"; "strRenamed")
OTr_DeleteItem($otrMain_i; "strRenamed")
$otrCmd_t:="OTr CopyItem / CompareItems / RenameItem / DeleteItem"
$otrResult_t:="compare="+String:C10($compare_i)+" existsAfterDelete="+String:C10(OTr_ItemExists($otrMain_i; "strRenamed"))
APPEND TO ARRAY:C911($testName_at; "Item utility routines")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
// 11. Serialisation
// ====================================================
$gotBlob_blob:=OTr_ObjectToNewBLOB($otrMain_i)
$testOtrH_i:=OTr_BLOBToObject($gotBlob_blob)
$otrCmd_t:="OTr ObjectToNewBLOB / BLOBToObject"
$otrResult_t:="blobSize="+String:C10(BLOB size:C605($gotBlob_blob))+" newHandle="+String:C10($testOtrH_i)+" getStr="+OTr_GetString($testOtrH_i; "str")
APPEND TO ARRAY:C911($testName_at; "Object serialisation")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)
If ($testOtrH_i#0)
	OTr_Clear($testOtrH_i)
End if 

// ====================================================
// 12. Handle list
// ====================================================
ARRAY LONGINT:C221($longArrOut_ai; 0)
OTr_GetHandleList(->$longArrOut_ai)
$otrCmd_t:="OTr_GetHandleList"
$otrResult_t:="handles="+String:C10(Size of array:C274($longArrOut_ai))
APPEND TO ARRAY:C911($testName_at; "Handle list")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

OTr_Clear($otrMain_i)

$count_i:=Size of array:C274($testName_at)
OTr_PutArray($accum_i; "testName"; ->$testName_at)
OTr_PutArray($accum_i; "otrCmd"; ->$otrCmd_at)
OTr_PutArray($accum_i; "otrResult"; ->$otrResult_at)
ARRAY TEXT:C222($emptyArr_at; $count_i)
OTr_PutArray($accum_i; "otCmd"; ->$emptyArr_at)
OTr_PutArray($accum_i; "otResult"; ->$emptyArr_at)
