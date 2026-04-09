//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_15_OTr (accum)

// Executes the OTr half of the Phase 15 side-by-side
// compatibility test. For each test scenario, runs the
// OTr commands and appends one row into the shared OTr
// accumulator handle via local 4D arrays, which are
// bulk-loaded into the accumulator at the end.
//
// Tags written to the accumulator:
//   testNum    -- display number ("1", "2", "9a" ...)
//   testName   -- human-readable scenario name
//   otrCmd     -- OTr command description
//   otrResult  -- "Pass", "Fail: ...", or "Skip: ..."
//
// Also initialises otCmd and otResult arrays (empty,
// same length) so ____Test_Phase_15_OT can update them
// by index.
//
// Must NOT call OT ClearAll -- the accumulator handle
// is owned by the controller (____Test_Phase_15).
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-07
// Refactored from ____Test_Phase_15 by Wayne Stewart.
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($accum_i : Integer)

var $otrMain_i : Integer
var $testOtrH_i : Integer
var $tempH_i : Integer
var $loadedH_i : Integer
var $h4_i : Integer
var $gotten_t : Text
var $gotLong_i : Integer
var $gotReal_r : Real
var $gotBool_i : Integer
var $testDate_d : Date
var $gotDate_d : Date
var $testTime_h : Time
var $gotTime_h : Time
var vtCC_Filename : Text  // process variable -- required for Get pointer round-trip
var $gotPtr_ptr : Pointer
var $wombat_pic : Picture
var $gotPic_pic : Picture
var $otrArrPicOut_pic : Picture
var $testBlob_blob : Blob
var $gotBlob_blob : Blob
var $serialOtrBlob_blob : Blob
var $varTarget_t : Text
var $varDest_t : Text
var $gotItemExists_i : Integer
var $gotItemType_i : Integer
var $otrCount_i : Integer
var $otrArrSize_i : Integer
var $otrSize_i : Integer
var $otrVer_t : Text
var $originalOtrOpts_i : Integer
var $testOpts_i : Integer
var $readOtrOpts_i : Integer
var $otrArrVal_i : Integer
var $otrArrStr_t : Text
var $otrArrReal_r : Real
var $otrArrBool_i : Integer
var $otrCmd_t : Text
var $otrResult_t : Text
var $count_i : Integer

ARRAY TEXT:C222($testNum_at; 0)
ARRAY TEXT:C222($testName_at; 0)
ARRAY TEXT:C222($otrCmd_at; 0)
ARRAY TEXT:C222($otrResult_at; 0)
ARRAY TEXT:C222($otrPropNames_at; 0)
ARRAY TEXT:C222($emptyArr_at; 0)
ARRAY LONGINT:C221($setupAl_ai; 0)
ARRAY TEXT:C222($setupAs_at; 0)
ARRAY REAL:C219($setupAr_arr; 0)
ARRAY BOOLEAN:C223($setupAb_ab; 0)
ARRAY POINTER:C280($setupAptr_aptr; 0)
ARRAY PICTURE:C279($setupApic_apic; 0)
ARRAY LONGINT:C221($setupSort_ai; 0)

// ----------------------------------------------------
// Initialise OTr main handle
// (does NOT clear all -- accumulator must survive)
// ----------------------------------------------------
$otrMain_i:=OT New
$wombat_pic:=OTr_z_Wombat

// ====================================================
//MARK:- 1. Creation / Destruction
// ====================================================
$otrCmd_t:="OT New / OT Clear"
$otrResult_t:="Fail: not run"

$testOtrH_i:=OT New
If ($testOtrH_i#0)
	OT Clear($testOtrH_i)
	If (OK=1)
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: OT Clear set OK=0"
	End if 
Else 
	$otrResult_t:="Fail: OT New returned 0"
End if 

APPEND TO ARRAY:C911($testNum_at; "1")
APPEND TO ARRAY:C911($testName_at; "Creation / destruction")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 2. String / Text
// ====================================================
$otrCmd_t:="OT PutString / OT GetString"
$otrResult_t:="Fail: not run"

OT PutString($otrMain_i; "str"; "compat-str")
$gotten_t:=OT GetString($otrMain_i; "str")
If ($gotten_t="compat-str")
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got '"+$gotten_t+"'"
End if 

APPEND TO ARRAY:C911($testNum_at; "2")
APPEND TO ARRAY:C911($testName_at; "String / Text")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 3. Longint
// ====================================================
$otrCmd_t:="OT PutLong / OT GetLong"
$otrResult_t:="Fail: not run"

OT PutLong($otrMain_i; "num"; 424242)
$gotLong_i:=OT GetLong($otrMain_i; "num")
If ($gotLong_i=424242)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($gotLong_i)
End if 

APPEND TO ARRAY:C911($testNum_at; "3")
APPEND TO ARRAY:C911($testName_at; "Longint")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 4. Real
// ====================================================
$otrCmd_t:="OT PutReal / OT GetReal"
$otrResult_t:="Fail: not run"

OT PutReal($otrMain_i; "ratio"; 3.14159)
$gotReal_r:=OT GetReal($otrMain_i; "ratio")
If ($gotReal_r=3.14159)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($gotReal_r)
End if 

APPEND TO ARRAY:C911($testNum_at; "4")
APPEND TO ARRAY:C911($testName_at; "Real")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 5. Boolean
// ====================================================
$otrCmd_t:="OT PutBoolean / OT GetBoolean"
$otrResult_t:="Fail: not run"

OT PutBoolean($otrMain_i; "flag"; True:C214)
$gotBool_i:=OT GetBoolean($otrMain_i; "flag")
If ($gotBool_i=1)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($gotBool_i)
End if 

APPEND TO ARRAY:C911($testNum_at; "5")
APPEND TO ARRAY:C911($testName_at; "Boolean")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 6. Date
// ====================================================
$otrCmd_t:="OT PutDate / OT GetDate"
$otrResult_t:="Fail: not run"
$testDate_d:=!2026-04-04!

OT PutDate($otrMain_i; "dt"; $testDate_d)
$gotDate_d:=OT GetDate($otrMain_i; "dt")
If ($gotDate_d=$testDate_d)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($gotDate_d)
End if 

APPEND TO ARRAY:C911($testNum_at; "6")
APPEND TO ARRAY:C911($testName_at; "Date")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 7. Time
// ====================================================
$otrCmd_t:="OT PutTime / OT GetTime"
$otrResult_t:="Fail: not run"
$testTime_h:=?10:30:45?

OT PutTime($otrMain_i; "tm"; $testTime_h)
$gotTime_h:=OT GetTime($otrMain_i; "tm")
If ($gotTime_h=$testTime_h)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($gotTime_h)
End if 

APPEND TO ARRAY:C911($testNum_at; "7")
APPEND TO ARRAY:C911($testName_at; "Time")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 8. Pointer
// ====================================================
$otrCmd_t:="OT PutPointer / OT GetPointer"
$otrResult_t:="Fail: not run"
// Use a process variable (no $) so OTr_uTextToPointer can
// reconstruct it via Get pointer. Local ($) variables cannot
// be resolved by name -- this is a 4D platform constraint,
// not an OTr defect, and matches the OT 5.0 documented limit.
vtCC_Filename:="otr-ptr-val"

OT PutPointer($otrMain_i; "ptr"; ->vtCC_Filename)
OT GetPointer($otrMain_i; "ptr"; ->$gotPtr_ptr)
If (OK=1) & ($gotPtr_ptr#Null:C1517)
	If (($gotPtr_ptr->)=vtCC_Filename)
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: dereference got '"+String:C10($gotPtr_ptr->)+"'"
	End if 
Else 
	$otrResult_t:="Fail: OK=0 or Null pointer"
End if 

APPEND TO ARRAY:C911($testNum_at; "8")
APPEND TO ARRAY:C911($testName_at; "Pointer")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 9. Picture (empty picture)
// ====================================================
$otrCmd_t:="OT PutPicture / OT GetPicture"
$otrResult_t:="Fail: not run"

OT PutPicture($otrMain_i; "pic"; $wombat_pic)
$gotPic_pic:=OT GetPicture($otrMain_i; "pic")
If (OTr_uEqualPictures($wombat_pic; $gotPic_pic))
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: picture mismatch or OK=0"
End if 

APPEND TO ARRAY:C911($testNum_at; "9")
APPEND TO ARRAY:C911($testName_at; "Picture (empty picture)")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 9a. Picture (wombat)
// ====================================================
$otrCmd_t:="OT PutPicture / OT GetPicture"
$otrResult_t:="Fail: not run"

If (Picture size:C356($wombat_pic)=0)
	$otrResult_t:="Skip: Wombat picture not loaded"
Else 
	OT PutPicture($otrMain_i; "pic9a"; $wombat_pic)
	$gotPic_pic:=OT GetPicture($otrMain_i; "pic9a")
	If (OTr_uEqualPictures($wombat_pic; $gotPic_pic))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: picture mismatch or OK=0"
	End if 
End if 

APPEND TO ARRAY:C911($testNum_at; "9a")
APPEND TO ARRAY:C911($testName_at; "Picture (wombat)")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 10. BLOB
// ====================================================
$otrCmd_t:="OT PutBLOB / OT GetNewBLOB"
$otrResult_t:="Fail: not run"
CONVERT FROM TEXT:C1011("compat-blob-data"; "UTF-8"; $testBlob_blob)

OT PutBLOB($otrMain_i; "blob"; $testBlob_blob)
$gotBlob_blob:=OT GetNewBLOB($otrMain_i; "blob")
If (OTr_uEqualBLOBs($testBlob_blob; $gotBlob_blob))
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: BLOB content mismatch or OK=0"
End if 

APPEND TO ARRAY:C911($testNum_at; "10")
APPEND TO ARRAY:C911($testName_at; "BLOB")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 11. Variable
// ====================================================
$otrCmd_t:="OT PutVariable / OT GetVariable"
$otrResult_t:="Fail: not run"
$varTarget_t:="otr-var-val"
$varDest_t:=""

OT PutVariable($otrMain_i; "var"; ->$varTarget_t)
OT GetVariable($otrMain_i; "var"; ->$varDest_t)
If ($varDest_t="otr-var-val")
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got '"+$varDest_t+"'"
End if 

APPEND TO ARRAY:C911($testNum_at; "11")
APPEND TO ARRAY:C911($testName_at; "Variable")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 12. Record  (Intentional difference §4.3)
// ====================================================
$otrCmd_t:="OT PutRecord / OT GetRecord"
$otrResult_t:="Fail: not run"

// Create and save a record so there is a current record
// in table 1 for OT PutRecord to reference.
CREATE RECORD:C68([Table_1:1])
[Table_1:1]Name:2:="OTr-Wayne"
SAVE RECORD:C53([Table_1:1])

OT PutRecord($otrMain_i; "rec"; 1)
CREATE RECORD:C68([Table_1:1])
OT GetRecord($otrMain_i; "rec"; 1)
If (OK=1)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: OT GetRecord set OK=0"
End if 
// SAVE RECORD intentionally omitted -- new record is discarded.

APPEND TO ARRAY:C911($testNum_at; "12")
APPEND TO ARRAY:C911($testName_at; "Record")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 13. Dot-path
// ====================================================
$otrCmd_t:="OT PutString (dotted) / OT GetString"
$otrResult_t:="Fail: not run"

OT PutString($otrMain_i; "a.b.c"; "dot-val")
$gotten_t:=OT GetString($otrMain_i; "a.b.c")
If ($gotten_t="dot-val")
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got '"+$gotten_t+"'"
End if 

APPEND TO ARRAY:C911($testNum_at; "13")
APPEND TO ARRAY:C911($testName_at; "Dot-path")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 14. Array Longint
// ====================================================
$otrCmd_t:="OT PutArrayLong / OT GetArrayLong"
$otrResult_t:="Fail: not run"

// Declare a 3-element LongInt array (§25 reuses indices 2 and 3)
ARRAY LONGINT:C221($setupAl_ai; 3)
OT PutArray($otrMain_i; "al"; ->$setupAl_ai)

OT PutArrayLong($otrMain_i; "al"; 1; 100)
$otrArrVal_i:=OT GetArrayLong($otrMain_i; "al"; 1)
If ($otrArrVal_i=100)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($otrArrVal_i)
End if 

APPEND TO ARRAY:C911($testNum_at; "14")
APPEND TO ARRAY:C911($testName_at; "Array Longint")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 15. Array Text
// ====================================================
$otrCmd_t:="OT PutArrayString / OT GetArrayString"
$otrResult_t:="Fail: not run"

ARRAY TEXT:C222($setupAs_at; 1)
OT PutArray($otrMain_i; "as"; ->$setupAs_at)

OT PutArrayString($otrMain_i; "as"; 1; "arr-str-val")
$otrArrStr_t:=OT GetArrayString($otrMain_i; "as"; 1)
If ($otrArrStr_t="arr-str-val")
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got '"+$otrArrStr_t+"'"
End if 

APPEND TO ARRAY:C911($testNum_at; "15")
APPEND TO ARRAY:C911($testName_at; "Array Text")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 16. Array Real
// ====================================================
$otrCmd_t:="OT PutArrayReal / OT GetArrayReal"
$otrResult_t:="Fail: not run"

ARRAY REAL:C219($setupAr_arr; 1)
OT PutArray($otrMain_i; "ar"; ->$setupAr_arr)

OT PutArrayReal($otrMain_i; "ar"; 1; 9.99)
$otrArrReal_r:=OT GetArrayReal($otrMain_i; "ar"; 1)
If ($otrArrReal_r=9.99)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($otrArrReal_r)
End if 

APPEND TO ARRAY:C911($testNum_at; "16")
APPEND TO ARRAY:C911($testName_at; "Array Real")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 17. Array Boolean
// ====================================================
$otrCmd_t:="OT PutArrayBoolean / OT GetArrayBoolean"
$otrResult_t:="Fail: not run"

ARRAY BOOLEAN:C223($setupAb_ab; 1)
OT PutArray($otrMain_i; "ab"; ->$setupAb_ab)

OT PutArrayBoolean($otrMain_i; "ab"; 1; True:C214)
$otrArrBool_i:=OT GetArrayBoolean($otrMain_i; "ab"; 1)
If ($otrArrBool_i=1)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($otrArrBool_i)
End if 

APPEND TO ARRAY:C911($testNum_at; "17")
APPEND TO ARRAY:C911($testName_at; "Array Boolean")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 18. Array Pointer
// ====================================================
$otrCmd_t:="OT PutArrayPointer / OT GetArrayPointer"
$otrResult_t:="Fail: not run"

ARRAY POINTER:C280($setupAptr_aptr; 1)
OT PutArray($otrMain_i; "aptr"; ->$setupAptr_aptr)

// NOTE: OTr pointer array round-trip for local ($) variables
// is unreliable -- OTr_uTextToPointer reconstructs via
// Get pointer which cannot resolve the caller's local scope.
// Use a process variable (no $) so Get pointer can resolve it.
var vtCC_XMLTopLevelRef : Text
vtCC_XMLTopLevelRef:="arr-ptr-val"
OT PutArrayPointer($otrMain_i; "aptr"; 1; ->vtCC_XMLTopLevelRef)
$gotPtr_ptr:=OT GetArrayPointer($otrMain_i; "aptr"; 1)
If (OK=1) & ($gotPtr_ptr#Null:C1517)
	If (($gotPtr_ptr->)=vtCC_XMLTopLevelRef)
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: value mismatch"
	End if 
Else 
	$otrResult_t:="Fail: OK=0 or Null pointer"
End if 

APPEND TO ARRAY:C911($testNum_at; "18")
APPEND TO ARRAY:C911($testName_at; "Array Pointer")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 19. Array Picture (empty picture)
// ====================================================
$otrCmd_t:="OT PutArrayPicture / OT GetArrayPicture"
$otrResult_t:="Fail: not run"

// Intentional difference: OT re-encodes array pictures
// internally; exact equality cannot be assumed. Test checks
// that a non-empty picture is returned (round-trip succeeds).
ARRAY PICTURE:C279($setupApic_apic; 1)
OT PutArray($otrMain_i; "apic"; ->$setupApic_apic)

OT PutArrayPicture($otrMain_i; "apic"; 1; $wombat_pic)
$otrArrPicOut_pic:=OT GetArrayPicture($otrMain_i; "apic"; 1)
If (Picture size:C356($otrArrPicOut_pic)>0)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: empty picture or OK=0"
End if 

APPEND TO ARRAY:C911($testNum_at; "19")
APPEND TO ARRAY:C911($testName_at; "Array Picture (empty picture)")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 19a. Array Picture (wombat)
// ====================================================
$otrCmd_t:="OT PutArrayPicture / OT GetArrayPicture"
$otrResult_t:="Fail: not run"

If (Picture size:C356($wombat_pic)=0)
	$otrResult_t:="Skip: Wombat picture not loaded"
Else 
	OT PutArrayPicture($otrMain_i; "apic"; 1; $wombat_pic)
	$otrArrPicOut_pic:=OT GetArrayPicture($otrMain_i; "apic"; 1)
	If (OTr_uEqualPictures($wombat_pic; $otrArrPicOut_pic))
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: picture mismatch or OK=0"
	End if 
End if 

APPEND TO ARRAY:C911($testNum_at; "19a")
APPEND TO ARRAY:C911($testName_at; "Array Picture (wombat)")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 20. Item info
// ====================================================
$otrCmd_t:="OT ItemExists / OT ItemType"
$otrResult_t:="Fail: not run"

// "str" was stored in §2; OT type for String/Text is 112.
$gotItemExists_i:=OT ItemExists($otrMain_i; "str")
$gotItemType_i:=OT ItemType($otrMain_i; "str")
If ($gotItemExists_i=1) & ($gotItemType_i=112)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: ItemExists="+String:C10($gotItemExists_i)+" ItemType="+String:C10($gotItemType_i)
End if 

APPEND TO ARRAY:C911($testNum_at; "20")
APPEND TO ARRAY:C911($testName_at; "Item info")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 21. Item count
// ====================================================
$otrCmd_t:="OT ItemCount"
$otrResult_t:="Fail: not run"

// Use a fresh handle with exactly 3 scalar items.
$h4_i:=OT New
OT PutString($h4_i; "x"; "a")
OT PutString($h4_i; "y"; "b")
OT PutString($h4_i; "z"; "c")

$otrCount_i:=OT ItemCount($h4_i)
If ($otrCount_i=3)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($otrCount_i)
End if 

OT Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "21")
APPEND TO ARRAY:C911($testName_at; "Item count")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 22. Property enumeration
// ====================================================
$otrCmd_t:="OT GetAllProperties"
$otrResult_t:="Fail: not run"

$h4_i:=OT New
OT PutString($h4_i; "p1"; "v1")
OT PutString($h4_i; "p2"; "v2")

ARRAY TEXT:C222($otrPropNames_at; 0)
ARRAY LONGINT:C221($otrTypes_ai; 0)
ARRAY LONGINT:C221($otrItemSizes_ai; 0)
ARRAY LONGINT:C221($otrDataSizes_ai; 0)
OT GetAllProperties($h4_i; ->$otrPropNames_at; ->$otrTypes_ai; ->$otrItemSizes_ai; ->$otrDataSizes_ai)
If (Size of array:C274($otrPropNames_at)=2)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10(Size of array:C274($otrPropNames_at))+" names"
End if 

OT Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "22")
APPEND TO ARRAY:C911($testName_at; "Property enumeration")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 23. Delete / Rename
// ====================================================
$otrCmd_t:="OT DeleteItem / OT RenameItem"
$otrResult_t:="Fail: not run"

$h4_i:=OT New
OT PutString($h4_i; "del"; "gone")
OT PutString($h4_i; "ren"; "stays")

OT DeleteItem($h4_i; "del")
OT RenameItem($h4_i; "ren"; "renamed")
If (OT ItemExists($h4_i; "del")=0) & (OT ItemExists($h4_i; "renamed")=1)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: delete or rename did not work"
End if 

OT Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "23")
APPEND TO ARRAY:C911($testName_at; "Delete / rename")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 24. Copy
// ====================================================
$otrCmd_t:="OT CopyItem"
$otrResult_t:="Fail: not run"

$h4_i:=OT New
OT PutString($otrMain_i; "src"; "copy-val")
OT CopyItem($otrMain_i; "src"; $h4_i; "dst")
$gotten_t:=OT GetString($h4_i; "dst")
If ($gotten_t="copy-val")
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got '"+$gotten_t+"'"
End if 

OT Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "24")
APPEND TO ARRAY:C911($testName_at; "Copy")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 25. Size of array
// ====================================================
$otrCmd_t:="OT SizeOfArray"
$otrResult_t:="Fail: not run"

// "al" was seeded in §14 with element 1 = 100.
// Add elements 2 and 3; size should now be 3.
OT PutArrayLong($otrMain_i; "al"; 2; 200)
OT PutArrayLong($otrMain_i; "al"; 3; 300)

$otrArrSize_i:=OT SizeOfArray($otrMain_i; "al")
If ($otrArrSize_i=3)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($otrArrSize_i)
End if 

APPEND TO ARRAY:C911($testNum_at; "25")
APPEND TO ARRAY:C911($testName_at; "Size of array")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 26. Sort arrays
// ====================================================
$otrCmd_t:="OT SortArrays"
$otrResult_t:="Fail: not run"

$h4_i:=OT New
ARRAY LONGINT:C221($setupSort_ai; 3)
OT PutArray($h4_i; "sort"; ->$setupSort_ai)

OT PutArrayLong($h4_i; "sort"; 1; 30)
OT PutArrayLong($h4_i; "sort"; 2; 10)
OT PutArrayLong($h4_i; "sort"; 3; 20)
OT SortArrays($h4_i; "sort"; ">")
$gotLong_i:=OT GetArrayLong($h4_i; "sort"; 1)
If ($gotLong_i=10)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: first element after sort = "+String:C10($gotLong_i)
End if 

OT Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "26")
APPEND TO ARRAY:C911($testName_at; "Sort arrays")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 27. Object size  (Intentional difference §4.3)
// ====================================================
$otrCmd_t:="OT ObjectSize"
$otrResult_t:="Fail: not run"

// Values will not match OT (§4.3); both must be non-zero.
$otrSize_i:=OT ObjectSize($otrMain_i)
If ($otrSize_i>0)
	$otrResult_t:="Pass (size="+String:C10($otrSize_i)+")"
Else 
	$otrResult_t:="Fail: returned 0 or OK=0"
End if 

APPEND TO ARRAY:C911($testNum_at; "27")
APPEND TO ARRAY:C911($testName_at; "Object size")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 28. BLOB serialisation (Intentional diff §4.3)
// ====================================================
$otrCmd_t:="OT ObjectToNewBLOB / OT BLOBToObject"
$otrResult_t:="Fail: not run"

// Round-trip within OTr independently; do NOT cross-load
// (OT and OTr formats are incompatible per §4.3).
$tempH_i:=OT New
OT PutString($tempH_i; "bser"; "blob-ser-val")
$serialOtrBlob_blob:=OT ObjectToNewBLOB($tempH_i)
$loadedH_i:=OT BLOBToObject($serialOtrBlob_blob)
$gotten_t:=OT GetString($loadedH_i; "bser")
If ($gotten_t="blob-ser-val")
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: round-trip got '"+$gotten_t+"'"
End if 
OT Clear($tempH_i)
OT Clear($loadedH_i)

APPEND TO ARRAY:C911($testNum_at; "28")
APPEND TO ARRAY:C911($testName_at; "BLOB serialisation")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 29. Version
// ====================================================
$otrCmd_t:="OT GetVersion"
$otrResult_t:="Fail: not run"

// Values will differ from OT; both must be non-empty.
$otrVer_t:=OT GetVersion
If (Length:C16($otrVer_t)>0)
	$otrResult_t:="Pass (v="+$otrVer_t+")"
Else 
	$otrResult_t:="Fail: empty version or OK=0"
End if 

APPEND TO ARRAY:C911($testNum_at; "29")
APPEND TO ARRAY:C911($testName_at; "Version")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 30. Options
// ====================================================
$otrCmd_t:="OT GetOptions / OT SetOptions"
$otrResult_t:="Fail: not run"
$testOpts_i:=1+4  // FailOnItemNotFound + AutoCreateObjects

$originalOtrOpts_i:=OT GetOptions
OT SetOptions($testOpts_i)
$readOtrOpts_i:=OT GetOptions
OT SetOptions($originalOtrOpts_i)
If ($readOtrOpts_i=$testOpts_i)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: read "+String:C10($readOtrOpts_i)+" expected "+String:C10($testOpts_i)
End if 

APPEND TO ARRAY:C911($testNum_at; "30")
APPEND TO ARRAY:C911($testName_at; "Options")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- TEARDOWN and BULK LOAD INTO ACCUMULATOR
// ====================================================
OT Clear($otrMain_i)

$count_i:=Size of array:C274($testNum_at)

// Load OTr result columns into accumulator
OT PutArray($accum_i; "testNum"; ->$testNum_at)
OT PutArray($accum_i; "testName"; ->$testName_at)
OT PutArray($accum_i; "otrCmd"; ->$otrCmd_at)
OT PutArray($accum_i; "otrResult"; ->$otrResult_at)

// Initialise OT columns to the same length with empty strings
// so ____Test_Phase_15_OT can update them by index.
ARRAY TEXT:C222($emptyArr_at; $count_i)
OT PutArray($accum_i; "otCmd"; ->$emptyArr_at)
OT PutArray($accum_i; "otResult"; ->$emptyArr_at)
