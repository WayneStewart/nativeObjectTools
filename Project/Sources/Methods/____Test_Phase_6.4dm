//%attributes = {"invisible":true,"shared":false}
  // ----------------------------------------------------
  // Project Method: ____Test_Phase_6

  // Unit tests for all Phase 6 methods:
  //   OTr_uMapType
  //   OTr_ObjectToBLOB / OTr_ObjectToNewBLOB / OTr_BLOBToObject
  //
  // Tests cover:
  //   OTr_uMapType — 4D→OT and OT→4D spot checks
  //   Scalar round-trip (text, long, real, boolean, date, time)
  //   BLOB item round-trip (binary attachment table)
  //   Picture item round-trip (binary attachment table)
  //   OTr_ObjectToNewBLOB — function result form
  //   OTr_BLOBToObject — invalid data error case

  // Access: Private

  // Returns: Nothing (results shown via ALERT,
  //          summary copied to pasteboard)

  // Created by Wayne Stewart, 2026-04-03
  // Based on work by himself, Rob Laveaux, and Cannon Smith.
  // ----------------------------------------------------

var $h_i : Integer
var $h2_i : Integer
var $h3_i : Integer
var $h4_i : Integer
var $total_i; $passed_i; $failed_i : Integer
var $failures_t : Text
var $summary_t : Text

// MapType test vars
var $mapResult_i : Integer

// Scalar round-trip test vars
var $serialBlob_blob : Blob
var $gotStr_t : Text
var $gotLong_i : Integer
var $gotReal_r : Real
var $gotBool_i : Integer

// Binary round-trip test vars
var $testBlob_blob : Blob
var $roundTripBlob_blob : Blob
var $gotBlob_blob : Blob
var $pngB64_t : Text
var $pngBlob_blob : Blob
var $testPic_pic : Picture
var $gotPic_pic : Picture

// Invalid data test vars
var $badBlob_blob : Blob

// ====================================================
// SETUP
// ====================================================
OTr_ClearAll
$total_i := 0
$passed_i := 0
$failed_i := 0
$failures_t := ""

// ====================================================
//MARK:- OTr_uMapType — 4D→OT direction
// ====================================================

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(Is longint; 0)
If ($mapResult_i = 5)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: Is longint → OT Longint (5)"+Char(Carriage return)
End if

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(Is real; 0)
If ($mapResult_i = 1)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: Is real → OT Real (1)"+Char(Carriage return)
End if

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(Is text; 0)
If ($mapResult_i = 112)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: Is text → OT Character (112)"+Char(Carriage return)
End if

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(Is picture; 0)
If ($mapResult_i = 3)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: Is picture → OT Picture (3)"+Char(Carriage return)
End if

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(Is collection; 0)
If ($mapResult_i = 113)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: Is collection → OT Array Char (113)"+Char(Carriage return)
End if

// ====================================================
//MARK:- OTr_uMapType — OT→4D direction
// ====================================================

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(5; 1)
If ($mapResult_i = Is longint)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: OT Longint (5) → Is longint"+Char(Carriage return)
End if

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(115; 1)
If ($mapResult_i = Is text)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: OT Record (115) → Is text"+Char(Carriage return)
End if

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(24; 1)
If ($mapResult_i = Is text)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: OT Variable (24) → Is text"+Char(Carriage return)
End if

// ====================================================
//MARK:- OTr_uMapType — default direction (no second param)
// ====================================================

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(Is Boolean)
If ($mapResult_i = 6)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: Is Boolean → OT Boolean default dir"+Char(Carriage return)
End if

// ====================================================
//MARK:- OTr_uMapType — unknown type returns 0
// ====================================================

$total_i := $total_i+1
$mapResult_i := OTr_uMapType(9999; 0)
If ($mapResult_i = 0)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"uMapType: unknown type should return 0"+Char(Carriage return)
End if

// ====================================================
//MARK:- OTr_ObjectToNewBLOB — scalar round-trip
// ====================================================

$h_i := OTr_New
OTr_PutString($h_i; "name"; "phase6-test")
OTr_PutLong($h_i; "count"; 42)
OTr_PutReal($h_i; "ratio"; 3.14)
OTr_PutBoolean($h_i; "flag"; True)

$total_i := $total_i+1
$serialBlob_blob := OTr_ObjectToNewBLOB($h_i)
If ((OK = 1) & (BLOB SIZE($serialBlob_blob) > 0))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"ObjectToNewBLOB: serial BLOB empty or OK=0"+Char(Carriage return)
End if

// Checkpoint: inspect bytes
OTr_SaveToClipboard($h_i)

$total_i := $total_i+1
$h2_i := OTr_BLOBToObject($serialBlob_blob)
If ((OK = 1) & ($h2_i > 0))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOBToObject: invalid handle or OK=0"+Char(Carriage return)
End if

$total_i := $total_i+1
$gotStr_t := OTr_GetString($h2_i; "name")
If ($gotStr_t = "phase6-test")
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOBToObject round-trip: string value"+Char(Carriage return)
End if

$total_i := $total_i+1
$gotLong_i := OTr_GetLong($h2_i; "count")
If ($gotLong_i = 42)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOBToObject round-trip: long value"+Char(Carriage return)
End if

$total_i := $total_i+1
$gotReal_r := OTr_GetReal($h2_i; "ratio")
If ($gotReal_r = 3.14)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOBToObject round-trip: real value"+Char(Carriage return)
End if

$total_i := $total_i+1
$gotBool_i := OTr_GetBoolean($h2_i; "flag")
If ($gotBool_i = 1)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOBToObject round-trip: boolean value"+Char(Carriage return)
End if

// ====================================================
//MARK:- OTr_BLOBToObject — invalid handle returns OK=0
// ====================================================

$total_i := $total_i+1
SET BLOB SIZE($serialBlob_blob; 0)  // clear the BLOB
OTr_ObjectToBLOB(9999; ->$serialBlob_blob)
If (OK = 0)
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"ObjectToBLOB invalid handle should set OK=0"+Char(Carriage return)
End if
OK := 1

// ====================================================
//MARK:- BLOB item round-trip (binary attachment table)
// ====================================================

$h3_i := OTr_New
CONVERT FROM TEXT("hello-otr-phase6"; "UTF-8"; $testBlob_blob)
OTr_PutBLOB($h3_i; "bdata"; $testBlob_blob)

$total_i := $total_i+1
$roundTripBlob_blob := OTr_ObjectToNewBLOB($h3_i)
If ((OK = 1) & (BLOB SIZE($roundTripBlob_blob) > 0))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOB item: ObjectToNewBLOB OK=0 or empty"+Char(Carriage return)
End if

$total_i := $total_i+1
$h4_i := OTr_BLOBToObject($roundTripBlob_blob)
If ((OK = 1) & ($h4_i > 0))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOB item: BLOBToObject returned 0 or OK=0"+Char(Carriage return)
End if

$total_i := $total_i+1
$gotBlob_blob := OTr_GetNewBLOB($h4_i; "bdata")
If ((OK = 1) & (OTr_uEqualBLOBs($testBlob_blob; $gotBlob_blob)))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOB item: round-trip content mismatch"+Char(Carriage return)
End if

// ====================================================
//MARK:- Picture item round-trip (binary attachment table)
// ====================================================

// 1×1 black pixel PNG, hardcoded Base64
$pngB64_t := "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
CONVERT FROM TEXT($pngB64_t; "US-ASCII"; $pngBlob_blob)
BASE64 DECODE($pngBlob_blob)
BLOB TO PICTURE($pngBlob_blob; $testPic_pic; ".png")

$h_i := OTr_New
OTr_PutPicture($h_i; "pdata"; $testPic_pic)

$total_i := $total_i+1
$roundTripBlob_blob := OTr_ObjectToNewBLOB($h_i)
If ((OK = 1) & (BLOB SIZE($roundTripBlob_blob) > 0))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"Picture item: ObjectToNewBLOB OK=0 or empty"+Char(Carriage return)
End if

$total_i := $total_i+1
$h2_i := OTr_BLOBToObject($roundTripBlob_blob)
If ((OK = 1) & ($h2_i > 0))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"Picture item: BLOBToObject returned 0 or OK=0"+Char(Carriage return)
End if

$total_i := $total_i+1
$gotPic_pic := OTr_GetPicture($h2_i; "pdata")
If ((OK = 1) & (OTr_uEqualPictures($testPic_pic; $gotPic_pic)))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"Picture item: round-trip content mismatch"+Char(Carriage return)
End if

// ====================================================
//MARK:- OTr_BLOBToObject — invalid data error case
// ====================================================

CONVERT FROM TEXT("NOT_OTR1_DATA"; "US-ASCII"; $badBlob_blob)

$total_i := $total_i+1
$h_i := OTr_BLOBToObject($badBlob_blob)
If ((OK = 0) & ($h_i = 0))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOBToObject: invalid data should return 0 and OK=0"+Char(Carriage return)
End if
OK := 1

// ====================================================
//MARK:- OTr_BLOBToObject — BLOB too small error case
// ====================================================

CONVERT FROM TEXT("OTR"; "US-ASCII"; $badBlob_blob)  // only 3 bytes

$total_i := $total_i+1
$h_i := OTr_BLOBToObject($badBlob_blob)
If ((OK = 0) & ($h_i = 0))
	$passed_i := $passed_i+1
Else
	$failed_i := $failed_i+1
	$failures_t := $failures_t+"BLOBToObject: tiny BLOB should return 0 and OK=0"+Char(Carriage return)
End if
OK := 1

// ====================================================
//MARK:- SUMMARY
// ====================================================
OTr_ClearAll

$summary_t := "Phase 6 Tests"+Char(Carriage return)
$summary_t := $summary_t+"Total:  "+String($total_i)+Char(Carriage return)
$summary_t := $summary_t+"Passed: "+String($passed_i)+Char(Carriage return)
$summary_t := $summary_t+"Failed: "+String($failed_i)

If ($failed_i > 0)
	$summary_t := $summary_t+Char(Carriage return)+Char(Carriage return)+"Failures:"+Char(Carriage return)+$failures_t
End if

ALERT($summary_t)
SET TEXT TO PASTEBOARD($summary_t)
