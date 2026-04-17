//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_10c_OT ($accum_i)
//
// Executes the OT half of the Phase 10c comprehensive
// OK=0 test suite.
//
// Runs 120 scenarios in exactly the same order as
// ____Test_Phase_10c_OTr and writes otCmd / otResult
// by sequential index into the shared accumulator.
//
// PLATFORM NOTE:
// The ObjectTools plugin is not available on all
// platforms. If OT New returns 0, all OT columns are
// marked "Skip: plugin not available" and the method
// returns without running any scenario.
//
// To build on a platform without the plugin, comment
// out the entire body below the #DECLARE line
// (from "// ==== BEGIN OT BLOCK" to the end).
//
// Access: Private
// Returns: Nothing
//
// Created by Wayne Stewart / Claude, 2026-04-10
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($accum_i : Integer)

// ==== BEGIN OT BLOCK — comment out on Tahoe 26.4+ ====
/*

var $h_i : Integer
var $r_i : Integer
var $r_r : Real
var $r_b : Integer
var $r_d : Date
var $r_h : Time
var $r_t : Text
var $r_ptr : Pointer
var $r_pic : Picture
var $r_blob : Blob
var $badBlob_blob : Blob
var $ioBLOB_blob : Blob
var $varLong_i : Integer
var $varText_t : Text
var $reg_i : Integer
var $ready_b : Boolean
var $count_i : Integer
var $n_i : Integer
var $otCmd_t : Text
var $otResult_t : Text

// Process variable required for OT GetArray (OT plugin limitation)
ARRAY LONGINT(OTr_LongArrayForTests_ai; 0)

// ====================================================
// PLUGIN AVAILABILITY CHECK
// ====================================================
$ready_b:=True
$reg_i:=OT Register(Storage.OTr.registrationCode)
$h_i:=OT New

If ($h_i=0)
	ALERT("ObjectTools 5.0 is not available or not registered."+Char(Carriage return)+"OT columns will be marked as skipped.")
	$ready_b:=False
	$count_i:=OTr_SizeOfArray($accum_i; "testName")
	For ($n_i; 1; $count_i)
		OTr_PutArrayText($accum_i; "otCmd"; $n_i; "Plugin not available")
		OTr_PutArrayText($accum_i; "otResult"; $n_i; "Skip: plugin not available")
	End for 
Else 
	OT Clear($h_i)
End if 

If ($ready_b)
	
	// ====================================================
	// SEED OBJECT — identical layout to ____Test_Phase_10c_OTr:
	//   "scalar"   : Long = 123
	//   "textItem" : Text = "abc"
	//   "longArr"  : Array Long [10, 20, 30]
	//   "textArr"  : Array Text ["x", "y"]
	// ====================================================
	$h_i:=OT New
	OT PutLong($h_i; "scalar"; 123)
	OT PutString($h_i; "textItem"; "abc")
	
	ARRAY LONGINT($longArr_ai; 3)
	$longArr_ai{1}:=10
	$longArr_ai{2}:=20
	$longArr_ai{3}:=30
	OT PutArray($h_i; "longArr"; $longArr_ai)
	
	ARRAY TEXT($textArr_at; 2)
	$textArr_at{1}:="x"
	$textArr_at{2}:="y"
	OT PutArray($h_i; "textArr"; $textArr_at)
	
	$n_i:=0
	
	// ====================================================
	//MARK:- OT Copy
	// ====================================================
	
	// 1. OT Copy — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT Copy(99999)
	$otCmd_t:="OT Copy(99999)"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArray
	// ====================================================
	
	// 2. OT PutArray — invalid handle
	$n_i:=$n_i+1
	OT PutArray(99999; "arr"; $longArr_ai)
	$otCmd_t:="OT PutArray(99999; \"arr\"; $longArr_ai)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 3. OT PutArray — type mismatch (scalar is Long, not array)
	$n_i:=$n_i+1
	OT PutArray($h_i; "scalar"; $longArr_ai)
	$otCmd_t:="OT PutArray($h_i; \"scalar\"; $longArr_ai)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayBLOB
	// ====================================================
	
	// 4. OT PutArrayBLOB — invalid handle
	$n_i:=$n_i+1
	OT PutArrayBLOB(99999; "longArr"; 1; $r_blob)
	$otCmd_t:="OT PutArrayBLOB(99999; \"longArr\"; 1; $r_blob)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 5. OT PutArrayBLOB — index out of range
	$n_i:=$n_i+1
	OT PutArrayBLOB($h_i; "longArr"; 99; $r_blob)
	$otCmd_t:="OT PutArrayBLOB($h_i; \"longArr\"; 99; $r_blob)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayBoolean
	// ====================================================
	
	// 6. OT PutArrayBoolean — invalid handle
	$n_i:=$n_i+1
	OT PutArrayBoolean(99999; "longArr"; 1; 1)
	$otCmd_t:="OT PutArrayBoolean(99999; \"longArr\"; 1; 1)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 7. OT PutArrayBoolean — type mismatch (longArr is Long array, not Boolean)
	$n_i:=$n_i+1
	OT PutArrayBoolean($h_i; "longArr"; 1; 1)
	$otCmd_t:="OT PutArrayBoolean($h_i; \"longArr\"; 1; 1)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayDate
	// ====================================================
	
	// 8. OT PutArrayDate — invalid handle
	$n_i:=$n_i+1
	OT PutArrayDate(99999; "longArr"; 1; !2026-01-01!)
	$otCmd_t:="OT PutArrayDate(99999; \"longArr\"; 1; !2026-01-01!)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 9. OT PutArrayDate — type mismatch
	$n_i:=$n_i+1
	OT PutArrayDate($h_i; "longArr"; 1; !2026-01-01!)
	$otCmd_t:="OT PutArrayDate($h_i; \"longArr\"; 1; !2026-01-01!)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayLong
	// ====================================================
	
	// 10. OT PutArrayLong — invalid handle
	$n_i:=$n_i+1
	OT PutArrayLong(99999; "longArr"; 1; 777)
	$otCmd_t:="OT PutArrayLong(99999; \"longArr\"; 1; 777)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 11. OT PutArrayLong — type mismatch (textArr is Text array, not Long)
	$n_i:=$n_i+1
	OT PutArrayLong($h_i; "textArr"; 1; 777)
	$otCmd_t:="OT PutArrayLong($h_i; \"textArr\"; 1; 777)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayPicture
	// ====================================================
	
	// 12. OT PutArrayPicture — invalid handle
	$n_i:=$n_i+1
	OT PutArrayPicture(99999; "longArr"; 1; $r_pic)
	$otCmd_t:="OT PutArrayPicture(99999; \"longArr\"; 1; <picture>)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 13. OT PutArrayPicture — type mismatch
	$n_i:=$n_i+1
	OT PutArrayPicture($h_i; "longArr"; 1; $r_pic)
	$otCmd_t:="OT PutArrayPicture($h_i; \"longArr\"; 1; <picture>)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayPointer
	// ====================================================
	
	// 14. OT PutArrayPointer — invalid handle
	$n_i:=$n_i+1
	OT PutArrayPointer(99999; "longArr"; 1; ->$r_i)
	$otCmd_t:="OT PutArrayPointer(99999; \"longArr\"; 1; ->$r_i)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 15. OT PutArrayPointer — type mismatch
	$n_i:=$n_i+1
	OT PutArrayPointer($h_i; "longArr"; 1; ->$r_i)
	$otCmd_t:="OT PutArrayPointer($h_i; \"longArr\"; 1; ->$r_i)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayReal
	// ====================================================
	
	// 16. OT PutArrayReal — invalid handle
	$n_i:=$n_i+1
	OT PutArrayReal(99999; "longArr"; 1; 3.14)
	$otCmd_t:="OT PutArrayReal(99999; \"longArr\"; 1; 3.14)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 17. OT PutArrayReal — type mismatch (textArr is Text, not Real)
	$n_i:=$n_i+1
	OT PutArrayReal($h_i; "textArr"; 1; 3.14)
	$otCmd_t:="OT PutArrayReal($h_i; \"textArr\"; 1; 3.14)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayString
	// ====================================================
	
	// 18. OT PutArrayString — invalid handle
	$n_i:=$n_i+1
	OT PutArrayString(99999; "textArr"; 1; "z")
	$otCmd_t:="OT PutArrayString(99999; \"textArr\"; 1; \"z\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 19. OT PutArrayString — type mismatch (longArr is Long, not String)
	$n_i:=$n_i+1
	OT PutArrayString($h_i; "longArr"; 1; "z")
	$otCmd_t:="OT PutArrayString($h_i; \"longArr\"; 1; \"z\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayText
	// ====================================================
	
	// 20. OT PutArrayText — invalid handle
	$n_i:=$n_i+1
	OT PutArrayText(99999; "textArr"; 1; "z")
	$otCmd_t:="OT PutArrayText(99999; \"textArr\"; 1; \"z\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 21. OT PutArrayText — type mismatch
	$n_i:=$n_i+1
	OT PutArrayText($h_i; "longArr"; 1; "z")
	$otCmd_t:="OT PutArrayText($h_i; \"longArr\"; 1; \"z\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutArrayTime
	// ====================================================
	
	// 22. OT PutArrayTime — invalid handle
	$n_i:=$n_i+1
	OT PutArrayTime(99999; "longArr"; 1; ?10:00:00?)
	$otCmd_t:="OT PutArrayTime(99999; \"longArr\"; 1; ?10:00:00?)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 23. OT PutArrayTime — type mismatch (textArr is Text, not Time)
	$n_i:=$n_i+1
	OT PutArrayTime($h_i; "textArr"; 1; ?10:00:00?)
	$otCmd_t:="OT PutArrayTime($h_i; \"textArr\"; 1; ?10:00:00?)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutBLOB
	// ====================================================
	
	// 24. OT PutBLOB — invalid handle
	$n_i:=$n_i+1
	OT PutBLOB(99999; "tag"; $r_blob)
	$otCmd_t:="OT PutBLOB(99999; \"tag\"; $r_blob)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 25. OT PutBLOB — type mismatch (scalar is Long, not BLOB)
	$n_i:=$n_i+1
	OT PutBLOB($h_i; "scalar"; $r_blob)
	$otCmd_t:="OT PutBLOB($h_i; \"scalar\"; $r_blob)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutBoolean
	// ====================================================
	
	// 26. OT PutBoolean — invalid handle
	$n_i:=$n_i+1
	OT PutBoolean(99999; "tag"; 1)
	$otCmd_t:="OT PutBoolean(99999; \"tag\"; 1)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 27. OT PutBoolean — type mismatch
	$n_i:=$n_i+1
	OT PutBoolean($h_i; "scalar"; 1)
	$otCmd_t:="OT PutBoolean($h_i; \"scalar\"; 1)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutDate
	// ====================================================
	
	// 28. OT PutDate — invalid handle
	$n_i:=$n_i+1
	OT PutDate(99999; "tag"; !2026-01-01!)
	$otCmd_t:="OT PutDate(99999; \"tag\"; !2026-01-01!)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 29. OT PutDate — type mismatch
	$n_i:=$n_i+1
	OT PutDate($h_i; "scalar"; !2026-01-01!)
	$otCmd_t:="OT PutDate($h_i; \"scalar\"; !2026-01-01!)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutLong
	// ====================================================
	
	// 30. OT PutLong — invalid handle
	$n_i:=$n_i+1
	OT PutLong(99999; "tag"; 42)
	$otCmd_t:="OT PutLong(99999; \"tag\"; 42)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 31. OT PutLong — type mismatch (textItem is Text, not Long)
	$n_i:=$n_i+1
	OT PutLong($h_i; "textItem"; 42)
	$otCmd_t:="OT PutLong($h_i; \"textItem\"; 42)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutPointer
	// ====================================================
	
	// 32. OT PutPointer — invalid handle
	$n_i:=$n_i+1
	OT PutPointer(99999; "tag"; ->$r_i)
	$otCmd_t:="OT PutPointer(99999; \"tag\"; ->$r_i)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 33. OT PutPointer — type mismatch
	$n_i:=$n_i+1
	OT PutPointer($h_i; "scalar"; ->$r_i)
	$otCmd_t:="OT PutPointer($h_i; \"scalar\"; ->$r_i)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutReal
	// ====================================================
	
	// 34. OT PutReal — invalid handle
	$n_i:=$n_i+1
	OT PutReal(99999; "tag"; 3.14)
	$otCmd_t:="OT PutReal(99999; \"tag\"; 3.14)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 35. OT PutReal — type mismatch (textItem is Text, not Real)
	$n_i:=$n_i+1
	OT PutReal($h_i; "textItem"; 3.14)
	$otCmd_t:="OT PutReal($h_i; \"textItem\"; 3.14)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutString
	// ====================================================
	
	// 36. OT PutString — invalid handle
	$n_i:=$n_i+1
	OT PutString(99999; "tag"; "val")
	$otCmd_t:="OT PutString(99999; \"tag\"; \"val\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 37. OT PutString — type mismatch (scalar is Long, not String)
	$n_i:=$n_i+1
	OT PutString($h_i; "scalar"; "val")
	$otCmd_t:="OT PutString($h_i; \"scalar\"; \"val\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutText
	// ====================================================
	
	// 38. OT PutText — invalid handle
	$n_i:=$n_i+1
	OT PutText(99999; "tag"; "val")
	$otCmd_t:="OT PutText(99999; \"tag\"; \"val\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 39. OT PutText — type mismatch
	$n_i:=$n_i+1
	OT PutText($h_i; "scalar"; "val")
	$otCmd_t:="OT PutText($h_i; \"scalar\"; \"val\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutTime
	// ====================================================
	
	// 40. OT PutTime — invalid handle
	$n_i:=$n_i+1
	OT PutTime(99999; "tag"; ?10:00:00?)
	$otCmd_t:="OT PutTime(99999; \"tag\"; ?10:00:00?)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 41. OT PutTime — type mismatch
	$n_i:=$n_i+1
	OT PutTime($h_i; "scalar"; ?10:00:00?)
	$otCmd_t:="OT PutTime($h_i; \"scalar\"; ?10:00:00?)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT PutVariable / OT GetVariable
	// ====================================================
	
	// 42. OT PutVariable — invalid handle
	$n_i:=$n_i+1
	$varLong_i:=42
	OT PutVariable(99999; "tag"; ->$varLong_i)
	$otCmd_t:="OT PutVariable(99999; \"tag\"; ->$varLong_i)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 43. OT GetVariable — type mismatch (stored as Long, retrieved as Text)
	$n_i:=$n_i+1
	$varLong_i:=123
	OT PutVariable($h_i; "varMixed"; ->$varLong_i)
	$varText_t:=""
	OT GetVariable($h_i; "varMixed"; ->$varText_t)
	$otCmd_t:="OT PutVariable Long / OT GetVariable into Text"
	$otResult_t:="text=\""+$varText_t+"\" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArray
	// ====================================================
	
	// 44. OT GetArray — invalid handle
	$n_i:=$n_i+1
	OT GetArray(99999; "longArr"; OTr_LongArrayForTests_ai)
	$otCmd_t:="OT GetArray(99999; \"longArr\"; outOtArr_ai)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 45. OT GetArray — type mismatch (scalar is not an array)
	$n_i:=$n_i+1
	OT GetArray($h_i; "scalar"; OTr_LongArrayForTests_ai)
	$otCmd_t:="OT GetArray($h_i; \"scalar\"; outOtArr_ai)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayBLOB
	// ====================================================
	
	// 46. OT GetArrayBLOB — invalid handle
	$n_i:=$n_i+1
	$r_blob:=OT GetArrayBLOB(99999; "longArr"; 1)
	$otCmd_t:="OT GetArrayBLOB(99999; \"longArr\"; 1)"
	$otResult_t:="blobSize="+String(BLOB size($r_blob))+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 47. OT GetArrayBLOB — type mismatch (textArr is Text, not BLOB)
	$n_i:=$n_i+1
	$r_blob:=OT GetArrayBLOB($h_i; "textArr"; 1)
	$otCmd_t:="OT GetArrayBLOB($h_i; \"textArr\"; 1)"
	$otResult_t:="blobSize="+String(BLOB size($r_blob))+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayBoolean
	// ====================================================
	
	// 48. OT GetArrayBoolean — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT GetArrayBoolean(99999; "longArr"; 1)
	$otCmd_t:="OT GetArrayBoolean(99999; \"longArr\"; 1)"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 49. OT GetArrayBoolean — index out of range
	$n_i:=$n_i+1
	$r_i:=OT GetArrayBoolean($h_i; "longArr"; 99)
	$otCmd_t:="OT GetArrayBoolean($h_i; \"longArr\"; 99)"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayDate
	// ====================================================
	
	// 50. OT GetArrayDate — invalid handle
	$n_i:=$n_i+1
	$r_d:=OT GetArrayDate(99999; "longArr"; 1)
	$otCmd_t:="OT GetArrayDate(99999; \"longArr\"; 1)"
	$otResult_t:="returned "+String($r_d)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 51. OT GetArrayDate — type mismatch
	$n_i:=$n_i+1
	$r_d:=OT GetArrayDate($h_i; "longArr"; 1)
	$otCmd_t:="OT GetArrayDate($h_i; \"longArr\"; 1)"
	$otResult_t:="returned "+String($r_d)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayLong
	// ====================================================
	
	// 52. OT GetArrayLong — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT GetArrayLong(99999; "longArr"; 1)
	$otCmd_t:="OT GetArrayLong(99999; \"longArr\"; 1)"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 53. OT GetArrayLong — index out of range
	$n_i:=$n_i+1
	$r_i:=OT GetArrayLong($h_i; "longArr"; 99)
	$otCmd_t:="OT GetArrayLong($h_i; \"longArr\"; 99)"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayPicture
	// ====================================================
	
	// 54. OT GetArrayPicture — invalid handle
	$n_i:=$n_i+1
	$r_pic:=OT GetArrayPicture(99999; "longArr"; 1)
	$otCmd_t:="OT GetArrayPicture(99999; \"longArr\"; 1)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 55. OT GetArrayPicture — type mismatch
	$n_i:=$n_i+1
	$r_pic:=OT GetArrayPicture($h_i; "longArr"; 1)
	$otCmd_t:="OT GetArrayPicture($h_i; \"longArr\"; 1)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayPointer
	// ====================================================
	
	// 56. OT GetArrayPointer — invalid handle
	$n_i:=$n_i+1
	$r_ptr:=Null
	OT GetArrayPointer(99999; "longArr"; 1; $r_ptr)
	$otCmd_t:="OT GetArrayPointer(99999; \"longArr\"; 1; $r_ptr)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 57. OT GetArrayPointer — type mismatch
	$n_i:=$n_i+1
	$r_ptr:=Null
	OT GetArrayPointer($h_i; "longArr"; 1; $r_ptr)
	$otCmd_t:="OT GetArrayPointer($h_i; \"longArr\"; 1; $r_ptr)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayReal
	// ====================================================
	
	// 58. OT GetArrayReal — invalid handle
	$n_i:=$n_i+1
	$r_r:=OT GetArrayReal(99999; "longArr"; 1)
	$otCmd_t:="OT GetArrayReal(99999; \"longArr\"; 1)"
	$otResult_t:="returned "+String($r_r)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 59. OT GetArrayReal — type mismatch (textArr is Text, not Real)
	$n_i:=$n_i+1
	$r_r:=OT GetArrayReal($h_i; "textArr"; 1)
	$otCmd_t:="OT GetArrayReal($h_i; \"textArr\"; 1)"
	$otResult_t:="returned "+String($r_r)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayString
	// ====================================================
	
	// 60. OT GetArrayString — invalid handle
	$n_i:=$n_i+1
	$r_t:=OT GetArrayString(99999; "textArr"; 1)
	$otCmd_t:="OT GetArrayString(99999; \"textArr\"; 1)"
	$otResult_t:="returned \""+$r_t+"\" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 61. OT GetArrayString — type mismatch (longArr is Long, not String)
	$n_i:=$n_i+1
	$r_t:=OT GetArrayString($h_i; "longArr"; 1)
	$otCmd_t:="OT GetArrayString($h_i; \"longArr\"; 1)"
	$otResult_t:="returned \""+$r_t+"\" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayText
	// ====================================================
	
	// 62. OT GetArrayText — invalid handle
	$n_i:=$n_i+1
	$r_t:=OT GetArrayText(99999; "textArr"; 1)
	$otCmd_t:="OT GetArrayText(99999; \"textArr\"; 1)"
	$otResult_t:="returned \""+$r_t+"\" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 63. OT GetArrayText — type mismatch (longArr is Long, not Text)
	$n_i:=$n_i+1
	$r_t:=OT GetArrayText($h_i; "longArr"; 1)
	$otCmd_t:="OT GetArrayText($h_i; \"longArr\"; 1)"
	$otResult_t:="returned \""+$r_t+"\" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetArrayTime
	// ====================================================
	
	// 64. OT GetArrayTime — invalid handle
	$n_i:=$n_i+1
	$r_h:=OT GetArrayTime(99999; "longArr"; 1)
	$otCmd_t:="OT GetArrayTime(99999; \"longArr\"; 1)"
	$otResult_t:="returned "+String($r_h)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 65. OT GetArrayTime — type mismatch
	$n_i:=$n_i+1
	$r_h:=OT GetArrayTime($h_i; "longArr"; 1)
	$otCmd_t:="OT GetArrayTime($h_i; \"longArr\"; 1)"
	$otResult_t:="returned "+String($r_h)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetBLOB
	// ====================================================
	
	// 66. OT GetBLOB — invalid handle
	$n_i:=$n_i+1
	OT GetBLOB(99999; "scalar"; $r_blob)
	$otCmd_t:="OT GetBLOB(99999; \"scalar\"; $r_blob)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 67. OT GetBLOB — type mismatch (scalar is Long, not BLOB)
	$n_i:=$n_i+1
	OT GetBLOB($h_i; "scalar"; $r_blob)
	$otCmd_t:="OT GetBLOB($h_i; \"scalar\"; $r_blob)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetBoolean
	// ====================================================
	
	// 68. OT GetBoolean — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT GetBoolean(99999; "scalar")
	$otCmd_t:="OT GetBoolean(99999; \"scalar\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 69. OT GetBoolean — type mismatch (textItem is Text, not Boolean)
	$n_i:=$n_i+1
	$r_i:=OT GetBoolean($h_i; "textItem")
	$otCmd_t:="OT GetBoolean($h_i; \"textItem\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetDate
	// ====================================================
	
	// 70. OT GetDate — invalid handle
	$n_i:=$n_i+1
	$r_d:=OT GetDate(99999; "scalar")
	$otCmd_t:="OT GetDate(99999; \"scalar\")"
	$otResult_t:="returned "+String($r_d)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 71. OT GetDate — type mismatch (scalar is Long, not Date)
	$n_i:=$n_i+1
	$r_d:=OT GetDate($h_i; "scalar")
	$otCmd_t:="OT GetDate($h_i; \"scalar\")"
	$otResult_t:="returned "+String($r_d)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetLong
	// ====================================================
	
	// 72. OT GetLong — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT GetLong(99999; "scalar")
	$otCmd_t:="OT GetLong(99999; \"scalar\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 73. OT GetLong — missing tag
	$n_i:=$n_i+1
	$r_i:=OT GetLong($h_i; "doesNotExist")
	$otCmd_t:="OT GetLong($h_i; \"doesNotExist\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 74. OT GetLong — type mismatch (textItem is Text, not Long)
	$n_i:=$n_i+1
	$r_i:=OT GetLong($h_i; "textItem")
	$otCmd_t:="OT GetLong($h_i; \"textItem\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetNewBLOB
	// ====================================================
	
	// 75. OT GetNewBLOB — invalid handle
	$n_i:=$n_i+1
	$r_blob:=OT GetNewBLOB(99999; "scalar")
	$otCmd_t:="OT GetNewBLOB(99999; \"scalar\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 76. OT GetNewBLOB — type mismatch (scalar is Long, not BLOB)
	$n_i:=$n_i+1
	$r_blob:=OT GetNewBLOB($h_i; "scalar")
	$otCmd_t:="OT GetNewBLOB($h_i; \"scalar\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetObject
	// ====================================================
	
	// 77. OT GetObject — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT GetObject(99999; "scalar")
	$otCmd_t:="OT GetObject(99999; \"scalar\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 78. OT GetObject — type mismatch (scalar is Long, not Object)
	$n_i:=$n_i+1
	$r_i:=OT GetObject($h_i; "scalar")
	$otCmd_t:="OT GetObject($h_i; \"scalar\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetPicture
	// ====================================================
	
	// 79. OT GetPicture — invalid handle
	$n_i:=$n_i+1
	$r_pic:=OT GetPicture(99999; "scalar")
	$otCmd_t:="OT GetPicture(99999; \"scalar\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 80. OT GetPicture — type mismatch
	$n_i:=$n_i+1
	$r_pic:=OT GetPicture($h_i; "scalar")
	$otCmd_t:="OT GetPicture($h_i; \"scalar\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetPointer
	// ====================================================
	
	// 81. OT GetPointer — invalid handle
	$n_i:=$n_i+1
	$r_ptr:=Null
	OT GetPointer(99999; "scalar"; $r_ptr)
	$otCmd_t:="OT GetPointer(99999; \"scalar\"; $r_ptr)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 82. OT GetPointer — missing tag
	$n_i:=$n_i+1
	$r_ptr:=Null
	OT GetPointer($h_i; "missingPtr"; $r_ptr)
	$otCmd_t:="OT GetPointer($h_i; \"missingPtr\"; $r_ptr)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 83. OT GetPointer — type mismatch (scalar is Long, not Pointer)
	$n_i:=$n_i+1
	$r_ptr:=Null
	OT GetPointer($h_i; "scalar"; $r_ptr)
	$otCmd_t:="OT GetPointer($h_i; \"scalar\"; $r_ptr)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetReal
	// ====================================================
	
	// 84. OT GetReal — invalid handle
	$n_i:=$n_i+1
	$r_r:=OT GetReal(99999; "scalar")
	$otCmd_t:="OT GetReal(99999; \"scalar\")"
	$otResult_t:="returned "+String($r_r)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 85. OT GetReal — type mismatch (textItem is Text, not Real)
	$n_i:=$n_i+1
	$r_r:=OT GetReal($h_i; "textItem")
	$otCmd_t:="OT GetReal($h_i; \"textItem\")"
	$otResult_t:="returned "+String($r_r)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetString
	// ====================================================
	
	// 86. OT GetString — invalid handle
	$n_i:=$n_i+1
	$r_t:=OT GetString(99999; "textItem")
	$otCmd_t:="OT GetString(99999; \"textItem\")"
	$otResult_t:="returned \""+$r_t+"\" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ----------------------------------------------------
	// Refresh: restore known initial state before getter
	// type-mismatch tests — prior scenarios have mutated
	// $h_i through multiple type-changing Put calls.
	// ----------------------------------------------------
	OT Clear($h_i)
	$h_i:=OT New
	OT PutLong($h_i; "scalar"; 123)
	OT PutString($h_i; "textItem"; "abc")
	ARRAY LONGINT($longArr_ai; 3)
	$longArr_ai{1}:=10
	$longArr_ai{2}:=20
	$longArr_ai{3}:=30
	OT PutArray($h_i; "longArr"; $longArr_ai)
	ARRAY TEXT($textArr_at; 2)
	$textArr_at{1}:="x"
	$textArr_at{2}:="y"
	OT PutArray($h_i; "textArr"; $textArr_at)
	
	// 87. OT GetString — type mismatch (scalar is Long, not String)
	$n_i:=$n_i+1
	$r_t:=OT GetString($h_i; "scalar")
	$otCmd_t:="OT GetString($h_i; \"scalar\")"
	$otResult_t:="returned \""+$r_t+"\" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetText
	// ====================================================
	
	// 88. OT GetText — invalid handle
	$n_i:=$n_i+1
	$r_t:=OT GetText(99999; "textItem")
	$otCmd_t:="OT GetText(99999; \"textItem\")"
	$otResult_t:="returned \""+$r_t+"\" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 89. OT GetText — type mismatch (scalar is Long, not Text)
	$n_i:=$n_i+1
	$r_t:=OT GetText($h_i; "scalar")
	$otCmd_t:="OT GetText($h_i; \"scalar\")"
	$otResult_t:="returned \""+$r_t+"\" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- OT GetTime
	// ====================================================
	
	// 90. OT GetTime — invalid handle
	$n_i:=$n_i+1
	$r_h:=OT GetTime(99999; "scalar")
	$otCmd_t:="OT GetTime(99999; \"scalar\")"
	$otResult_t:="returned "+String($r_h)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 91. OT GetTime — type mismatch (scalar is Long, not Time)
	$n_i:=$n_i+1
	$r_h:=OT GetTime($h_i; "scalar")
	$otCmd_t:="OT GetTime($h_i; \"scalar\")"
	$otResult_t:="returned "+String($r_h)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- Array element utilities
	// ====================================================
	
	// 92. OT DeleteElement — invalid handle
	$n_i:=$n_i+1
	OT DeleteElement(99999; "longArr"; 1)
	$otCmd_t:="OT DeleteElement(99999; \"longArr\"; 1)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 93. OT DeleteElement — type mismatch (scalar is not array)
	$n_i:=$n_i+1
	OT DeleteElement($h_i; "scalar"; 1)
	$otCmd_t:="OT DeleteElement($h_i; \"scalar\"; 1)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 94. OT FindInArray — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT FindInArray(99999; "longArr"; "10")
	$otCmd_t:="OT FindInArray(99999; \"longArr\"; \"10\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 95. OT InsertElement — invalid handle
	$n_i:=$n_i+1
	OT InsertElement(99999; "longArr"; 1)
	$otCmd_t:="OT InsertElement(99999; \"longArr\"; 1)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 96. OT ResizeArray — invalid handle
	$n_i:=$n_i+1
	OT ResizeArray(99999; "longArr"; 5)
	$otCmd_t:="OT ResizeArray(99999; \"longArr\"; 5)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 97. OT SizeOfArray — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT SizeOfArray(99999; "longArr")
	$otCmd_t:="OT SizeOfArray(99999; \"longArr\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 98. OT SizeOfArray — missing tag
	$n_i:=$n_i+1
	$r_i:=OT SizeOfArray($h_i; "missingArray")
	$otCmd_t:="OT SizeOfArray($h_i; \"missingArray\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 99. OT SortArrays — invalid handle
	$n_i:=$n_i+1
	OT SortArrays(99999; "longArr"; ">"; ""; ""; ""; ""; ""; ""; ""; ""; ""; "")
	$otCmd_t:="OT SortArrays(99999; \"longArr\"; \">\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- Object info utilities
	// ====================================================
	
	// 100. OT ItemCount — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT ItemCount(99999)
	$otCmd_t:="OT ItemCount(99999)"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 101. OT ObjectSize — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT ObjectSize(99999)
	$otCmd_t:="OT ObjectSize(99999)"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 102. OT ItemExists — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT ItemExists(99999; "scalar")
	$otCmd_t:="OT ItemExists(99999; \"scalar\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 103. OT ItemType — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT ItemType(99999; "scalar")
	$otCmd_t:="OT ItemType(99999; \"scalar\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 104. OT IsEmbedded — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT IsEmbedded(99999; "scalar")
	$otCmd_t:="OT IsEmbedded(99999; \"scalar\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- Property query commands
	// ====================================================
	
	// 105. OT GetAllProperties — invalid handle
	$n_i:=$n_i+1
	ARRAY TEXT($outNames_at; 0)
	ARRAY LONGINT($outTypes_ai; 0)
	ARRAY LONGINT($outSizes_ai; 0)
	ARRAY LONGINT($outData_ai; 0)
	OT GetAllProperties(99999; $outNames_at; $outTypes_ai; $outSizes_ai; $outData_ai)
	$otCmd_t:="OT GetAllProperties(99999; ...)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 106. OT GetAllNamedProperties — invalid handle
	$n_i:=$n_i+1
	OT GetAllNamedProperties(99999; ""; $outNames_at; $outTypes_ai; $outSizes_ai; $outData_ai)
	$otCmd_t:="OT GetAllNamedProperties(99999; \"\"; ...)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 107. OT GetItemProperties — invalid handle
	$n_i:=$n_i+1
	var $outName_t : Text
	var $outType_i : Integer
	var $outItemSize_i : Integer
	var $outDataSize_i : Integer
	OT GetItemProperties(99999; 1; $outName_t; $outType_i; $outItemSize_i; $outDataSize_i)
	$otCmd_t:="OT GetItemProperties(99999; 1; ...)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 108. OT GetNamedProperties — invalid handle
	$n_i:=$n_i+1
	var $outIndex_i : Integer
	OT GetNamedProperties(99999; "scalar"; $outType_i; $outItemSize_i; $outDataSize_i; $outIndex_i)
	$otCmd_t:="OT GetNamedProperties(99999; \"scalar\"; ...)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- Item manipulation commands
	// ====================================================
	
	// 109. OT CompareItems — invalid handle
	$n_i:=$n_i+1
	$r_i:=OT CompareItems(99999; "scalar"; $h_i; "scalar")
	$otCmd_t:="OT CompareItems(99999; \"scalar\"; $h_i; \"scalar\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 110. OT CompareItems — type mismatch (Long vs Text)
	$n_i:=$n_i+1
	$r_i:=OT CompareItems($h_i; "scalar"; $h_i; "textItem")
	$otCmd_t:="OT CompareItems($h_i; \"scalar\"; $h_i; \"textItem\")"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 111. OT RenameItem — invalid handle
	$n_i:=$n_i+1
	OT RenameItem(99999; "scalar"; "renamed")
	$otCmd_t:="OT RenameItem(99999; \"scalar\"; \"renamed\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 112. OT RenameItem — rename conflict (target tag already exists)
	$n_i:=$n_i+1
	OT RenameItem($h_i; "scalar"; "textItem")
	$otCmd_t:="OT RenameItem($h_i; \"scalar\"; \"textItem\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 113. OT CopyItem — invalid source handle
	$n_i:=$n_i+1
	OT CopyItem(99999; "scalar"; $h_i; "copyDest")
	$otCmd_t:="OT CopyItem(99999; \"scalar\"; $h_i; \"copyDest\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 114. OT CopyItem — type mismatch (source Long, dest tag exists as Text)
	$n_i:=$n_i+1
	OT CopyItem($h_i; "scalar"; $h_i; "textItem")
	$otCmd_t:="OT CopyItem($h_i; \"scalar\"; $h_i; \"textItem\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 115. OT DeleteItem — invalid handle
	$n_i:=$n_i+1
	OT DeleteItem(99999; "scalar")
	$otCmd_t:="OT DeleteItem(99999; \"scalar\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 116. OT DeleteItem — missing tag
	$n_i:=$n_i+1
	OT DeleteItem($h_i; "doesNotExist")
	$otCmd_t:="OT DeleteItem($h_i; \"doesNotExist\")"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- Serialisation
	// ====================================================
	
	// 117. OT ObjectToBLOB — invalid handle
	$n_i:=$n_i+1
	OT ObjectToBLOB(99999; $ioBLOB_blob)
	$otCmd_t:="OT ObjectToBLOB(99999; $ioBLOB_blob)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 118. OT ObjectToNewBLOB — invalid handle
	$n_i:=$n_i+1
	$r_blob:=OT ObjectToNewBLOB(99999)
	$otCmd_t:="OT ObjectToNewBLOB(99999)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// 119. OT BLOBToObject — invalid BLOB (not a serialised object)
	$n_i:=$n_i+1
	TEXT TO BLOB("this is not a serialised object"; $badBlob_blob)
	$r_i:=OT BLOBToObject($badBlob_blob)
	$otCmd_t:="OT BLOBToObject(<invalid blob>)"
	$otResult_t:="returned "+String($r_i)+" OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- Dotted-path traversal
	// ====================================================
	
	// 120. OT PutLong — invalid dotted path through scalar
	$n_i:=$n_i+1
	OT PutLong($h_i; "scalar.child"; 9)
	$otCmd_t:="OT PutLong($h_i; \"scalar.child\"; 9)"
	$otResult_t:="OK="+String(OK)
	OTr_PutArrayText($accum_i; "otCmd"; $n_i; $otCmd_t)
	OTr_PutArrayText($accum_i; "otResult"; $n_i; $otResult_t)
	
	// ====================================================
	//MARK:- TEARDOWN
	// ====================================================
	OT Clear($h_i)
	
End if 

*/
// ==== END OT BLOCK ====
