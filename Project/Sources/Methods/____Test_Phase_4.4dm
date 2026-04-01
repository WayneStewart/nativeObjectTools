//%attributes = {"invisible":true}
//// ====================================================
//// Project Method: ____Test_Phase_4
////
//// Comprehensive test suite for Phase 4 (Array
//// Operations): bulk arrays, typed elements, and
//// array utilities.
////
//// Access: Private

//// Parameters: None

//// Returns: Nothing

//// Created by Wayne Stewart, 2026-04-01
//// ====================================================



//var $h1_i; $h2_i; $i_i; $j_i; $size_i; $foundIdx_i : Integer
//ARRAY LONGINT($longArr_ai; 0)
//ARRAY REAL($realArr_ar; 0)
//ARRAY TEXT($textArr_at; 0)
//ARRAY DATE($dateArr_ad; 0)
//ARRAY TIME($timeArr_atime; 0)
//ARRAY BOOLEAN($boolArr_ab; 0)

//var $total_i; $passed_i; $failed_i : Integer

//OTr_ClearAll

//// Debug checkpoint: store handle for inspection
//$h1_i:=OTr_New

//// ====================================================
//// BULK ARRAY TESTS
//// ====================================================

//$total_i:=0
//$passed_i:=0
//$failed_i:=0

//// Test 1: PutArray Long and GetArray Long
//$total_i:=$total_i+1
//ARRAY LONGINT($longArr_ai; 5)
//For ($i_i; 1; 5)
//$longArr_ai{$i_i}:=$i_i*10
//End for 

//OTr_PutArray($h1_i; "numbers"; ->$longArr_ai)

//ARRAY LONGINT($longArr_ai; 0)
//OTr_GetArray($h1_i; "numbers"; ->$longArr_ai)

//If (Size of array($longArr_ai)=5)
//If (($longArr_ai{1}=10) & ($longArr_ai{5}=50))
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("GetArray longint values mismatch")
//End if 
//Else 
//$failed_i:=$failed_i+1
//ALERT("GetArray longint size mismatch")
//End if 

//// Test 2: PutArray Text and GetArray Text
//$total_i:=$total_i+1
//ARRAY TEXT($textArr_at; 3)
//$textArr_at{1}:="alpha"
//$textArr_at{2}:="beta"
//$textArr_at{3}:="gamma"

//OTr_PutArray($h1_i; "words"; ->$textArr_at)

//ARRAY TEXT($textArr_at; 0)
//OTr_GetArray($h1_i; "words"; ->$textArr_at)

//If ((Size of array($textArr_at)=3) & ($textArr_at{1}="alpha") & ($textArr_at{3}="gamma"))
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("GetArray text mismatch")
//End if 

//// Save state for debugging
//OTr_SaveToClipboard($h1_i)

//// ====================================================
//// ELEMENT PUT/GET TESTS (Long)
//// ====================================================

//$total_i:=$total_i+1
//OTr_PutArrayLong($h1_i; "indices"; 1; 100)
//OTr_PutArrayLong($h1_i; "indices"; 2; 200)
//OTr_PutArrayLong($h1_i; "indices"; 5; 500)

//If ((OTr_GetArrayLong($h1_i; "indices"; 1)=100) & (OTr_GetArrayLong($h1_i; "indices"; 5)=500))
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("PutArrayLong/GetArrayLong mismatch")
//End if 

//// ====================================================
//// ELEMENT PUT/GET TESTS (Real)
//// ====================================================

//$total_i:=$total_i+1
//OTr_PutArrayReal($h1_i; "decimals"; 1; 3.14)
//OTr_PutArrayReal($h1_i; "decimals"; 2; 2.71)

//If ((OTr_GetArrayReal($h1_i; "decimals"; 1)>3.1) & (OTr_GetArrayReal($h1_i; "decimals"; 1)<3.2) & (OTr_GetArrayReal($h1_i; "decimals"; 2)>2.7) & (OTr_GetArrayReal($h1_i; "decimals"; 2)<2.8))
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("PutArrayReal/GetArrayReal mismatch")
//End if 

//// ====================================================
//// ELEMENT PUT/GET TESTS (String/Text)
//// ====================================================

//$total_i:=$total_i+1
//OTr_PutArrayString($h1_i; "names"; 1; "John")
//OTr_PutArrayString($h1_i; "names"; 2; "Jane")
//OTr_PutArrayText($h1_i; "names"; 3; "Bob")

//If ((OTr_GetArrayString($h1_i; "names"; 1)="John") & (OTr_GetArrayText($h1_i; "names"; 3)="Bob"))
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("PutArrayString/Text mismatch")
//End if 

//// ====================================================
//// ELEMENT PUT/GET TESTS (Date)
//// ====================================================

//$total_i:=$total_i+1
//OTr_PutArrayDate($h1_i; "dates"; 1; Date("1/4/2026"))
//OTr_PutArrayDate($h1_i; "dates"; 2; Date("25/12/2026"))

//If (Substring(String(OTr_GetArrayDate($h1_i; "dates"; 1); ISO date GMT); 1; 7)="2026-04")
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("PutArrayDate/GetArrayDate mismatch")
//End if 

//// ====================================================
//// ELEMENT PUT/GET TESTS (Time)
//// ====================================================

//$total_i:=$total_i+1
//OTr_PutArrayTime($h1_i; "times"; 1; ?12:30:15?)
//OTr_PutArrayTime($h1_i; "times"; 2; ?23:59:59?)

//If (OTr_GetArrayTime($h1_i; "times"; 1)=?12:30:15?)
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("PutArrayTime/GetArrayTime mismatch")
//End if 

//// ====================================================
//// ELEMENT PUT/GET TESTS (Boolean)
//// ====================================================

//$total_i:=$total_i+1
//OTr_PutArrayBoolean($h1_i; "flags"; 1; True)
//OTr_PutArrayBoolean($h1_i; "flags"; 2; False)
//OTr_PutArrayBoolean($h1_i; "flags"; 3; True)

//If ((OTr_GetArrayBoolean($h1_i; "flags"; 1)=True) & (OTr_GetArrayBoolean($h1_i; "flags"; 2)=False))
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("PutArrayBoolean/GetArrayBoolean mismatch")
//End if 

//// ====================================================
//// ARRAY UTILITY TESTS (SizeOfArray)
//// ====================================================

//$total_i:=$total_i+1
//OTr_PutArrayLong($h1_i; "counter"; 1; 11)
//OTr_PutArrayLong($h1_i; "counter"; 2; 22)
//OTr_PutArrayLong($h1_i; "counter"; 3; 33)

//$size_i:=OTr_SizeOfArray($h1_i; "counter")

//If ($size_i=3)
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("SizeOfArray returned "+String($size_i)+", expected 3")
//End if 

//// ====================================================
//// ARRAY UTILITY TESTS (ResizeArray)
//// ====================================================

//$total_i:=$total_i+1
//OTr_ResizeArray($h1_i; "counter"; 5)
//$size_i:=OTr_SizeOfArray($h1_i; "counter")

//If ($size_i=5)
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("ResizeArray failed")
//End if 

//// ====================================================
//// ARRAY UTILITY TESTS (InsertElement)
//// ====================================================

//$total_i:=$total_i+1
//// array is [11, 22, 33, 0, 0]
//OTr_InsertElement($h1_i; "counter"; 2)  // Insert at pos 2
//OTr_PutArrayLong($h1_i; "counter"; 2; 99)

//If ((OTr_GetArrayLong($h1_i; "counter"; 1)=11) & (OTr_GetArrayLong($h1_i; "counter"; 2)=99) & (OTr_GetArrayLong($h1_i; "counter"; 3)=22))
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("InsertElement failed")
//End if 

//// ====================================================
//// ARRAY UTILITY TESTS (DeleteElement)
//// ====================================================

//$total_i:=$total_i+1
//OTr_DeleteElement($h1_i; "counter"; 2)  // Delete pos 2

//If (OTr_GetArrayLong($h1_i; "counter"; 2)=22)
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("DeleteElement failed")
//End if 

//// ====================================================
//// ARRAY UTILITY TESTS (FindInArray)
//// ====================================================

//$total_i:=$total_i+1
//OTr_PutArrayString($h1_i; "search"; 1; "apple")
//OTr_PutArrayString($h1_i; "search"; 2; "banana")
//OTr_PutArrayString($h1_i; "search"; 3; "cherry")

//$foundIdx_i:=OTr_FindInArray($h1_i; "search"; "banana")

//If ($foundIdx_i=2)
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("FindInArray returned "+String($foundIdx_i)+", expected 2")
//End if 

//// ====================================================
//// ARRAY UTILITY TESTS (SortArrays)
//// ====================================================

//$total_i:=$total_i+1
//OTr_PutArrayString($h1_i; "surname"; 1; "Smith")
//OTr_PutArrayString($h1_i; "surname"; 2; "Adam")
//OTr_PutArrayString($h1_i; "surname"; 3; "Jones")

//OTr_PutArrayString($h1_i; "given"; 1; "John")
//OTr_PutArrayString($h1_i; "given"; 2; "Sarah")
//OTr_PutArrayString($h1_i; "given"; 3; "Robert")

//OTr_SortArrays($h1_i; "surname"; ">"; "given"; "*")

//If ((OTr_GetArrayString($h1_i; "surname"; 1)="Adam") & (OTr_GetArrayString($h1_i; "given"; 1)="Sarah"))
//$passed_i:=$passed_i+1
//Else 
//$failed_i:=$failed_i+1
//ALERT("SortArrays failed")
//End if 

//// ====================================================
//// SUMMARY
//// ====================================================

//ALERT("Phase 4 Test Summary:\r"+"Total: "+String($total_i)+"\r"+"Passed: "+String($passed_i)+"\r"+"Failed: "+String($failed_i))
