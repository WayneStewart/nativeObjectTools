//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_3

// Unit tests for Phase 3 item info and utility methods.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t : Text

// ----------------------------------------------------

$StackSize_i:=0
$DesiredProcessName_t:=Current method name:C684

If (Current process name:C1392=$DesiredProcessName_t)

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
	OT ClearAll
	$h1_i:=OT New
	$h2_i:=OT New
	$hObj_i:=OT New

	OT PutLong($h1_i; "a.long"; 42)
	OT PutText($h1_i; "a.text"; "alpha")
	OT PutBoolean($h1_i; "a.flag"; True:C214)
	OT PutText($hObj_i; "inside"; "value")
	OT PutObject($h1_i; "a.child"; $hObj_i)

	OT SaveToClipboard($h1_i)

	//MARK:- OT ItemCount
	$total_i:=$total_i+1
	$count_i:=OT ItemCount($h1_i; "a")
	If ($count_i=4)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"ItemCount on embedded object failed."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT ItemExists
	$total_i:=$total_i+1
	$exists_i:=OT ItemExists($h1_i; "a.long")
	If ($exists_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"ItemExists failed for existing tag."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	$exists_i:=OT ItemExists($h1_i; "a.missing")
	If ($exists_i=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"ItemExists failed for missing tag."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT ItemType and OT IsEmbedded
	$total_i:=$total_i+1
	$type_i:=OT ItemType($h1_i; "a.long")
	// Numeric object properties may report as Real in some 4D versions.
	If ($type_i=5) | ($type_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"ItemType failed for long."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	$isEmbedded_i:=OT IsEmbedded($h1_i; "a.child")
	If ($isEmbedded_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"IsEmbedded failed for object item."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT GetAllNamedProperties
	OT GetAllNamedProperties($h1_i; "a"; ->$names_at; ->$types_ai; \
	->$itemSizes_ai; ->$dataSizes_ai)
	$total_i:=$total_i+1
	If (Size of array:C274($names_at)=4)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetAllNamedProperties count failed."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT GetNamedProperties
	$outType_i:=0
	$itemSize_i:=0
	$dataSize_i:=0
	$index_i:=-1
	OT GetNamedProperties($h1_i; "a.text"; ->$outType_i; ->$itemSize_i; \
	->$dataSize_i; ->$index_i)
	$total_i:=$total_i+1
	If ($outType_i=112) & ($index_i=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetNamedProperties failed."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT GetItemProperties (order-agnostic)
	$name_t:=""
	$outType_i:=0
	$itemSize_i:=0
	$dataSize_i:=0
	OT GetItemProperties($h1_i; 1; ->$name_t; ->$outType_i; \
	->$itemSize_i; ->$dataSize_i)
	$total_i:=$total_i+1
	If ($name_t#"")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetItemProperties failed to return name."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT CopyItem / OT CompareItems / OT RenameItem / OT DeleteItem
	OT CopyItem($h1_i; "a.text"; $h2_i; "b.text")
	$cmp_i:=OT CompareItems($h1_i; "a.text"; $h2_i; "b.text")
	$total_i:=$total_i+1
	If ($cmp_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"CopyItem/CompareItems failed."+Char:C90(Carriage return:K15:38)
	End if 

	OT RenameItem($h2_i; "b.text"; "renamed")
	$total_i:=$total_i+1
	If (OT ItemExists($h2_i; "b.renamed")=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"RenameItem failed."+Char:C90(Carriage return:K15:38)
	End if 

	OT DeleteItem($h2_i; "b.renamed")
	$total_i:=$total_i+1
	If (OT ItemExists($h2_i; "b.renamed")=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"DeleteItem failed."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT ObjectSize
	$total_i:=$total_i+1
	$size_i:=OT ObjectSize($h1_i)
	If ($size_i>0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"ObjectSize failed."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- done
	OT ClearAll

	var $result_t : Text

	If ($failed_i=0)
		$result_t:=(Current method name:C684+" - all tests passed ("+String:C10($passed_i)+"/"+String:C10($total_i)+").")
	Else 
		$result_t:=(Current method name:C684+" - FAILED ("+String:C10($failed_i)+"/"+String:C10($total_i)+")."+Char:C90(Carriage return:K15:38)+$failures_t)
	End if 

	ALERT:C41($result_t)

	SET TEXT TO PASTEBOARD:C523($result_t)
Else 
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 
