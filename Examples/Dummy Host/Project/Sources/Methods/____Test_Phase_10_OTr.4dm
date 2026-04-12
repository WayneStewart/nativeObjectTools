//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10_OTr ($accum_i)

// Executes the OTr half of the Phase 10 logging-focused
// side-by-side test. For each of the 9 error-condition
// scenarios, runs the OTr command and accumulates the
// results into local arrays, then bulk-loads them into
// the shared accumulator handle.
//
// Scenarios are intentionally logically wrong to trigger
// OTr error paths and produce representative log entries.
//
// Tags written to the accumulator:
//   testName  -- human-readable scenario label
//   otrCmd    -- OTr command description
//   otrResult -- "returned X OK=Y" or "OK=Y"
//
// Also initialises otCmd and otResult arrays (empty,
// same length) so ____Test_Phase_10_OT can update them
// by index.
//
// Must NOT call OTr_ClearAll -- the accumulator handle
// is owned by the controller (____Test_Phase_10).
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-07
// Refactored from ____Test_Phase_10 by Wayne Stewart.
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($accum_i : Integer)

var $otrMain_i : Integer
var $gotLong_i : Integer
var $size_i : Integer
var $compare_i : Integer
var $gotPtr_ptr : Pointer
var $reg_i : Integer
var $otrCmd_t : Text
var $otrResult_t : Text
var $count_i : Integer
// ==== BEGIN OTr BLOCK — comment out when renamed to OT  ====

ARRAY TEXT($testName_at; 0)
ARRAY TEXT($otrCmd_at; 0)
ARRAY TEXT($otrResult_at; 0)
ARRAY TEXT($emptyArr_at; 0)

// ----------------------------------------------------
// Initialise OTr main handle
// (does NOT call ClearAll -- accumulator must survive)
// ----------------------------------------------------
$otrMain_i:=OTr_New

// Seed known scalar values so later misuse is deliberate.
OTr_PutLong($otrMain_i; "scalar"; 123)
OTr_PutString($otrMain_i; "textItem"; "abc")

// ====================================================
//MARK:- 1. Invalid handle on getter
// ====================================================
$otrCmd_t:="OTr_GetLong(99999; \"missing\")"
$otrResult_t:="Fail: not run"

$gotLong_i:=OTr_GetLong(99999; "missing")
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)

APPEND TO ARRAY($testName_at; "Invalid handle on getter")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 2. Missing tag on getter
// ====================================================
$otrCmd_t:="OTr_GetLong($otrMain_i; \"doesNotExist\")"
$otrResult_t:="Fail: not run"

$gotLong_i:=OTr_GetLong($otrMain_i; "doesNotExist")
$otrResult_t:="returned "+String($gotLong_i)+" OK="+String(OK)

APPEND TO ARRAY($testName_at; "Missing tag on getter")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 3. Array write against scalar
// ====================================================
$otrCmd_t:="OTr_PutArrayLong($otrMain_i; \"scalar\"; 1; 777)"
$otrResult_t:="Fail: not run"

OTr_PutArrayLong($otrMain_i; "scalar"; 1; 777)
$otrResult_t:="OK="+String(OK)

APPEND TO ARRAY($testName_at; "Array write against scalar")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 4. SizeOfArray on missing tag
// ====================================================
$otrCmd_t:="OTr_SizeOfArray($otrMain_i; \"missingArray\")"
$otrResult_t:="Fail: not run"

$size_i:=OTr_SizeOfArray($otrMain_i; "missingArray")
$otrResult_t:="returned "+String($size_i)+" OK="+String(OK)

APPEND TO ARRAY($testName_at; "SizeOfArray on missing tag")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 5. CompareItems type mismatch
// ====================================================
$otrCmd_t:="OTr_CompareItems($otrMain_i; \"scalar\"; $otrMain_i; \"textItem\")"
$otrResult_t:="Fail: not run"

$compare_i:=OTr_CompareItems($otrMain_i; "scalar"; $otrMain_i; "textItem")
$otrResult_t:="returned "+String($compare_i)+" OK="+String(OK)

APPEND TO ARRAY($testName_at; "CompareItems type mismatch")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 6. Invalid dotted path through scalar
// ====================================================
$otrCmd_t:="OTr_PutLong($otrMain_i; \"scalar.child\"; 9)"
$otrResult_t:="Fail: not run"

OTr_PutLong($otrMain_i; "scalar.child"; 9)
$otrResult_t:="OK="+String(OK)

APPEND TO ARRAY($testName_at; "Invalid dotted path through scalar")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 7. Pointer getter on missing tag
// ====================================================
$otrCmd_t:="OTr_GetPointer($otrMain_i; \"missingPtr\"; ->$gotPtr_ptr)"
$otrResult_t:="Fail: not run"

$gotPtr_ptr:=Null
OTr_GetPointer($otrMain_i; "missingPtr"; ->$gotPtr_ptr)
$otrResult_t:="OK="+String(OK)

APPEND TO ARRAY($testName_at; "Pointer getter on missing tag")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 8. Delete missing tag
// ====================================================
$otrCmd_t:="OTr_DeleteItem($otrMain_i; \"missingDelete\")"
$otrResult_t:="Fail: not run"

OTr_DeleteItem($otrMain_i; "missingDelete")
$otrResult_t:="OK="+String(OK)

APPEND TO ARRAY($testName_at; "Delete missing tag")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 9. Register call
// ====================================================
$otrCmd_t:="OTr_Register(\"20C9-EMQv-BJBl-D20M\")"
$otrResult_t:="Fail: not run"

$reg_i:=OTr_Register("20C9-EMQv-BJBl-D20M")
$otrResult_t:="returned "+String($reg_i)+" OK="+String(OK)

APPEND TO ARRAY($testName_at; "Register call")
APPEND TO ARRAY($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- TEARDOWN and BULK LOAD INTO ACCUMULATOR
// ====================================================
OTr_Clear($otrMain_i)

$count_i:=Size of array($testName_at)

// Load OTr result columns into accumulator
OTr_PutArray($accum_i; "testName"; ->$testName_at)
OTr_PutArray($accum_i; "otrCmd"; ->$otrCmd_at)
OTr_PutArray($accum_i; "otrResult"; ->$otrResult_at)

// Initialise OT columns to the same length with empty strings
// so ____Test_Phase_10_OT can update them by index.
ARRAY TEXT($emptyArr_at; $count_i)
OTr_PutArray($accum_i; "otCmd"; ->$emptyArr_at)
OTr_PutArray($accum_i; "otResult"; ->$emptyArr_at)
// ==== END OTr BLOCK ====
