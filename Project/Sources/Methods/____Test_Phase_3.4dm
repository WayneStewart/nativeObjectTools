//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_3

// Unit tests for Phase 3 item info and utility methods.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

var $total_i : Integer
var $passed_i : Integer
var $failed_i : Integer
var $failures_t : Text

var $h1_i : Integer
var $h2_i : Integer
var $hObj_i : Integer

var $count_i : Integer
var $type_i : Integer
var $isEmbedded_i : Integer
var $exists_i : Integer
var $size_i : Integer
var $cmp_i : Integer

var $name_t : Text
var $outType_i : Integer
var $itemSize_i : Integer
var $dataSize_i : Integer
var $index_i : Integer

ARRAY TEXT:C222($names_at; 0)
ARRAY LONGINT:C221($types_ai; 0)
ARRAY LONGINT:C221($itemSizes_ai; 0)
ARRAY LONGINT:C221($dataSizes_ai; 0)

//MARK:- setup
OTr_ClearAll
$h1_i:=OTr_New
$h2_i:=OTr_New
$hObj_i:=OTr_New

OTr_PutLong($h1_i; "a.long"; 42)
OTr_PutText($h1_i; "a.text"; "alpha")
OTr_PutBoolean($h1_i; "a.flag"; True:C214)
OTr_PutText($hObj_i; "inside"; "value")
OTr_PutObject($h1_i; "a.child"; $hObj_i)

OTr_SaveToClipboard($h1_i)

//MARK:- OTr_ItemCount
$total_i:=$total_i+1
$count_i:=OTr_ItemCount($h1_i; "a")
If ($count_i=4)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ItemCount on embedded object failed."+Char:C90(Carriage return:K15:38)
End if 

//MARK:- OTr_ItemExists
$total_i:=$total_i+1
$exists_i:=OTr_ItemExists($h1_i; "a.long")
If ($exists_i=1)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ItemExists failed for existing tag."+Char:C90(Carriage return:K15:38)
End if 

$total_i:=$total_i+1
$exists_i:=OTr_ItemExists($h1_i; "a.missing")
If ($exists_i=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ItemExists failed for missing tag."+Char:C90(Carriage return:K15:38)
End if 

//MARK:- OTr_ItemType and OTr_IsEmbedded
$total_i:=$total_i+1
$type_i:=OTr_ItemType($h1_i; "a.long")
// Numeric object properties may report as Real in some 4D versions.
If (($type_i=5) | ($type_i=1))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ItemType failed for long."+Char:C90(Carriage return:K15:38)
End if 

$total_i:=$total_i+1
$isEmbedded_i:=OTr_IsEmbedded($h1_i; "a.child")
If ($isEmbedded_i=1)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"IsEmbedded failed for object item."+Char:C90(Carriage return:K15:38)
End if 

//MARK:- OTr_GetAllNamedProperties
OTr_GetAllNamedProperties($h1_i; "a"; ->$names_at; ->$types_ai; \
->$itemSizes_ai; ->$dataSizes_ai)
$total_i:=$total_i+1
If (Size of array:C274($names_at)=4)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"GetAllNamedProperties count failed."+Char:C90(Carriage return:K15:38)
End if 

//MARK:- OTr_GetNamedProperties
$outType_i:=0
$itemSize_i:=0
$dataSize_i:=0
$index_i:=-1
OTr_GetNamedProperties($h1_i; "a.text"; ->$outType_i; ->$itemSize_i; \
->$dataSize_i; ->$index_i)
$total_i:=$total_i+1
If (($outType_i=112) & ($index_i=0))
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"GetNamedProperties failed."+Char:C90(Carriage return:K15:38)
End if 

//MARK:- OTr_GetItemProperties (order-agnostic)
$name_t:=""
$outType_i:=0
$itemSize_i:=0
$dataSize_i:=0
OTr_GetItemProperties($h1_i; 1; ->$name_t; ->$outType_i; \
->$itemSize_i; ->$dataSize_i)
$total_i:=$total_i+1
If ($name_t#"")
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"GetItemProperties failed to return name."+Char:C90(Carriage return:K15:38)
End if 

//MARK:- OTr_CopyItem / OTr_CompareItems / OTr_RenameItem / OTr_DeleteItem
OTr_CopyItem($h1_i; "a.text"; $h2_i; "b.text")
$cmp_i:=OTr_CompareItems($h1_i; "a.text"; $h2_i; "b.text")
$total_i:=$total_i+1
If ($cmp_i=1)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"CopyItem/CompareItems failed."+Char:C90(Carriage return:K15:38)
End if 

OTr_RenameItem($h2_i; "b.text"; "renamed")
$total_i:=$total_i+1
If (OTr_ItemExists($h2_i; "b.renamed")=1)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"RenameItem failed."+Char:C90(Carriage return:K15:38)
End if 

OTr_DeleteItem($h2_i; "b.renamed")
$total_i:=$total_i+1
If (OTr_ItemExists($h2_i; "b.renamed")=0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"DeleteItem failed."+Char:C90(Carriage return:K15:38)
End if 

//MARK:- OTr_ObjectSize
$total_i:=$total_i+1
$size_i:=OTr_ObjectSize($h1_i)
If ($size_i>0)
	$passed_i:=$passed_i+1
Else 
	$failed_i:=$failed_i+1
	$failures_t:=$failures_t+"ObjectSize failed."+Char:C90(Carriage return:K15:38)
End if 

//MARK:- done
OTr_ClearAll

var $result_t : Text

If ($failed_i=0)
	$result_t:=(Current method name:C684+" - all tests passed ("+String:C10($passed_i)+"/"+String:C10($total_i)+").")
Else 
	$result_t:=(Current method name:C684+" - FAILED ("+String:C10($failed_i)+"/"+String:C10($total_i)+")."+Char:C90(Carriage return:K15:38)+$failures_t)
End if 

ALERT:C41($result_t)

SET TEXT TO PASTEBOARD:C523($result_t)