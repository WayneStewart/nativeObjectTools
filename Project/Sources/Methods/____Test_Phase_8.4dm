//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_8

// Tests for Phase 8: OTr_u_AccessArrayElement and all
// typed _New accessors.
//
// Covers all 10 types:
//   LongInt, Real, String, Text (alias), Date, Time,
//   Boolean, BLOB, Picture, Pointer
//
// Per type: Put round-trip, Get value, OK unchanged on success.
// Shared error paths tested once (LongInt):
//   invalid handle, missing tag, type mismatch, out-of-range.

// Access: Private

// Returns: Nothing (summary ALERT at end)

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-05 - Added all remaining typed accessor tests.
// ----------------------------------------------------
var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t : Text

// ----------------------------------------------------

$StackSize_i:=0
$DesiredProcessName_t:=Current method name:C684

If (Current process name:C1392=$DesiredProcessName_t)

	var $h_i : Integer
	var $total_i; $passed_i; $failed_i : Integer
	var $failures_t : Text
	var $savedOK_i : Integer
	var $result_i : Integer
	var $result_r : Real
	var $result_t : Text
	var $result_d : Date
	var $result_h : Time
	var $result_blob : Blob
	var $result_pic : Picture
	var $result_ptr : Pointer
	var $testBlob_blob : Blob
	var $testDate_d : Date
	var $testTime_h : Time
	var $testWombat_pic : Picture
	var $subH_i : Integer

	ARRAY LONGINT:C221($longArr_ai; 0)
	ARRAY REAL:C219($realArr_ar; 0)
	ARRAY TEXT:C222($textArr_at; 0)
	ARRAY DATE:C224($dateArr_ad; 0)
	ARRAY TIME:C1223($timeArr_ah; 0)
	ARRAY BOOLEAN:C223($boolArr_ab; 0)
	ARRAY BLOB:C1222($blobArr_ablob; 0)
	ARRAY PICTURE:C279($picArr_apic; 0)
	ARRAY POINTER:C280($ptrArr_aptr; 0)

	// ====================================================
	// SETUP
	// ====================================================
	OTr_ClearAll
	$h_i:=OTr_New
	$total_i:=0
	$passed_i:=0
	$failed_i:=0
	$failures_t:=""

	$testWombat_pic:=OTr_z_Wombat()  // A lovely wombat
	vtCC_Filename:=Structure file:C489  // This already declared in a compiler method, so it won't cause any problems here

	// Build a top-level 5-element LongInt array
	ARRAY LONGINT:C221($longArr_ai; 5)
	$longArr_ai{1}:=100
	$longArr_ai{2}:=200
	$longArr_ai{3}:=300
	$longArr_ai{4}:=400
	$longArr_ai{5}:=500
	OTr_PutArray($h_i; "longs"; ->$longArr_ai)

	// Real array (3 elements)
	ARRAY REAL:C219($realArr_ar; 3)
	$realArr_ar{1}:=1.1
	$realArr_ar{2}:=2.2
	$realArr_ar{3}:=3.3
	OTr_PutArray($h_i; "reals"; ->$realArr_ar)

	// Text array (3 elements)
	ARRAY TEXT:C222($textArr_at; 3)
	$textArr_at{1}:="alpha"
	$textArr_at{2}:="beta"
	$textArr_at{3}:="gamma"
	OTr_PutArray($h_i; "words"; ->$textArr_at)

	// Date array (3 elements)
	$testDate_d:=!2026-01-15!
	ARRAY DATE:C224($dateArr_ad; 3)
	$dateArr_ad{1}:=!2026-01-01!
	$dateArr_ad{2}:=!2026-06-15!
	$dateArr_ad{3}:=!2026-12-31!
	OTr_PutArray($h_i; "dates"; ->$dateArr_ad)

	// Time array (3 elements)
	$testTime_h:=?08:30:00?
	ARRAY TIME:C1223($timeArr_ah; 3)
	$timeArr_ah{1}:=?08:00:00?
	$timeArr_ah{2}:=?12:30:00?
	$timeArr_ah{3}:=?23:59:59?
	OTr_PutArray($h_i; "times"; ->$timeArr_ah)

	// Boolean array (3 elements)
	ARRAY BOOLEAN:C223($boolArr_ab; 3)
	$boolArr_ab{1}:=True:C214
	$boolArr_ab{2}:=False:C215
	$boolArr_ab{3}:=True:C214
	OTr_PutArray($h_i; "flags"; ->$boolArr_ab)

	// BLOB array (3 elements — store text bytes as BLOBs)
	ARRAY BLOB:C1222($blobArr_ablob; 3)
	TEXT TO BLOB:C554("hello"; $blobArr_ablob{1})
	TEXT TO BLOB:C554("world"; $blobArr_ablob{2})
	TEXT TO BLOB:C554("test"; $blobArr_ablob{3})
	OTr_PutArray($h_i; "blobs"; ->$blobArr_ablob)

	// Picture array (3 elements — element 1 seeded with wombat)
	ARRAY PICTURE:C279($picArr_apic; 3)
	$picArr_apic{1}:=$testWombat_pic
	OTr_PutArray($h_i; "pics"; ->$picArr_apic)

	// Pointer array (3 elements — element 1 seeded with ->vtCC_Filename)
	ARRAY POINTER:C280($ptrArr_aptr; 3)
	$ptrArr_aptr{1}:=->vtCC_Filename
	OTr_PutArray($h_i; "ptrs"; ->$ptrArr_aptr)

	// Build a sub-object containing a 3-element LongInt array.
	// Dot path: "sub.vals"
	$subH_i:=OTr_New
	ARRAY LONGINT:C221($longArr_ai; 3)
	$longArr_ai{1}:=11
	$longArr_ai{2}:=22
	$longArr_ai{3}:=33
	OTr_PutArray($subH_i; "vals"; ->$longArr_ai)
	OTr_PutObject($h_i; "sub"; $subH_i)

	OTr_SaveToClipboard($h_i)

	OTr_Clear($subH_i)



	// ====================================================
	//MARK:- GET — top-level array, in-range element
	// ====================================================

	$total_i:=$total_i+1
	$result_i:=OTr_GetArrayLong($h_i; "longs"; 3)
	If ($result_i=300)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GET top-level element 3 expected 300, got "+String:C10($result_i)+" OK="+String:C10(OK)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- GET — top-level array, element 1 and element 5
	// ====================================================

	$total_i:=$total_i+1
	If (OTr_GetArrayLong($h_i; "longs"; 1)=100) & (OTr_GetArrayLong($h_i; "longs"; 5)=500)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GET top-level elements 1 and 5"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- PUT — top-level array, round-trip
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayLong($h_i; "longs"; 2; 999)
	$result_i:=OTr_GetArrayLong($h_i; "longs"; 2)
	If ($result_i=999)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PUT top-level round-trip: expected 999, got "+String:C10($result_i)+" OK="+String:C10(OK)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- PUT — adjacent elements undisturbed
	// ====================================================

	$total_i:=$total_i+1
	If (OTr_GetArrayLong($h_i; "longs"; 1)=100) & (OTr_GetArrayLong($h_i; "longs"; 3)=300)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PUT — adjacent elements disturbed"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- GET — sub-object array via dotted path
	// ====================================================

	$total_i:=$total_i+1
	$result_i:=OTr_GetArrayLong($h_i; "sub.vals"; 2)
	If ($result_i=22)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GET sub-object element 2 expected 22, got "+String:C10($result_i)+" OK="+String:C10(OK)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- PUT — sub-object array via dotted path
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayLong($h_i; "sub.vals"; 1; 777)
	$result_i:=OTr_GetArrayLong($h_i; "sub.vals"; 1)
	If ($result_i=777)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PUT sub-object round-trip: expected 777, got "+String:C10($result_i)+" OK="+String:C10(OK)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- OK unchanged on successful GET
	// ====================================================

	$total_i:=$total_i+1
	$savedOK_i:=OK
	OTr_GetArrayLong($h_i; "longs"; 1)
	If (OK=$savedOK_i)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OK should be unchanged after successful GET"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- ERROR — invalid handle
	// ====================================================

	$total_i:=$total_i+1
	OTr_GetArrayLong(9999; "longs"; 1)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GET invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	OTr_PutArrayLong(9999; "longs"; 1; 42)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PUT invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- ERROR — missing tag
	// ====================================================

	$total_i:=$total_i+1
	OTr_GetArrayLong($h_i; "nosucharray"; 1)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GET missing tag should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- ERROR — type mismatch (tag exists but is wrong type)
	// ====================================================

	// "reals" is a Real array — addressing it as LongInt should fail
	$total_i:=$total_i+1
	OTr_GetArrayLong($h_i; "reals"; 1)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GET type mismatch should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	OTr_PutArrayLong($h_i; "reals"; 1; 42)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PUT type mismatch should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- ERROR — index out of range
	// ====================================================

	$total_i:=$total_i+1
	OTr_GetArrayLong($h_i; "longs"; 999)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GET out-of-range index should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	OTr_PutArrayLong($h_i; "longs"; 999; 42)
	If (OK=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PUT out-of-range index should set OK=0"+Char:C90(Carriage return:K15:38)
	End if 

	OTr_SaveToClipboard($h_i)


	// ====================================================
	//MARK:- REAL — Get element
	// ====================================================

	$total_i:=$total_i+1
	$result_r:=OTr_GetArrayReal($h_i; "reals"; 2)
	If ($result_r=2.2)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetArrayReal_New: expected 2.2, got "+String:C10($result_r)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- REAL — Put/Get round-trip
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayReal($h_i; "reals"; 1; 9.9)
	$result_r:=OTr_GetArrayReal($h_i; "reals"; 1)
	If ($result_r=9.9)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutArrayReal_New round-trip: expected 9.9, got "+String:C10($result_r)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- STRING — Get element
	// ====================================================

	$total_i:=$total_i+1
	$result_t:=OTr_GetArrayString($h_i; "words"; 1)
	If ($result_t="alpha")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetArrayString_New: expected 'alpha', got '"+$result_t+"'"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- STRING — Put/Get round-trip
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayString($h_i; "words"; 2; "UPDATED")
	$result_t:=OTr_GetArrayString($h_i; "words"; 2)
	If ($result_t="UPDATED")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutArrayString_New round-trip: expected 'UPDATED', got '"+$result_t+"'"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- TEXT (alias) — Get via OTr_GetArrayText_New
	// ====================================================

	$total_i:=$total_i+1
	$result_t:=OTr_GetArrayText($h_i; "words"; 3)
	If ($result_t="gamma")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetArrayText_New: expected 'gamma', got '"+$result_t+"'"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- TEXT (alias) — Put via OTr_PutArrayText_New
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayText($h_i; "words"; 3; "TEXTALIAS")
	$result_t:=OTr_GetArrayText($h_i; "words"; 3)
	If ($result_t="TEXTALIAS")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutArrayText_New round-trip: expected 'TEXTALIAS', got '"+$result_t+"'"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- DATE — Get element
	// ====================================================

	$total_i:=$total_i+1
	$result_d:=OTr_GetArrayDate($h_i; "dates"; 2)
	If ($result_d=!2026-06-15!)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetArrayDate_New: expected !2026-06-15!, got "+String:C10($result_d)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- DATE — Put/Get round-trip
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayDate($h_i; "dates"; 1; !2000-07-04!)
	$result_d:=OTr_GetArrayDate($h_i; "dates"; 1)
	If ($result_d=!2000-07-04!)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutArrayDate_New round-trip: expected !2000-07-04!, got "+String:C10($result_d)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- TIME — Get element
	// ====================================================

	$total_i:=$total_i+1
	$result_h:=OTr_GetArrayTime($h_i; "times"; 1)
	If ($result_h=?08:00:00?)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetArrayTime_New: expected ?08:00:00?, got "+String:C10($result_h)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- TIME — Put/Get round-trip
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayTime($h_i; "times"; 3; ?14:45:00?)
	$result_h:=OTr_GetArrayTime($h_i; "times"; 3)
	If ($result_h=?14:45:00?)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutArrayTime_New round-trip: expected ?14:45:00?, got "+String:C10($result_h)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- BOOLEAN — Get element (True → 1)
	// ====================================================

	$total_i:=$total_i+1
	$result_i:=OTr_GetArrayBoolean($h_i; "flags"; 1)
	If ($result_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetArrayBoolean_New: expected 1 (True), got "+String:C10($result_i)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- BOOLEAN — Get element (False → 0)
	// ====================================================

	$total_i:=$total_i+1
	$result_i:=OTr_GetArrayBoolean($h_i; "flags"; 2)
	If ($result_i=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetArrayBoolean_New: expected 0 (False), got "+String:C10($result_i)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- BOOLEAN — Put/Get round-trip
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayBoolean($h_i; "flags"; 2; True:C214)
	$result_i:=OTr_GetArrayBoolean($h_i; "flags"; 2)
	If ($result_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutArrayBoolean_New round-trip: expected 1, got "+String:C10($result_i)+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- BLOB — Put/Get round-trip via OTr_uEqualBLOBs
	// ====================================================

	TEXT TO BLOB:C554("compare me"; $testBlob_blob)
	OTr_PutArrayBLOB($h_i; "blobs"; 1; $testBlob_blob)

	$total_i:=$total_i+1
	$result_blob:=OTr_GetArrayBLOB($h_i; "blobs"; 1)
	If (OTr_uEqualBLOBs($result_blob; $testBlob_blob))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutArrayBLOB_New/GetArrayBLOB_New round-trip mismatch"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- PICTURE — Get existing element
	// ====================================================

	$total_i:=$total_i+1
	$result_pic:=OTr_GetArrayPicture($h_i; "pics"; 1)
	If (OTr_uEqualPictures($result_pic; $testWombat_pic))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetArrayPicture_New: picture mismatch"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- PICTURE — Put/Get round-trip
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayPicture($h_i; "pics"; 2; $testWombat_pic)
	$result_pic:=OTr_GetArrayPicture($h_i; "pics"; 2)
	If (OTr_uEqualPictures($result_pic; $testWombat_pic))
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutArrayPicture_New round-trip: picture mismatch"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- POINTER — Get existing element
	// ====================================================

	$total_i:=$total_i+1
	$result_ptr:=OTr_GetArrayPointer($h_i; "ptrs"; 1)
	If ($result_ptr->=vtCC_Filename)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetArrayPointer_New: dereference mismatch"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- POINTER — Put/Get round-trip
	// ====================================================

	$total_i:=$total_i+1
	OTr_PutArrayPointer($h_i; "ptrs"; 2; ->vtCC_Filename)
	$result_ptr:=OTr_GetArrayPointer($h_i; "ptrs"; 2)
	If ($result_ptr->=vtCC_Filename)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"PutArrayPointer_New round-trip: dereference mismatch"+Char:C90(Carriage return:K15:38)
	End if 

	// ====================================================
	//MARK:- SUMMARY
	// ====================================================

	OTr_SaveToClipboard($h_i)


	OTr_ClearAll

	var $summary_t : Text
	$summary_t:="Phase 8 Tests"+Char:C90(Carriage return:K15:38)
	$summary_t:=$summary_t+"Total:  "+String:C10($total_i)+Char:C90(Carriage return:K15:38)
	$summary_t:=$summary_t+"Passed: "+String:C10($passed_i)+Char:C90(Carriage return:K15:38)
	$summary_t:=$summary_t+"Failed: "+String:C10($failed_i)

	If ($failed_i>0)
		$summary_t:=$summary_t+Char:C90(Carriage return:K15:38)+Char:C90(Carriage return:K15:38)+"Failures:"+Char:C90(Carriage return:K15:38)+$failures_t
	End if 

	ALERT:C41($summary_t)
	SET TEXT TO PASTEBOARD:C523($summary_t)
Else 
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 
