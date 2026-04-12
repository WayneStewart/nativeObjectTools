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
// Must NOT call OTr_ClearAll -- the accumulator handle
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

// ==== BEGIN OTr BLOCK — comment out when renamed to OT  ====
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
// (does NOTr_Clear all -- accumulator must survive)
// ----------------------------------------------------
$otrMain_i:=OTr_New
$wombat_pic:=OTr_z_Wombat

// ====================================================
//MARK:- 1. Creation / Destruction
// ====================================================
$otrCmd_t:="OTr_New / OTr_Clear"
$otrResult_t:="Fail: not run"

$testOtrH_i:=OTr_New
If ($testOtrH_i#0)
	OTr_Clear($testOtrH_i)
	If (OK=1)
		$otrResult_t:="Pass"
	Else 
		$otrResult_t:="Fail: OTr_Clear set OK=0"
	End if 
Else 
	$otrResult_t:="Fail: OTr_New returned 0"
End if 

APPEND TO ARRAY:C911($testNum_at; "1")
APPEND TO ARRAY:C911($testName_at; "Creation / destruction")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 2. String / Text
// ====================================================
$otrCmd_t:="OTr_PutString / OTr_GetString"
$otrResult_t:="Fail: not run"

OTr_PutString($otrMain_i; "str"; "compat-str")
$gotten_t:=OTr_GetString($otrMain_i; "str")
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
$otrCmd_t:="OTr_PutLong / OTr_GetLong"
$otrResult_t:="Fail: not run"

OTr_PutLong($otrMain_i; "num"; 424242)
$gotLong_i:=OTr_GetLong($otrMain_i; "num")
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
$otrCmd_t:="OTr_PutReal / OTr_GetReal"
$otrResult_t:="Fail: not run"

OTr_PutReal($otrMain_i; "ratio"; 3.14159)
$gotReal_r:=OTr_GetReal($otrMain_i; "ratio")
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
$otrCmd_t:="OTr_PutBoolean / OTr_GetBoolean"
$otrResult_t:="Fail: not run"

OTr_PutBoolean($otrMain_i; "flag"; True:C214)
$gotBool_i:=OTr_GetBoolean($otrMain_i; "flag")
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
$otrCmd_t:="OTr_PutDate / OTr_GetDate"
$otrResult_t:="Fail: not run"
$testDate_d:=!2026-04-04!

OTr_PutDate($otrMain_i; "dt"; $testDate_d)
$gotDate_d:=OTr_GetDate($otrMain_i; "dt")
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
$otrCmd_t:="OTr_PutTime / OTr_GetTime"
$otrResult_t:="Fail: not run"
$testTime_h:=?10:30:45?

OTr_PutTime($otrMain_i; "tm"; $testTime_h)
$gotTime_h:=OTr_GetTime($otrMain_i; "tm")
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
$otrCmd_t:="OTr_PutPointer / OTr_GetPointer"
$otrResult_t:="Fail: not run"
// Use a process variable (no $) so OTr_u_TextToPointer can
// reconstruct it via Get pointer. Local ($) variables cannot
// be resolved by name -- this is a 4D platform constraint,
// not an OTr defect, and matches the OT 5.0 documented limit.
vtCC_Filename:="otr-ptr-val"

OTr_PutPointer($otrMain_i; "ptr"; ->vtCC_Filename)
OTr_GetPointer($otrMain_i; "ptr"; ->$gotPtr_ptr)
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
$otrCmd_t:="OTr_PutPicture / OTr_GetPicture"
$otrResult_t:="Fail: not run"

OTr_PutPicture($otrMain_i; "pic"; $wombat_pic)
$gotPic_pic:=OTr_GetPicture($otrMain_i; "pic")
If (OTr_u_EqualPictures($wombat_pic; $gotPic_pic))
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
$otrCmd_t:="OTr_PutPicture / OTr_GetPicture"
$otrResult_t:="Fail: not run"

If (Picture size:C356($wombat_pic)=0)
	$otrResult_t:="Skip: Wombat picture not loaded"
Else 
	OTr_PutPicture($otrMain_i; "pic9a"; $wombat_pic)
	$gotPic_pic:=OTr_GetPicture($otrMain_i; "pic9a")
	If (OTr_u_EqualPictures($wombat_pic; $gotPic_pic))
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
$otrCmd_t:="OTr_PutBLOB / OTr_GetNewBLOB"
$otrResult_t:="Fail: not run"
CONVERT FROM TEXT:C1011("compat-blob-data"; "UTF-8"; $testBlob_blob)

OTr_PutBLOB($otrMain_i; "blob"; $testBlob_blob)
$gotBlob_blob:=OTr_GetNewBLOB($otrMain_i; "blob")
If (OTr_u_EqualBLOBs($testBlob_blob; $gotBlob_blob))
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
$otrCmd_t:="OTr_PutVariable / OTr_GetVariable"
$otrResult_t:="Fail: not run"
$varTarget_t:="otr-var-val"
$varDest_t:=""

OTr_PutVariable($otrMain_i; "var"; ->$varTarget_t)
OTr_GetVariable($otrMain_i; "var"; ->$varDest_t)
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
$otrCmd_t:="OTr_PutRecord / OTr_GetRecord"
$otrResult_t:="Fail: not run"

// Create and save a record so there is a current record
// in table 1 for OTr_PutRecord to reference.
CREATE RECORD:C68([Table_1:1])
[Table_1:1]Name:2:="OTr-Wayne"
SAVE RECORD:C53([Table_1:1])

OTr_PutRecord($otrMain_i; "rec"; 1)
CREATE RECORD:C68([Table_1:1])
OTr_GetRecord($otrMain_i; "rec"; 1)
If (OK=1)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: OTr_GetRecord set OK=0"
End if 
// SAVE RECORD intentionally omitted -- new record is discarded.

APPEND TO ARRAY:C911($testNum_at; "12")
APPEND TO ARRAY:C911($testName_at; "Record")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 13. Dot-path
// ====================================================
$otrCmd_t:="OTr_PutString (dotted) / OTr_GetString"
$otrResult_t:="Fail: not run"

OTr_PutString($otrMain_i; "a.b.c"; "dot-val")
$gotten_t:=OTr_GetString($otrMain_i; "a.b.c")
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
$otrCmd_t:="OTr_PutArrayLong / OTr_GetArrayLong"
$otrResult_t:="Fail: not run"

// Declare a 3-element LongInt array (§25 reuses indices 2 and 3)
ARRAY LONGINT:C221($setupAl_ai; 3)
OTr_PutArray($otrMain_i; "al"; ->$setupAl_ai)

OTr_PutArrayLong($otrMain_i; "al"; 1; 100)
$otrArrVal_i:=OTr_GetArrayLong($otrMain_i; "al"; 1)
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
$otrCmd_t:="OTr_PutArrayString / OTr_GetArrayString"
$otrResult_t:="Fail: not run"

ARRAY TEXT:C222($setupAs_at; 1)
OTr_PutArray($otrMain_i; "as"; ->$setupAs_at)

OTr_PutArrayString($otrMain_i; "as"; 1; "arr-str-val")
$otrArrStr_t:=OTr_GetArrayString($otrMain_i; "as"; 1)
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
$otrCmd_t:="OTr_PutArrayReal / OTr_GetArrayReal"
$otrResult_t:="Fail: not run"

ARRAY REAL:C219($setupAr_arr; 1)
OTr_PutArray($otrMain_i; "ar"; ->$setupAr_arr)

OTr_PutArrayReal($otrMain_i; "ar"; 1; 9.99)
$otrArrReal_r:=OTr_GetArrayReal($otrMain_i; "ar"; 1)
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
$otrCmd_t:="OTr_PutArrayBoolean / OTr_GetArrayBoolean"
$otrResult_t:="Fail: not run"

ARRAY BOOLEAN:C223($setupAb_ab; 1)
OTr_PutArray($otrMain_i; "ab"; ->$setupAb_ab)

OTr_PutArrayBoolean($otrMain_i; "ab"; 1; True:C214)
$otrArrBool_i:=OTr_GetArrayBoolean($otrMain_i; "ab"; 1)
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
$otrCmd_t:="OTr_PutArrayPointer / OTr_GetArrayPointer"
$otrResult_t:="Fail: not run"

ARRAY POINTER:C280($setupAptr_aptr; 1)
OTr_PutArray($otrMain_i; "aptr"; ->$setupAptr_aptr)

// NOTE: OTr pointer array round-trip for local ($) variables
// is unreliable -- OTr_u_TextToPointer reconstructs via
// Get pointer which cannot resolve the caller's local scope.
// Use a process variable (no $) so Get pointer can resolve it.
var vtCC_XMLTopLevelRef : Text
vtCC_XMLTopLevelRef:="arr-ptr-val"
OTr_PutArrayPointer($otrMain_i; "aptr"; 1; ->vtCC_XMLTopLevelRef)
$gotPtr_ptr:=OTr_GetArrayPointer($otrMain_i; "aptr"; 1)
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
$otrCmd_t:="OTr_PutArrayPicture / OTr_GetArrayPicture"
$otrResult_t:="Fail: not run"

// Intentional difference: OT re-encodes array pictures
// internally; exact equality cannot be assumed. Test checks
// that a non-empty picture is returned (round-trip succeeds).
ARRAY PICTURE:C279($setupApic_apic; 1)
OTr_PutArray($otrMain_i; "apic"; ->$setupApic_apic)

OTr_PutArrayPicture($otrMain_i; "apic"; 1; $wombat_pic)
$otrArrPicOut_pic:=OTr_GetArrayPicture($otrMain_i; "apic"; 1)
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
$otrCmd_t:="OTr_PutArrayPicture / OTr_GetArrayPicture"
$otrResult_t:="Fail: not run"

If (Picture size:C356($wombat_pic)=0)
	$otrResult_t:="Skip: Wombat picture not loaded"
Else 
	OTr_PutArrayPicture($otrMain_i; "apic"; 1; $wombat_pic)
	$otrArrPicOut_pic:=OTr_GetArrayPicture($otrMain_i; "apic"; 1)
	If (OTr_u_EqualPictures($wombat_pic; $otrArrPicOut_pic))
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
$otrCmd_t:="OTr_ItemExists / OTr_ItemType"
$otrResult_t:="Fail: not run"

// "str" was stored in §2; OT type for String/Text is 112.
$gotItemExists_i:=OTr_ItemExists($otrMain_i; "str")
$gotItemType_i:=OTr_ItemType($otrMain_i; "str")
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
$otrCmd_t:="OTr_ItemCount"
$otrResult_t:="Fail: not run"

// Use a fresh handle with exactly 3 scalar items.
$h4_i:=OTr_New
OTr_PutString($h4_i; "x"; "a")
OTr_PutString($h4_i; "y"; "b")
OTr_PutString($h4_i; "z"; "c")

$otrCount_i:=OTr_ItemCount($h4_i)
If ($otrCount_i=3)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10($otrCount_i)
End if 

OTr_Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "21")
APPEND TO ARRAY:C911($testName_at; "Item count")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 22. Property enumeration
// ====================================================
$otrCmd_t:="OTr_GetAllProperties"
$otrResult_t:="Fail: not run"

$h4_i:=OTr_New
OTr_PutString($h4_i; "p1"; "v1")
OTr_PutString($h4_i; "p2"; "v2")

ARRAY TEXT:C222($otrPropNames_at; 0)
ARRAY LONGINT:C221($otrTypes_ai; 0)
ARRAY LONGINT:C221($otrItemSizes_ai; 0)
ARRAY LONGINT:C221($otrDataSizes_ai; 0)
OTr_GetAllProperties($h4_i; ->$otrPropNames_at; ->$otrTypes_ai; ->$otrItemSizes_ai; ->$otrDataSizes_ai)
If (Size of array:C274($otrPropNames_at)=2)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got "+String:C10(Size of array:C274($otrPropNames_at))+" names"
End if 

OTr_Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "22")
APPEND TO ARRAY:C911($testName_at; "Property enumeration")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 23. Delete / Rename
// ====================================================
$otrCmd_t:="OTr_DeleteItem / OTr_RenameItem"
$otrResult_t:="Fail: not run"

$h4_i:=OTr_New
OTr_PutString($h4_i; "del"; "gone")
OTr_PutString($h4_i; "ren"; "stays")

OTr_DeleteItem($h4_i; "del")
OTr_RenameItem($h4_i; "ren"; "renamed")
If (OTr_ItemExists($h4_i; "del")=0) & (OTr_ItemExists($h4_i; "renamed")=1)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: delete or rename did not work"
End if 

OTr_Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "23")
APPEND TO ARRAY:C911($testName_at; "Delete / rename")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 24. Copy
// ====================================================
$otrCmd_t:="OTr_CopyItem"
$otrResult_t:="Fail: not run"

$h4_i:=OTr_New
OTr_PutString($otrMain_i; "src"; "copy-val")
OTr_CopyItem($otrMain_i; "src"; $h4_i; "dst")
$gotten_t:=OTr_GetString($h4_i; "dst")
If ($gotten_t="copy-val")
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: got '"+$gotten_t+"'"
End if 

OTr_Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "24")
APPEND TO ARRAY:C911($testName_at; "Copy")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 25. Size of array
// ====================================================
$otrCmd_t:="OTr_SizeOfArray"
$otrResult_t:="Fail: not run"

// "al" was seeded in §14 with element 1 = 100.
// Add elements 2 and 3; size should now be 3.
OTr_PutArrayLong($otrMain_i; "al"; 2; 200)
OTr_PutArrayLong($otrMain_i; "al"; 3; 300)

$otrArrSize_i:=OTr_SizeOfArray($otrMain_i; "al")
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
$otrCmd_t:="OTr_SortArrays"
$otrResult_t:="Fail: not run"

$h4_i:=OTr_New
ARRAY LONGINT:C221($setupSort_ai; 3)
OTr_PutArray($h4_i; "sort"; ->$setupSort_ai)

OTr_PutArrayLong($h4_i; "sort"; 1; 30)
OTr_PutArrayLong($h4_i; "sort"; 2; 10)
OTr_PutArrayLong($h4_i; "sort"; 3; 20)
OTr_SortArrays($h4_i; "sort"; ">")
$gotLong_i:=OTr_GetArrayLong($h4_i; "sort"; 1)
If ($gotLong_i=10)
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: first element after sort = "+String:C10($gotLong_i)
End if 

OTr_Clear($h4_i)

APPEND TO ARRAY:C911($testNum_at; "26")
APPEND TO ARRAY:C911($testName_at; "Sort arrays")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 27. Object size  (Intentional difference §4.3)
// ====================================================
$otrCmd_t:="OTr_ObjectSize"
$otrResult_t:="Fail: not run"

// Values will not match OT (§4.3); both must be non-zero.
$otrSize_i:=OTr_ObjectSize($otrMain_i)
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
$otrCmd_t:="OTr_ObjectToNewBLOB / OTr_BLOBToObject"
$otrResult_t:="Fail: not run"

// Round-trip within OTr independently; do NOT cross-load
// (OT and OTr formats are incompatible per §4.3).
$tempH_i:=OTr_New
OTr_PutString($tempH_i; "bser"; "blob-ser-val")
$serialOtrBlob_blob:=OTr_ObjectToNewBLOB($tempH_i)
$loadedH_i:=OTr_BLOBToObject($serialOtrBlob_blob)
$gotten_t:=OTr_GetString($loadedH_i; "bser")
If ($gotten_t="blob-ser-val")
	$otrResult_t:="Pass"
Else 
	$otrResult_t:="Fail: round-trip got '"+$gotten_t+"'"
End if 
OTr_Clear($tempH_i)
OTr_Clear($loadedH_i)

APPEND TO ARRAY:C911($testNum_at; "28")
APPEND TO ARRAY:C911($testName_at; "BLOB serialisation")
APPEND TO ARRAY:C911($otrCmd_at; $otrCmd_t)
APPEND TO ARRAY:C911($otrResult_at; $otrResult_t)

// ====================================================
//MARK:- 29. Version
// ====================================================
$otrCmd_t:="OTr_GetVersion"
$otrResult_t:="Fail: not run"

// Values will differ from OT; both must be non-empty.
$otrVer_t:=OTr_GetVersion
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
$otrCmd_t:="OTr_GetOptions / OTr_SetOptions"
$otrResult_t:="Fail: not run"
$testOpts_i:=1+4  // FailOnItemNotFound + AutoCreateObjects

$originalOtrOpts_i:=OTr_GetOptions
OTr_SetOptions($testOpts_i)
$readOtrOpts_i:=OTr_GetOptions
OTr_SetOptions($originalOtrOpts_i)
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
OTr_Clear($otrMain_i)

$count_i:=Size of array:C274($testNum_at)

// Load OTr result columns into accumulator
OTr_PutArray($accum_i; "testNum"; ->$testNum_at)
OTr_PutArray($accum_i; "testName"; ->$testName_at)
OTr_PutArray($accum_i; "otrCmd"; ->$otrCmd_at)
OTr_PutArray($accum_i; "otrResult"; ->$otrResult_at)

// Initialise OT columns to the same length with empty strings
// so ____Test_Phase_15_OT can update them by index.
ARRAY TEXT:C222($emptyArr_at; $count_i)
OTr_PutArray($accum_i; "otCmd"; ->$emptyArr_at)
OTr_PutArray($accum_i; "otResult"; ->$emptyArr_at)
// ==== END OTr BLOCK ====
