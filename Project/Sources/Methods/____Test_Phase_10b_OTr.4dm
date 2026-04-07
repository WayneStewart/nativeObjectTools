//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10b_OTr ($accum_i)

// Executes the OTr half of the Phase 10b misuse suite.
// Scenarios are valid 4D calls with logical mistakes to
// generate representative error-condition log entries.
//
// Tags written to the accumulator:
//   testName
//   otrCmd
//   otrResult
//
// Also initialises otCmd and otResult arrays (empty,
// same length) so ____Test_Phase_10b_OT can update by index.
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-07
// Refactored from ____Test_Phase_10b by Wayne Stewart.
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($accum_i : Integer)

var $otrMain_i : Integer
var $gotLong_i : Integer
var $size_i : Integer
var $compare_i : Integer
var $badBlob_blob : Blob
var $ptrOut_ptr : Pointer
var $varText_t : Text
var $otrCmd_t : Text
var $otrResult_t : Text
var $count_i : Integer

ARRAY TEXT($testName_at; 0)
ARRAY TEXT($otrCmd_at; 0)
ARRAY TEXT($otrResult_at; 0)
ARRAY TEXT($emptyArr_at; 0)

$otrMain_i:=OTr_New
OTr_PutLong($otrMain_i; "scalar"; 123)
OTr_PutString($otrMain_i; "textItem"; "abc")

$otrCmd_t:="OTr_GetLong(99999; \"missing\")"
$gotLong_i:=OTr_GetLong(99999; "missing")
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
APPEND TO ARRAY($testName_at; "Invalid handle")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_GetLong($otrMain_i; \"missing\")"
$gotLong_i:=OTr_GetLong($otrMain_i; "missing")
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
APPEND TO ARRAY($testName_at; "Missing tag")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_PutArrayLong($otrMain_i; \"scalar\"; 1; 777)"
OTr_PutArrayLong($otrMain_i; "scalar"; 1; 777)
$otrResult_t:="OK="+String(OK)
APPEND TO ARRAY($testName_at; "Array write against scalar")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_GetArrayLong($otrMain_i; \"scalar\"; 99)"
$gotLong_i:=OTr_GetArrayLong($otrMain_i; "scalar"; 99)
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
APPEND TO ARRAY($testName_at; "Out-of-range array access")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_SizeOfArray($otrMain_i; \"missingArray\")"
$size_i:=OTr_SizeOfArray($otrMain_i; "missingArray")
$otrResult_t:="returned "+String($size_i)+" OK="+String(OK)
APPEND TO ARRAY($testName_at; "SizeOfArray on missing tag")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_CompareItems($otrMain_i; \"scalar\"; $otrMain_i; \"textItem\")"
$compare_i:=OTr_CompareItems($otrMain_i; "scalar"; $otrMain_i; "textItem")
$otrResult_t:="returned "+String($compare_i)+" OK="+String(OK)
APPEND TO ARRAY($testName_at; "CompareItems type mismatch")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_PutLong($otrMain_i; \"scalar.child\"; 9)"
OTr_PutLong($otrMain_i; "scalar.child"; 9)
$otrResult_t:="OK="+String(OK)
APPEND TO ARRAY($testName_at; "Invalid dotted path through scalar")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_DeleteItem($otrMain_i; \"missingDelete\")"
OTr_DeleteItem($otrMain_i; "missingDelete")
$otrResult_t:="OK="+String(OK)
APPEND TO ARRAY($testName_at; "Delete missing tag")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_GetPointer($otrMain_i; \"missingPtr\"; ->$ptrOut_ptr)"
$ptrOut_ptr:=Null
OTr_GetPointer($otrMain_i; "missingPtr"; ->$ptrOut_ptr)
$otrResult_t:="OK="+String(OK)
APPEND TO ARRAY($testName_at; "Pointer getter on missing tag")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_BLOBToObject($badBlob_blob)"
TEXT TO BLOB("this is not a serialised object"; $badBlob_blob)
$gotLong_i:=OTr_BLOBToObject($badBlob_blob)
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)
APPEND TO ARRAY($testName_at; "Invalid BLOB deserialisation")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr PutVariable long / OTr GetVariable into text"
$gotLong_i:=123
OTr_PutVariable($otrMain_i; "varMixed"; ->$gotLong_i)
$varText_t:=""
OTr_GetVariable($otrMain_i; "varMixed"; ->$varText_t)
$otrResult_t:="text="+$varText_t+" OK="+String(OK)
APPEND TO ARRAY($testName_at; "Variable type mismatch")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

$otrCmd_t:="OTr_ItemCount(99999)"
$size_i:=OTr_ItemCount(99999)
$otrResult_t:="returned "+String($size_i)+" OK="+String(OK)
APPEND TO ARRAY($testName_at; "Invalid handle on object utility")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

OTr_Clear($otrMain_i)

$count_i:=Size of array($testName_at)
OTr_PutArray($accum_i; "testName"; ->$testName_at)
OTr_PutArray($accum_i; "otrCmd"; ->$otrCmd_at)
OTr_PutArray($accum_i; "otrResult"; ->$otrResult_at)
ARRAY TEXT($emptyArr_at; $count_i)
OTr_PutArray($accum_i; "otCmd"; ->$emptyArr_at)
OTr_PutArray($accum_i; "otResult"; ->$emptyArr_at)
