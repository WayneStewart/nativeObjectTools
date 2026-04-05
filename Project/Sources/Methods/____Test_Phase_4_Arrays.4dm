//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_4_Arrays

// Comprehensive unit tests for all array operations:
//   OTr_PutArray / OTr_GetArray
//   OTr_SizeOfArray / OTr_ArrayType / OTr_ResizeArray
//   OTr_InsertElement / OTr_DeleteElement
//   OTr_FindInArray
//   OTr_PutArrayLong  / OTr_GetArrayLong
//   OTr_PutArrayReal  / OTr_GetArrayReal
//   OTr_PutArrayString / OTr_GetArrayString
//   OTr_PutArrayText  / OTr_GetArrayText
//   OTr_PutArrayDate  / OTr_GetArrayDate
//   OTr_PutArrayTime  / OTr_GetArrayTime
//   OTr_PutArrayBoolean / OTr_GetArrayBoolean
//   OTr_SortArrays

// Skipped (no equality test available):
//   OTr_PutArrayBLOB    / OTr_GetArrayBLOB
//   OTr_PutArrayPicture / OTr_GetArrayPicture
//   OTr_PutArrayPointer / OTr_GetArrayPointer
//
// Access: Private

// Returns: Nothing (results shown via ALERT on failure,
//          summary ALERT at end)

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

var $h_i : Integer
var $total_i; $passed_i; $failed_i : Integer
var $failures_t : Text
var $i_i : Integer

ARRAY LONGINT:C221($longArr_ai; 0)
ARRAY REAL:C219($realArr_ar; 0)
ARRAY TEXT:C222($textArr_at; 0)
ARRAY TEXT:C222($strArr_at; 0)
ARRAY DATE:C224($dateArr_ad; 0)
ARRAY TIME:C1223($timeArr_ah; 0)
ARRAY BOOLEAN:C223($boolArr_ab; 0)

// ====================================================
// SETUP
// ====================================================
OTr_ClearAll
$h_i:=OTr_New
$total_i:=0
$passed_i:=0
$failed_i:=0
$failures_t:=""

// ====================================================
//MARK:- OTr_PutArray / OTr_GetArray (LongInt)
// ====================================================

$total_i:=$total_i+1
ARRAY LONGINT:C221($longArr_ai; 5)
For ($i_i; 1; 5)
	$longArr_ai{$i_i}:=$i_i*10
End for 
OTr_PutArray($h_i; "longs"; ->$longArr_ai)
ARRAY LONGINT:C221($longArr_ai; 0)
OTr_GetArray($h_i; "longs"; ->$longArr_ai)
If ((Size of array:C274($longArr_ai)=5) & ($longArr_ai{1}=10) & ($longArr_ai{5}=50))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArray/GetArray LongInt"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_PutArray / OTr_GetArray (Text)
// ====================================================

$total_i:=$total_i+1
ARRAY TEXT:C222($textArr_at; 3)
$textArr_at{1}:="alpha"
$textArr_at{2}:="beta"
$textArr_at{3}:="gamma"
OTr_PutArray($h_i; "words"; ->$textArr_at)
ARRAY TEXT:C222($textArr_at; 0)
OTr_GetArray($h_i; "words"; ->$textArr_at)
If ((Size of array:C274($textArr_at)=3) & ($textArr_at{1}="alpha") & ($textArr_at{3}="gamma"))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArray/GetArray Text"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_SizeOfArray
// ====================================================

$total_i:=$total_i+1
If (OTr_SizeOfArray($h_i; "longs")=5)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"SizeOfArray"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_ArrayType
// ====================================================

$total_i:=$total_i+1
If (OTr_ArrayType($h_i; "longs")=LongInt array:K8:19)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ArrayType returned wrong type for LongInt array"+Char:C90(Carriage return:K15:38)
End if 

$total_i:=$total_i+1
If (OTr_ArrayType($h_i; "missing")=-1)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ArrayType should return -1 for missing tag"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_ResizeArray — grow
// ====================================================

$total_i:=$total_i+1
OTr_ResizeArray($h_i; "longs"; 8)
If ((OTr_SizeOfArray($h_i; "longs")=8) & (OK=1))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ResizeArray grow"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_ResizeArray — shrink
// ====================================================

$total_i:=$total_i+1
OTr_ResizeArray($h_i; "longs"; 3)
If ((OTr_SizeOfArray($h_i; "longs")=3) & (OK=1))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ResizeArray shrink"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_ResizeArray — invalid handle
// ====================================================

$total_i:=$total_i+1
OTr_ResizeArray(9999; "longs"; 5)
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ResizeArray invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_PutArrayLong / OTr_GetArrayLong
// ====================================================

// Rebuild a known 5-element LongInt array
ARRAY LONGINT:C221($longArr_ai; 5)
For ($i_i; 1; 5)
	$longArr_ai{$i_i}:=$i_i*100
End for 
OTr_PutArray($h_i; "longs"; ->$longArr_ai)

$total_i:=$total_i+1
OTr_PutArrayLong($h_i; "longs"; 2; 999)
If ((OTr_GetArrayLong($h_i; "longs"; 2)=999) & (OK=1))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayLong/GetArrayLong"+Char:C90(Carriage return:K15:38)
End if 

// Unchanged elements not disturbed
$total_i:=$total_i+1
If ((OTr_GetArrayLong($h_i; "longs"; 1)=100) & (OTr_GetArrayLong($h_i; "longs"; 5)=500))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayLong — adjacent elements disturbed"+Char:C90(Carriage return:K15:38)
End if 

// Out of range
$total_i:=$total_i+1
OTr_PutArrayLong($h_i; "longs"; 99; 1)
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayLong out-of-range should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// Type mismatch
$total_i:=$total_i+1
OTr_PutArrayLong($h_i; "words"; 1; 1)
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayLong type mismatch should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_PutArrayReal / OTr_GetArrayReal
// ====================================================

$total_i:=$total_i+1
ARRAY REAL:C219($realArr_ar; 4)
$realArr_ar{1}:=1.1
$realArr_ar{2}:=2.2
$realArr_ar{3}:=3.3
$realArr_ar{4}:=4.4
OTr_PutArray($h_i; "reals"; ->$realArr_ar)
OTr_PutArrayReal($h_i; "reals"; 3; 9.9)
If ((OTr_GetArrayReal($h_i; "reals"; 3)>9.89) & (OTr_GetArrayReal($h_i; "reals"; 3)<9.91))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayReal/GetArrayReal"+Char:C90(Carriage return:K15:38)
End if 

// Neighbours unchanged
$total_i:=$total_i+1
If ((OTr_GetArrayReal($h_i; "reals"; 2)>2.19) & (OTr_GetArrayReal($h_i; "reals"; 4)>4.39))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayReal — adjacent elements disturbed"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_PutArrayString / OTr_GetArrayString
// ====================================================

$total_i:=$total_i+1
ARRAY TEXT:C222($strArr_at; 3)
$strArr_at{1}:="foo"
$strArr_at{2}:="bar"
$strArr_at{3}:="baz"
OTr_PutArray($h_i; "strs"; ->$strArr_at)
OTr_PutArrayString($h_i; "strs"; 2; "qux")
If (OTr_GetArrayString($h_i; "strs"; 2)="qux")
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayString/GetArrayString"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_PutArrayText / OTr_GetArrayText
// ====================================================

$total_i:=$total_i+1
ARRAY TEXT:C222($textArr_at; 3)
$textArr_at{1}:="one"
$textArr_at{2}:="two"
$textArr_at{3}:="three"
OTr_PutArray($h_i; "texts"; ->$textArr_at)
OTr_PutArrayText($h_i; "texts"; 1; "ONE")
If (OTr_GetArrayText($h_i; "texts"; 1)="ONE")
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayText/GetArrayText"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_PutArrayDate / OTr_GetArrayDate
// ====================================================

$total_i:=$total_i+1
ARRAY DATE:C224($dateArr_ad; 3)
$dateArr_ad{1}:=!2026-01-01!
$dateArr_ad{2}:=!2026-06-15!
$dateArr_ad{3}:=!2026-12-31!
OTr_PutArray($h_i; "dates"; ->$dateArr_ad)
OTr_PutArrayDate($h_i; "dates"; 2; !2000-07-04!)
If (OTr_GetArrayDate($h_i; "dates"; 2)=!2000-07-04!)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayDate/GetArrayDate"+Char:C90(Carriage return:K15:38)
End if 

// Neighbours unchanged
$total_i:=$total_i+1
If ((OTr_GetArrayDate($h_i; "dates"; 1)=!2026-01-01!) & (OTr_GetArrayDate($h_i; "dates"; 3)=!2026-12-31!))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayDate — adjacent elements disturbed"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_PutArrayTime / OTr_GetArrayTime
// ====================================================

$total_i:=$total_i+1
ARRAY TIME:C1223($timeArr_ah; 3)
$timeArr_ah{1}:=?08:00:00?
$timeArr_ah{2}:=?12:30:00?
$timeArr_ah{3}:=?23:59:59?
OTr_PutArray($h_i; "times"; ->$timeArr_ah)
OTr_PutArrayTime($h_i; "times"; 2; ?09:15:00?)
If (OTr_GetArrayTime($h_i; "times"; 2)=?09:15:00?)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayTime/GetArrayTime"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_PutArrayBoolean / OTr_GetArrayBoolean
// ====================================================

$total_i:=$total_i+1
ARRAY BOOLEAN:C223($boolArr_ab; 4)
$boolArr_ab{1}:=True:C214
$boolArr_ab{2}:=False:C215
$boolArr_ab{3}:=True:C214
$boolArr_ab{4}:=False:C215
OTr_PutArray($h_i; "flags"; ->$boolArr_ab)
OTr_PutArrayBoolean($h_i; "flags"; 2; True:C214)
If ((OTr_GetArrayBoolean($h_i; "flags"; 2)=1) & (OTr_GetArrayBoolean($h_i; "flags"; 4)=0))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"PutArrayBoolean/GetArrayBoolean"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_InsertElement
// ====================================================

// Original: ["alpha","beta","gamma"]
// Insert 1 blank at pos 2, then set its value to "delta"
// Expected: ["alpha","delta","beta","gamma"]
$total_i:=$total_i+1
ARRAY TEXT:C222($textArr_at; 3)
$textArr_at{1}:="alpha"
$textArr_at{2}:="beta"
$textArr_at{3}:="gamma"
OTr_PutArray($h_i; "ins_test"; ->$textArr_at)
OTr_InsertElement($h_i; "ins_test"; 2; 1)
OTr_PutArrayText($h_i; "ins_test"; 2; "delta")
ARRAY TEXT:C222($textArr_at; 0)
OTr_GetArray($h_i; "ins_test"; ->$textArr_at)
If ((Size of array:C274($textArr_at)=4) & ($textArr_at{2}="delta") & ($textArr_at{3}="beta") & ($textArr_at{4}="gamma"))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"InsertElement at pos 2"+Char:C90(Carriage return:K15:38)
End if 

// Insert at end (pos > numElements) — appended blank, then fill "epsilon"
// Expected: ["alpha","delta","beta","gamma","epsilon"]
$total_i:=$total_i+1
OTr_InsertElement($h_i; "ins_test"; 99; 1)
OTr_PutArrayText($h_i; "ins_test"; 5; "epsilon")
ARRAY TEXT:C222($textArr_at; 0)
OTr_GetArray($h_i; "ins_test"; ->$textArr_at)
If ((Size of array:C274($textArr_at)=5) & ($textArr_at{5}="epsilon") & ($textArr_at{1}="alpha"))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"InsertElement at end"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_DeleteElement
// ====================================================

// words = ["alpha","delta","beta","gamma","epsilon"]
// delete pos 2 ("delta") -> ["alpha","beta","gamma","epsilon"]
$total_i:=$total_i+1
OTr_DeleteElement($h_i; "ins_test"; 2)
ARRAY TEXT:C222($textArr_at; 0)
OTr_GetArray($h_i; "ins_test"; ->$textArr_at)
If ((Size of array:C274($textArr_at)=4) & ($textArr_at{1}="alpha") & ($textArr_at{2}="beta"))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"DeleteElement at pos 2"+Char:C90(Carriage return:K15:38)
End if 

// Delete last element
$total_i:=$total_i+1
OTr_DeleteElement($h_i; "ins_test"; 4)
ARRAY TEXT:C222($textArr_at; 0)
OTr_GetArray($h_i; "ins_test"; ->$textArr_at)
If ((Size of array:C274($textArr_at)=3) & ($textArr_at{3}="gamma"))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"DeleteElement at end"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_FindInArray — Text
// ====================================================

$total_i:=$total_i+1
ARRAY TEXT:C222($textArr_at; 5)
$textArr_at{1}:="cat"
$textArr_at{2}:="dog"
$textArr_at{3}:="bird"
$textArr_at{4}:="dog"
$textArr_at{5}:="fish"
OTr_PutArray($h_i; "pets"; ->$textArr_at)
If (OTr_FindInArray($h_i; "pets"; "dog")=2)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"FindInArray Text — first match"+Char:C90(Carriage return:K15:38)
End if 

// Search from start position
$total_i:=$total_i+1
If (OTr_FindInArray($h_i; "pets"; "dog"; 3)=4)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"FindInArray Text — startFrom"+Char:C90(Carriage return:K15:38)
End if 

// Not found
$total_i:=$total_i+1
If (OTr_FindInArray($h_i; "pets"; "elephant")=-1)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"FindInArray Text — not found should return -1"+Char:C90(Carriage return:K15:38)
End if 

OTr_SaveToClipboard($h_i)

// ====================================================
//MARK:- OTr_FindInArray — LongInt
// ====================================================

$total_i:=$total_i+1
ARRAY LONGINT:C221($longArr_ai; 4)
$longArr_ai{1}:=10
$longArr_ai{2}:=20
$longArr_ai{3}:=30
$longArr_ai{4}:=20
OTr_PutArray($h_i; "nums"; ->$longArr_ai)
If (OTr_FindInArray($h_i; "nums"; "20")=2)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"FindInArray LongInt — first match"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_FindInArray — Boolean
// ====================================================

$total_i:=$total_i+1
ARRAY BOOLEAN:C223($boolArr_ab; 4)
$boolArr_ab{1}:=False:C215
$boolArr_ab{2}:=False:C215
$boolArr_ab{3}:=True:C214
$boolArr_ab{4}:=True:C214
OTr_PutArray($h_i; "bools"; ->$boolArr_ab)
If (OTr_FindInArray($h_i; "bools"; "true")=3)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"FindInArray Boolean"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_FindInArray — Date
// ====================================================

$total_i:=$total_i+1
ARRAY DATE:C224($dateArr_ad; 3)
$dateArr_ad{1}:=!2026-01-01!
$dateArr_ad{2}:=!2026-06-15!
$dateArr_ad{3}:=!2026-12-31!
OTr_PutArray($h_i; "fdates"; ->$dateArr_ad)
If (OTr_FindInArray($h_i; "fdates"; "2026-06-15")=2)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"FindInArray Date"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_FindInArray — error cases
// ====================================================

// Invalid handle
$total_i:=$total_i+1
OTr_FindInArray(9999; "pets"; "cat")
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"FindInArray invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// Missing tag
$total_i:=$total_i+1
OTr_FindInArray($h_i; "no_such_tag"; "x")
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"FindInArray missing tag should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_SortArrays — single ascending key (LongInt)
// ====================================================

$total_i:=$total_i+1
ARRAY LONGINT:C221($longArr_ai; 5)
$longArr_ai{1}:=40
$longArr_ai{2}:=10
$longArr_ai{3}:=50
$longArr_ai{4}:=20
$longArr_ai{5}:=30
OTr_PutArray($h_i; "sort_nums"; ->$longArr_ai)
OTr_SortArrays($h_i; "sort_nums"; ">")
ARRAY LONGINT:C221($longArr_ai; 0)
OTr_GetArray($h_i; "sort_nums"; ->$longArr_ai)
If (($longArr_ai{1}=10) & ($longArr_ai{2}=20) & ($longArr_ai{3}=30) & ($longArr_ai{4}=40) & ($longArr_ai{5}=50))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"SortArrays single key ascending LongInt"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_SortArrays — single descending key (Text)
// ====================================================

$total_i:=$total_i+1
ARRAY TEXT:C222($textArr_at; 4)
$textArr_at{1}:="banana"
$textArr_at{2}:="apple"
$textArr_at{3}:="date"
$textArr_at{4}:="cherry"
OTr_PutArray($h_i; "sort_words"; ->$textArr_at)
OTr_SortArrays($h_i; "sort_words"; "<")
ARRAY TEXT:C222($textArr_at; 0)
OTr_GetArray($h_i; "sort_words"; ->$textArr_at)
If (($textArr_at{1}="date") & ($textArr_at{2}="cherry") & ($textArr_at{3}="banana") & ($textArr_at{4}="apple"))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"SortArrays single key descending Text"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_SortArrays — two keys, slave array follows
// Sort by first_name ASC then by score DESC;
// verify that "names" slave follows the sort order.
// ====================================================

$total_i:=$total_i+1
ARRAY TEXT:C222($textArr_at; 4)
$textArr_at{1}:="Charlie"
$textArr_at{2}:="Alice"
$textArr_at{3}:="Bob"
$textArr_at{4}:="Alice"
OTr_PutArray($h_i; "first_names"; ->$textArr_at)

ARRAY LONGINT:C221($longArr_ai; 4)
$longArr_ai{1}:=80
$longArr_ai{2}:=90
$longArr_ai{3}:=70
$longArr_ai{4}:=95
OTr_PutArray($h_i; "scores"; ->$longArr_ai)

// Slave array to verify ordering
ARRAY LONGINT:C221($longArr_ai; 4)
$longArr_ai{1}:=1
$longArr_ai{2}:=2
$longArr_ai{3}:=3
$longArr_ai{4}:=4
OTr_PutArray($h_i; "orig_pos"; ->$longArr_ai)

OTr_SortArrays($h_i; "first_names"; ">"; "scores"; "<"; "orig_pos"; "*")

ARRAY TEXT:C222($textArr_at; 0)
OTr_GetArray($h_i; "first_names"; ->$textArr_at)
ARRAY LONGINT:C221($longArr_ai; 0)
OTr_GetArray($h_i; "scores"; ->$longArr_ai)

// Expected: Alice(95), Alice(90), Bob(70), Charlie(80)
// orig_pos slave should follow: 4, 2, 3, 1
ARRAY LONGINT:C221($posArr_ai; 0)
OTr_GetArray($h_i; "orig_pos"; ->$posArr_ai)

If (($textArr_at{1}="Alice") & ($textArr_at{2}="Alice") & ($textArr_at{3}="Bob") & ($textArr_at{4}="Charlie"))
	If (($longArr_ai{1}=95) & ($longArr_ai{2}=90))
		If (($posArr_ai{3}=3) & ($posArr_ai{4}=1))
			$passed_i:=$passed_i+1
		Else 
			$failed_i:=$failed_i+1
			$failures_t:=$failures_t+"SortArrays two keys — slave array order wrong"+Char:C90(Carriage return:K15:38)
		End if 
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"SortArrays two keys — secondary key order wrong"+Char:C90(Carriage return:K15:38)
	End if 
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"SortArrays two keys — primary key order wrong"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- OTr_SortArrays — error cases
// ====================================================

// Nonexistent tag — OTr_zSortValidatePair reports "Tag not found"
$total_i:=$total_i+1
OTr_SortArrays($h_i; "no_such_array"; ">")
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"SortArrays nonexistent tag should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// Invalid direction
$total_i:=$total_i+1
OTr_SortArrays($h_i; "sort_nums"; "X")
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"SortArrays bad direction should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// Invalid handle
$total_i:=$total_i+1
OTr_SortArrays(9999; "sort_nums"; ">")
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"SortArrays invalid handle should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// All-slave (no key)
$total_i:=$total_i+1
OTr_SortArrays($h_i; "sort_nums"; "*")
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"SortArrays all-slave should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// Size mismatch
$total_i:=$total_i+1
ARRAY LONGINT:C221($longArr_ai; 3)
$longArr_ai{1}:=1
$longArr_ai{2}:=2
$longArr_ai{3}:=3
OTr_PutArray($h_i; "short_arr"; ->$longArr_ai)
OTr_SortArrays($h_i; "sort_nums"; ">"; "short_arr"; "*")
If (OK=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"SortArrays size mismatch should set OK=0"+Char:C90(Carriage return:K15:38)
End if 

// ====================================================
//MARK:- SUMMARY
// ====================================================
OTr_ClearAll

var $summary_t : Text
$summary_t:="Phase 5 Array Tests"+Char:C90(Carriage return:K15:38)
$summary_t:=$summary_t+"Total:  "+String:C10($total_i)+Char:C90(Carriage return:K15:38)
$summary_t:=$summary_t+"Passed: "+String:C10($passed_i)+Char:C90(Carriage return:K15:38)
$summary_t:=$summary_t+"Failed: "+String:C10($failed_i)

If ($failed_i>0)
	$summary_t:=$summary_t+Char:C90(Carriage return:K15:38)+Char:C90(Carriage return:K15:38)+"Failures:"+Char:C90(Carriage return:K15:38)+$failures_t
End if 

ALERT:C41($summary_t)
SET TEXT TO PASTEBOARD:C523($summary_t)
