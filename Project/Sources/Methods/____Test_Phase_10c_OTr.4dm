//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10c_OTr ($accum_i)
//
// Executes the OTr half of the Phase 10c comprehensive
// OK=0 test suite. Covers every command documented in the
// legacy ObjectTools 5 Reference as setting OK to zero on
// an error condition (146 references across 54 commands).
//
// Each scenario exercises one of the three canonical
// error classes for each command:
//   A) Invalid handle
//   B) Missing tag (item not found)
//   C) Type mismatch  (or index out of range for array cmds)
//
// Result format: "returned X OK=Y" or "OK=Y" for void cmds.
// All results should show OK=0.
//
// Tags written to the accumulator:
//   testName
//   otrCmd
//   otrResult
//
// Also initialises otCmd and otResult arrays (empty,
// same length) so ____Test_Phase_10c_OT can update by index.
//
// Must NOT call OTr_ClearAll -- the accumulator handle
// is owned by the controller (____Test_Phase_10c).
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-10
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($accum_i : Integer)

var $h_i : Integer          // working handle with seeded data
var $r_i : Integer          // return value (longint)
var $r_r : Real             // return value (real)
var $r_b : Integer          // return value (boolean)
var $r_d : Date             // return value (date)
var $r_h : Time             // return value (time)
var $r_t : Text             // return value (text)
var $r_blob : Blob          // return value (blob)
var $r_ptr : Pointer        // return value (pointer)
var $r_pic : Picture        // return value (picture)
var $badBlob_blob : Blob    // deliberately invalid BLOB for deserialisation
var $ioBLOB_blob : Blob     // target blob for OTr_ObjectToBLOB
// $longArr_ai, $textArr_at, $outArr_ai, $outNames_at, $outTypes_ai,
// $outSizes_ai, $outData_ai are process arrays declared with ARRAY commands below.
var $outType_i : Integer    // output type scalar (OTr_GetNamedProperties)
var $outItemSize_i : Integer
var $outDataSize_i : Integer
var $outIndex_i : Integer
var $outName_t : Text
var $otrCmd_t : Text
var $otrResult_t : Text
var $count_i : Integer
// ==== BEGIN OTr BLOCK — comment out when renamed to OT ====

ARRAY TEXT:C222($testName_at; 0)
ARRAY TEXT:C222($otrCmd_at; 0)
ARRAY TEXT:C222($otrResult_at; 0)
ARRAY TEXT:C222($emptyArr_at; 0)

// ----------------------------------------------------
// Seed a valid handle with representative data so that
// type-mismatch tests can target a known scalar while
// array commands can target a known array.
//   "scalar"   : Long = 123
//   "textItem" : Text = "abc"
//   "longArr"  : Array Long [10, 20, 30]
//   "textArr"  : Array Text ["x", "y"]
// ----------------------------------------------------
$h_i:=OTr_New

OTr_PutLong($h_i; "scalar"; 123)
OTr_PutString($h_i; "textItem"; "abc")

ARRAY LONGINT:C221($longArr_ai; 3)
$longArr_ai{1}:=10
$longArr_ai{2}:=20
$longArr_ai{3}:=30
OTr_PutArray($h_i; "longArr"; ->$longArr_ai)

ARRAY TEXT:C222($textArr_at; 2)
$textArr_at{1}:="x"
$textArr_at{2}:="y"
OTr_PutArray($h_i; "textArr"; ->$textArr_at)

// ====================================================
//MARK:- OT Copy
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_Copy(99999)"
$r_i:=OTr_Copy(99999)
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT Copy — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArray
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArray(99999; \"arr\"; ->$longArr_ai)"
OTr_PutArray(99999; "arr"; ->$longArr_ai)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArray — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (tag exists as scalar, not array)
$otrCmd_t:="OTr_PutArray($h_i; \"scalar\"; ->$longArr_ai)"
OTr_PutArray($h_i; "scalar"; ->$longArr_ai)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArray — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayBLOB
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayBLOB(99999; \"longArr\"; 1; $r_blob)"
OTr_PutArrayBLOB(99999; "longArr"; 1; $r_blob)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayBLOB — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Index out of range
$otrCmd_t:="OTr_PutArrayBLOB($h_i; \"longArr\"; 99; $r_blob)"
OTr_PutArrayBLOB($h_i; "longArr"; 99; $r_blob)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayBLOB — index out of range")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayBoolean
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayBoolean(99999; \"longArr\"; 1; True)"
OTr_PutArrayBoolean(99999; "longArr"; 1; True:C214)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayBoolean — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (longArr is Long array, not Boolean array)
$otrCmd_t:="OTr_PutArrayBoolean($h_i; \"longArr\"; 1; True)"
OTr_PutArrayBoolean($h_i; "longArr"; 1; True:C214)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayBoolean — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayDate
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayDate(99999; \"longArr\"; 1; !2026-01-01!)"
OTr_PutArrayDate(99999; "longArr"; 1; !2026-01-01!)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayDate — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutArrayDate($h_i; \"longArr\"; 1; !2026-01-01!)"
OTr_PutArrayDate($h_i; "longArr"; 1; !2026-01-01!)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayDate — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayLong
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayLong(99999; \"longArr\"; 1; 777)"
OTr_PutArrayLong(99999; "longArr"; 1; 777)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayLong — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (textArr is Text array, not Long)
$otrCmd_t:="OTr_PutArrayLong($h_i; \"textArr\"; 1; 777)"
OTr_PutArrayLong($h_i; "textArr"; 1; 777)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayLong — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayPicture
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayPicture(99999; \"longArr\"; 1; <picture>)"
OTr_PutArrayPicture(99999; "longArr"; 1; $r_pic)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayPicture — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutArrayPicture($h_i; \"longArr\"; 1; <picture>)"
OTr_PutArrayPicture($h_i; "longArr"; 1; $r_pic)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayPicture — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayPointer
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayPointer(99999; \"longArr\"; 1; ->$r_i)"
OTr_PutArrayPointer(99999; "longArr"; 1; ->$r_i)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayPointer — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutArrayPointer($h_i; \"longArr\"; 1; ->$r_i)"
OTr_PutArrayPointer($h_i; "longArr"; 1; ->$r_i)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayPointer — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayReal
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayReal(99999; \"longArr\"; 1; 3.14)"
OTr_PutArrayReal(99999; "longArr"; 1; 3.14)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayReal — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (textArr is Text, not Real)
$otrCmd_t:="OTr_PutArrayReal($h_i; \"textArr\"; 1; 3.14)"
OTr_PutArrayReal($h_i; "textArr"; 1; 3.14)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayReal — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayString
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayString(99999; \"textArr\"; 1; \"z\")"
OTr_PutArrayString(99999; "textArr"; 1; "z")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayString — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (longArr is Long, not String)
$otrCmd_t:="OTr_PutArrayString($h_i; \"longArr\"; 1; \"z\")"
OTr_PutArrayString($h_i; "longArr"; 1; "z")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayString — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayText
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayText(99999; \"textArr\"; 1; \"z\")"
OTr_PutArrayText(99999; "textArr"; 1; "z")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayText — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutArrayText($h_i; \"longArr\"; 1; \"z\")"
OTr_PutArrayText($h_i; "longArr"; 1; "z")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayText — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutArrayTime
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutArrayTime(99999; \"longArr\"; 1; ?10:00:00?)"
OTr_PutArrayTime(99999; "longArr"; 1; ?10:00:00?)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayTime — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutArrayTime($h_i; \"textArr\"; 1; ?10:00:00?)"
OTr_PutArrayTime($h_i; "textArr"; 1; ?10:00:00?)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutArrayTime — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutBLOB
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutBLOB(99999; \"tag\"; $r_blob)"
OTr_PutBLOB(99999; "tag"; $r_blob)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutBLOB — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (scalar is Long, not BLOB)
$otrCmd_t:="OTr_PutBLOB($h_i; \"scalar\"; $r_blob)"
OTr_PutBLOB($h_i; "scalar"; $r_blob)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutBLOB — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutBoolean
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutBoolean(99999; \"tag\"; True)"
OTr_PutBoolean(99999; "tag"; True:C214)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutBoolean — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutBoolean($h_i; \"scalar\"; True)"
OTr_PutBoolean($h_i; "scalar"; True:C214)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutBoolean — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutDate
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutDate(99999; \"tag\"; !2026-01-01!)"
OTr_PutDate(99999; "tag"; !2026-01-01!)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutDate — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutDate($h_i; \"scalar\"; !2026-01-01!)"
OTr_PutDate($h_i; "scalar"; !2026-01-01!)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutDate — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutLong
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutLong(99999; \"tag\"; 42)"
OTr_PutLong(99999; "tag"; 42)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutLong — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (textItem is Text, not Long)
$otrCmd_t:="OTr_PutLong($h_i; \"textItem\"; 42)"
OTr_PutLong($h_i; "textItem"; 42)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutLong — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutPointer
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutPointer(99999; \"tag\"; ->$r_i)"
OTr_PutPointer(99999; "tag"; ->$r_i)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutPointer — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutPointer($h_i; \"scalar\"; ->$r_i)"
OTr_PutPointer($h_i; "scalar"; ->$r_i)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutPointer — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutReal
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutReal(99999; \"tag\"; 3.14)"
OTr_PutReal(99999; "tag"; 3.14)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutReal — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutReal($h_i; \"textItem\"; 3.14)"
OTr_PutReal($h_i; "textItem"; 3.14)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutReal — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutString
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutString(99999; \"tag\"; \"val\")"
OTr_PutString(99999; "tag"; "val")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutString — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutString($h_i; \"scalar\"; \"val\")"
OTr_PutString($h_i; "scalar"; "val")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutString — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutText
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutText(99999; \"tag\"; \"val\")"
OTr_PutText(99999; "tag"; "val")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutText — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutText($h_i; \"scalar\"; \"val\")"
OTr_PutText($h_i; "scalar"; "val")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutText — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutTime
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_PutTime(99999; \"tag\"; ?10:00:00?)"
OTr_PutTime(99999; "tag"; ?10:00:00?)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutTime — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_PutTime($h_i; \"scalar\"; ?10:00:00?)"
OTr_PutTime($h_i; "scalar"; ?10:00:00?)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutTime — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT PutVariable
// ====================================================

// A) Invalid handle
var $varLong_i : Integer
$varLong_i:=42
$otrCmd_t:="OTr_PutVariable(99999; \"tag\"; ->$varLong_i)"
OTr_PutVariable(99999; "tag"; ->$varLong_i)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutVariable — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch on GetVariable (store long, retrieve as text)
var $varText_t : Text
$varLong_i:=123
OTr_PutVariable($h_i; "varMixed"; ->$varLong_i)
$varText_t:=""
$otrCmd_t:="OTr_GetVariable($h_i; \"varMixed\"; ->$varText_t) [stored as Long]"
OTr_GetVariable($h_i; "varMixed"; ->$varText_t)
$otrResult_t:="text=\""+$varText_t+"\" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetVariable — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArray
// ====================================================

// A) Invalid handle
ARRAY LONGINT:C221($outArr_ai; 0)
$otrCmd_t:="OTr_GetArray(99999; \"longArr\"; ->$outArr_ai)"
OTr_GetArray(99999; "longArr"; ->$outArr_ai)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArray — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (scalar is not an array)
ARRAY LONGINT:C221($outArr_ai; 0)
$otrCmd_t:="OTr_GetArray($h_i; \"scalar\"; ->$outArr_ai)"
OTr_GetArray($h_i; "scalar"; ->$outArr_ai)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArray — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayBLOB
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetArrayBLOB(99999; \"longArr\"; 1)"
$r_blob:=OTr_GetArrayBLOB(99999; "longArr"; 1)
$otrResult_t:="blobSize="+String:C10(BLOB size:C605($r_blob))+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayBLOB — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetArrayBLOB($h_i; \"textArr\"; 1)"
$r_blob:=OTr_GetArrayBLOB($h_i; "textArr"; 1)
$otrResult_t:="blobSize="+String:C10(BLOB size:C605($r_blob))+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayBLOB — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayBoolean
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetArrayBoolean(99999; \"longArr\"; 1)"
$r_i:=OTr_GetArrayBoolean(99999; "longArr"; 1)
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayBoolean — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch + index out of range
$otrCmd_t:="OTr_GetArrayBoolean($h_i; \"longArr\"; 99)"
$r_i:=OTr_GetArrayBoolean($h_i; "longArr"; 99)
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayBoolean — index out of range")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayDate
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetArrayDate(99999; \"longArr\"; 1)"
$r_d:=OTr_GetArrayDate(99999; "longArr"; 1)
$otrResult_t:="returned "+String:C10($r_d)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayDate — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetArrayDate($h_i; \"longArr\"; 1)"
$r_d:=OTr_GetArrayDate($h_i; "longArr"; 1)
$otrResult_t:="returned "+String:C10($r_d)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayDate — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayLong
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetArrayLong(99999; \"longArr\"; 1)"
$r_i:=OTr_GetArrayLong(99999; "longArr"; 1)
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayLong — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Index out of range
$otrCmd_t:="OTr_GetArrayLong($h_i; \"longArr\"; 99)"
$r_i:=OTr_GetArrayLong($h_i; "longArr"; 99)
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayLong — index out of range")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayPicture
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetArrayPicture(99999; \"longArr\"; 1)"
$r_pic:=OTr_GetArrayPicture(99999; "longArr"; 1)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayPicture — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetArrayPicture($h_i; \"longArr\"; 1)"
$r_pic:=OTr_GetArrayPicture($h_i; "longArr"; 1)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayPicture — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayPointer
// ====================================================

// A) Invalid handle
$r_ptr:=Null:C1517
$otrCmd_t:="OTr_GetArrayPointer(99999; \"longArr\"; 1)"
$r_ptr:=OTr_GetArrayPointer(99999; "longArr"; 1)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayPointer — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$r_ptr:=Null:C1517
$otrCmd_t:="OTr_GetArrayPointer($h_i; \"longArr\"; 1)"
$r_ptr:=OTr_GetArrayPointer($h_i; "longArr"; 1)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayPointer — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayReal
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetArrayReal(99999; \"longArr\"; 1)"
$r_r:=OTr_GetArrayReal(99999; "longArr"; 1)
$otrResult_t:="returned "+String:C10($r_r)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayReal — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (textArr is Text)
$otrCmd_t:="OTr_GetArrayReal($h_i; \"textArr\"; 1)"
$r_r:=OTr_GetArrayReal($h_i; "textArr"; 1)
$otrResult_t:="returned "+String:C10($r_r)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayReal — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayString
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetArrayString(99999; \"textArr\"; 1)"
$r_t:=OTr_GetArrayString(99999; "textArr"; 1)
$otrResult_t:="returned \""+$r_t+"\" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayString — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetArrayString($h_i; \"longArr\"; 1)"
$r_t:=OTr_GetArrayString($h_i; "longArr"; 1)
$otrResult_t:="returned \""+$r_t+"\" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayString — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayText
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetArrayText(99999; \"textArr\"; 1)"
$r_t:=OTr_GetArrayText(99999; "textArr"; 1)
$otrResult_t:="returned \""+$r_t+"\" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayText — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (longArr is Long, not Text)
$otrCmd_t:="OTr_GetArrayText($h_i; \"longArr\"; 1)"
$r_t:=OTr_GetArrayText($h_i; "longArr"; 1)
$otrResult_t:="returned \""+$r_t+"\" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayText — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetArrayTime
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetArrayTime(99999; \"longArr\"; 1)"
$r_h:=OTr_GetArrayTime(99999; "longArr"; 1)
$otrResult_t:="returned "+String:C10($r_h)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayTime — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetArrayTime($h_i; \"longArr\"; 1)"
$r_h:=OTr_GetArrayTime($h_i; "longArr"; 1)
$otrResult_t:="returned "+String:C10($r_h)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetArrayTime — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetBLOB
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetBLOB(99999; \"scalar\"; ->$r_blob)"
OTr_GetBLOB(99999; "scalar"; ->$r_blob)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetBLOB — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (scalar is Long, not BLOB)
$otrCmd_t:="OTr_GetBLOB($h_i; \"scalar\"; ->$r_blob)"
OTr_GetBLOB($h_i; "scalar"; ->$r_blob)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetBLOB — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetBoolean
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetBoolean(99999; \"scalar\")"
$r_i:=OTr_GetBoolean(99999; "scalar")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetBoolean — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetBoolean($h_i; \"textItem\")"
$r_i:=OTr_GetBoolean($h_i; "textItem")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetBoolean — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetDate
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetDate(99999; \"scalar\")"
$r_d:=OTr_GetDate(99999; "scalar")
$otrResult_t:="returned "+String:C10($r_d)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetDate — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (scalar is Long, not Date)
$otrCmd_t:="OTr_GetDate($h_i; \"scalar\")"
$r_d:=OTr_GetDate($h_i; "scalar")
$otrResult_t:="returned "+String:C10($r_d)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetDate — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetLong
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetLong(99999; \"scalar\")"
$r_i:=OTr_GetLong(99999; "scalar")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetLong — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// B) Missing tag
$otrCmd_t:="OTr_GetLong($h_i; \"doesNotExist\")"
$r_i:=OTr_GetLong($h_i; "doesNotExist")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetLong — missing tag")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (textItem is Text, not Long)
$otrCmd_t:="OTr_GetLong($h_i; \"textItem\")"
$r_i:=OTr_GetLong($h_i; "textItem")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetLong — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetNewBLOB
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetNewBLOB(99999; \"scalar\")"
$r_blob:=OTr_GetNewBLOB(99999; "scalar")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetNewBLOB — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetNewBLOB($h_i; \"scalar\")"
$r_blob:=OTr_GetNewBLOB($h_i; "scalar")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetNewBLOB — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetObject
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetObject(99999; \"scalar\")"
$r_i:=OTr_GetObject(99999; "scalar")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetObject — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (scalar is Long, not Object)
$otrCmd_t:="OTr_GetObject($h_i; \"scalar\")"
$r_i:=OTr_GetObject($h_i; "scalar")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetObject — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetPicture
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetPicture(99999; \"scalar\")"
$r_pic:=OTr_GetPicture(99999; "scalar")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetPicture — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetPicture($h_i; \"scalar\")"
$r_pic:=OTr_GetPicture($h_i; "scalar")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetPicture — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetPointer
// ====================================================

// A) Invalid handle
$r_ptr:=Null:C1517
$otrCmd_t:="OTr_GetPointer(99999; \"scalar\"; ->$r_ptr)"
OTr_GetPointer(99999; "scalar"; ->$r_ptr)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetPointer — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// B) Missing tag
$r_ptr:=Null:C1517
$otrCmd_t:="OTr_GetPointer($h_i; \"missingPtr\"; ->$r_ptr)"
OTr_GetPointer($h_i; "missingPtr"; ->$r_ptr)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetPointer — missing tag")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$r_ptr:=Null:C1517
$otrCmd_t:="OTr_GetPointer($h_i; \"scalar\"; ->$r_ptr)"
OTr_GetPointer($h_i; "scalar"; ->$r_ptr)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetPointer — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetReal
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetReal(99999; \"scalar\")"
$r_r:=OTr_GetReal(99999; "scalar")
$otrResult_t:="returned "+String:C10($r_r)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetReal — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (textItem is Text, not Real)
$otrCmd_t:="OTr_GetReal($h_i; \"textItem\")"
$r_r:=OTr_GetReal($h_i; "textItem")
$otrResult_t:="returned "+String:C10($r_r)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetReal — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetString
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetString(99999; \"textItem\")"
$r_t:=OTr_GetString(99999; "textItem")
$otrResult_t:="returned \""+$r_t+"\" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetString — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch (scalar is Long, not String)
$otrCmd_t:="OTr_GetString($h_i; \"scalar\")"
$r_t:=OTr_GetString($h_i; "scalar")
$otrResult_t:="returned \""+$r_t+"\" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetString — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetText
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetText(99999; \"textItem\")"
$r_t:=OTr_GetText(99999; "textItem")
$otrResult_t:="returned \""+$r_t+"\" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetText — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetText($h_i; \"scalar\")"
$r_t:=OTr_GetText($h_i; "scalar")
$otrResult_t:="returned \""+$r_t+"\" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetText — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- OT GetTime
// ====================================================

// A) Invalid handle
$otrCmd_t:="OTr_GetTime(99999; \"scalar\")"
$r_h:=OTr_GetTime(99999; "scalar")
$otrResult_t:="returned "+String:C10($r_h)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetTime — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// C) Type mismatch
$otrCmd_t:="OTr_GetTime($h_i; \"scalar\")"
$r_h:=OTr_GetTime($h_i; "scalar")
$otrResult_t:="returned "+String:C10($r_h)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetTime — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- Array element utilities
// ====================================================

// OT DeleteElement — invalid handle
$otrCmd_t:="OTr_DeleteElement(99999; \"longArr\"; 1)"
OTr_DeleteElement(99999; "longArr"; 1)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT DeleteElement — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT DeleteElement — type mismatch (scalar not array)
$otrCmd_t:="OTr_DeleteElement($h_i; \"scalar\"; 1)"
OTr_DeleteElement($h_i; "scalar"; 1)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT DeleteElement — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT FindInArray — invalid handle
$otrCmd_t:="OTr_FindInArray(99999; \"longArr\"; \"10\")"
$r_i:=OTr_FindInArray(99999; "longArr"; "10")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT FindInArray — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT InsertElement — invalid handle
$otrCmd_t:="OTr_InsertElement(99999; \"longArr\"; 1)"
OTr_InsertElement(99999; "longArr"; 1)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT InsertElement — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT ResizeArray — invalid handle
$otrCmd_t:="OTr_ResizeArray(99999; \"longArr\"; 5)"
OTr_ResizeArray(99999; "longArr"; 5)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT ResizeArray — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT SizeOfArray — invalid handle
$otrCmd_t:="OTr_SizeOfArray(99999; \"longArr\")"
$r_i:=OTr_SizeOfArray(99999; "longArr")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT SizeOfArray — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT SizeOfArray — missing tag
$otrCmd_t:="OTr_SizeOfArray($h_i; \"missingArray\")"
$r_i:=OTr_SizeOfArray($h_i; "missingArray")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT SizeOfArray — missing tag")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT SortArrays — invalid handle
$otrCmd_t:="OTr_SortArrays(99999; \"longArr\"; \">\")"
OTr_SortArrays(99999; "longArr"; ">"; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; "")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT SortArrays — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- Object info utilities
// ====================================================

// OT ItemCount — invalid handle
$otrCmd_t:="OTr_ItemCount(99999)"
$r_i:=OTr_ItemCount(99999)
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT ItemCount — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT ObjectSize — invalid handle
$otrCmd_t:="OTr_ObjectSize(99999)"
$r_i:=OTr_ObjectSize(99999)
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT ObjectSize — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT ItemExists — invalid handle
$otrCmd_t:="OTr_ItemExists(99999; \"scalar\")"
$r_i:=OTr_ItemExists(99999; "scalar")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT ItemExists — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT ItemType — invalid handle
$otrCmd_t:="OTr_ItemType(99999; \"scalar\")"
$r_i:=OTr_ItemType(99999; "scalar")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT ItemType — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT IsEmbedded — invalid handle
$otrCmd_t:="OTr_IsEmbedded(99999; \"scalar\")"
$r_i:=OTr_IsEmbedded(99999; "scalar")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT IsEmbedded — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- Property query commands
// ====================================================

ARRAY TEXT:C222($outNames_at; 0)
ARRAY LONGINT:C221($outTypes_ai; 0)
ARRAY LONGINT:C221($outSizes_ai; 0)
ARRAY LONGINT:C221($outData_ai; 0)

// OT GetAllProperties — invalid handle
$otrCmd_t:="OTr_GetAllProperties(99999; ->$outNames_at; ->$outTypes_ai; ->$outSizes_ai; ->$outData_ai)"
OTr_GetAllProperties(99999; ->$outNames_at; ->$outTypes_ai; ->$outSizes_ai; ->$outData_ai)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetAllProperties — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT GetAllNamedProperties — invalid handle
$otrCmd_t:="OTr_GetAllNamedProperties(99999; \"\"; ->$outNames_at; ->$outTypes_ai; ->$outSizes_ai; ->$outData_ai)"
OTr_GetAllNamedProperties(99999; ""; ->$outNames_at; ->$outTypes_ai; ->$outSizes_ai; ->$outData_ai)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetAllNamedProperties — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT GetItemProperties — invalid handle
$otrCmd_t:="OTr_GetItemProperties(99999; 1; ->$outName_t; ->$outType_i; ->$outItemSize_i; ->$outDataSize_i)"
OTr_GetItemProperties(99999; 1; ->$outName_t; ->$outType_i; ->$outItemSize_i; ->$outDataSize_i)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetItemProperties — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT GetNamedProperties — invalid handle
$otrCmd_t:="OTr_GetNamedProperties(99999; \"scalar\"; ->$outType_i; ->$outItemSize_i; ->$outDataSize_i; ->$outIndex_i)"
OTr_GetNamedProperties(99999; "scalar"; ->$outType_i; ->$outItemSize_i; ->$outDataSize_i; ->$outIndex_i)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT GetNamedProperties — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- Item manipulation commands
// ====================================================

// OT CompareItems — invalid handle
$otrCmd_t:="OTr_CompareItems(99999; \"scalar\"; $h_i; \"scalar\")"
$r_i:=OTr_CompareItems(99999; "scalar"; $h_i; "scalar")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT CompareItems — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT CompareItems — type mismatch (Long vs Text)
$otrCmd_t:="OTr_CompareItems($h_i; \"scalar\"; $h_i; \"textItem\")"
$r_i:=OTr_CompareItems($h_i; "scalar"; $h_i; "textItem")
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT CompareItems — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT RenameItem — invalid handle
$otrCmd_t:="OTr_RenameItem(99999; \"scalar\"; \"renamed\")"
OTr_RenameItem(99999; "scalar"; "renamed")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT RenameItem — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT RenameItem — rename conflict (target tag already exists)
$otrCmd_t:="OTr_RenameItem($h_i; \"scalar\"; \"textItem\")"
OTr_RenameItem($h_i; "scalar"; "textItem")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT RenameItem — rename conflict")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT CopyItem — invalid source handle
$otrCmd_t:="OTr_CopyItem(99999; \"scalar\"; $h_i; \"copyDest\")"
OTr_CopyItem(99999; "scalar"; $h_i; "copyDest")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT CopyItem — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT CopyItem — type mismatch (source Long, dest tag exists as Text)
$otrCmd_t:="OTr_CopyItem($h_i; \"scalar\"; $h_i; \"textItem\")"
OTr_CopyItem($h_i; "scalar"; $h_i; "textItem")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT CopyItem — type mismatch")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT DeleteItem — invalid handle
$otrCmd_t:="OTr_DeleteItem(99999; \"scalar\")"
OTr_DeleteItem(99999; "scalar")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT DeleteItem — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT DeleteItem — missing tag
$otrCmd_t:="OTr_DeleteItem($h_i; \"doesNotExist\")"
OTr_DeleteItem($h_i; "doesNotExist")
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT DeleteItem — missing tag")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- Serialisation
// ====================================================

// OT ObjectToBLOB — invalid handle
$otrCmd_t:="OTr_ObjectToBLOB(99999; ->$ioBLOB_blob; 0)"
OTr_ObjectToBLOB(99999; ->$ioBLOB_blob; 0)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT ObjectToBLOB — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT ObjectToNewBLOB — invalid handle
$otrCmd_t:="OTr_ObjectToNewBLOB(99999)"
$r_blob:=OTr_ObjectToNewBLOB(99999)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT ObjectToNewBLOB — invalid handle")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// OT BLOBToObject — invalid BLOB (not a serialised object)
TEXT TO BLOB:C554("this is not a serialised object"; $badBlob_blob)
$otrCmd_t:="OTr_BLOBToObject(<invalid blob>)"
$r_i:=OTr_BLOBToObject($badBlob_blob)
$otrResult_t:="returned "+String:C10($r_i)+" OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT BLOBToObject — invalid BLOB")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- Dotted-path traversal
// ====================================================

// OT PutLong through a dotted path that traverses a scalar (not object)
$otrCmd_t:="OTr_PutLong($h_i; \"scalar.child\"; 9)"
OTr_PutLong($h_i; "scalar.child"; 9)
$otrResult_t:="OK="+String:C10(OK)
APPEND TO ARRAY:C911($testName_at; "OT PutLong — invalid dotted path through scalar")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- TEARDOWN AND BULK LOAD
// ====================================================
OTr_Clear($h_i)

$count_i:=Size of array:C274($testName_at)

OTr_PutArray($accum_i; "testName"; ->$testName_at)
OTr_PutArray($accum_i; "otrCmd"; ->$otrCmd_at)
OTr_PutArray($accum_i; "otrResult"; ->$otrResult_at)

ARRAY TEXT:C222($emptyArr_at; $count_i)
OTr_PutArray($accum_i; "otCmd"; ->$emptyArr_at)
OTr_PutArray($accum_i; "otResult"; ->$emptyArr_at)
// ==== END OTr BLOCK ====
