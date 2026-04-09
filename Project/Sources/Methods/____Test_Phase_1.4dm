//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_1

// Comprehensive unit tests for all implemented Phase 1 OTr commands.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
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
	var $h3_i : Integer

	var $version_t : Text
	var $regResult_i : Integer
	var $compiled_i : Integer

	var $originalOptions_i : Integer
	var $newOptions_i : Integer
	var $readOptions_i : Integer

	var $prevHandler_t : Text
	var $prev2Handler_t : Text
	var $prev3Handler_t : Text

	var $findIndex_i : Integer

	ARRAY LONGINT:C221($handles_ai; 0)

	//MARK:- reset baseline
	OT ClearAll

	//MARK:- OT GetVersion
	$version_t:=OT GetVersion
	$total_i:=$total_i+1
	If ($version_t#"")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT GetVersion returned empty text."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT Register
	$regResult_i:=OT Register("phase1-test")
	$total_i:=$total_i+1
	If ($regResult_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT Register did not return 1."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT CompiledApplication
	$compiled_i:=OT CompiledApplication
	$total_i:=$total_i+1
	If ($compiled_i=0) | ($compiled_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT CompiledApplication was not 0/1."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT GetOptions / OT SetOptions
	$originalOptions_i:=OT GetOptions
	$newOptions_i:=1+4+8
	OT SetOptions($newOptions_i)
	$readOptions_i:=OT GetOptions

	$total_i:=$total_i+1
	If ($readOptions_i=$newOptions_i)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT SetOptions/OT GetOptions mismatch."+Char:C90(Carriage return:K15:38)
	End if 

	// Restore options for isolation.
	OT SetOptions($originalOptions_i)

	//MARK:- OT SetErrorHandler chaining
	$prevHandler_t:=OT SetErrorHandler("Handler_A")
	$prev2Handler_t:=OT SetErrorHandler("Handler_B")
	$prev3Handler_t:=OT SetErrorHandler("")

	$total_i:=$total_i+1
	If ($prev2Handler_t="Handler_A") & ($prev3Handler_t="Handler_B")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT SetErrorHandler chaining failed."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT New / OT IsObject
	$h1_i:=OT New
	$total_i:=$total_i+1
	If ($h1_i>0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT New did not return positive handle."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OT IsObject($h1_i)=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT IsObject failed for new handle."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OT IsObject(0)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT IsObject should be 0 for handle 0."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OT IsObject(999999)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT IsObject should be 0 for invalid handle."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT Copy
	$h2_i:=OT Copy($h1_i)
	$total_i:=$total_i+1
	If ($h2_i>0) & ($h2_i#$h1_i)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT Copy did not return a distinct handle."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OT IsObject($h2_i)=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Copied handle is not valid."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT GetHandleList
	ARRAY LONGINT:C221($handles_ai; 0)
	OT GetHandleList(->$handles_ai)

	$total_i:=$total_i+1
	If (Size of array:C274($handles_ai)=2)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT GetHandleList should return 2 handles."+Char:C90(Carriage return:K15:38)
	End if 

	$findIndex_i:=Find in array:C230($handles_ai; $h1_i)
	$total_i:=$total_i+1
	If ($findIndex_i>0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Handle list missing first handle."+Char:C90(Carriage return:K15:38)
	End if 

	$findIndex_i:=Find in array:C230($handles_ai; $h2_i)
	$total_i:=$total_i+1
	If ($findIndex_i>0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Handle list missing copied handle."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT Clear and slot reuse
	OT Clear($h1_i)

	$total_i:=$total_i+1
	If (OT IsObject($h1_i)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT Clear did not invalidate handle."+Char:C90(Carriage return:K15:38)
	End if 

	$h3_i:=OT New
	$total_i:=$total_i+1
	If ($h3_i=$h1_i)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT New did not reuse cleared slot."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OT ClearAll
	OT ClearAll

	ARRAY LONGINT:C221($handles_ai; 0)
	OT GetHandleList(->$handles_ai)

	$total_i:=$total_i+1
	If (Size of array:C274($handles_ai)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT ClearAll did not empty handle list."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OT IsObject($h2_i)=0) & (OT IsObject($h3_i)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT ClearAll left one or more handles valid."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- final report
	If ($failed_i=0)
		ALERT:C41(Current method name:C684+" - all tests passed ("+String:C10($passed_i)+"/"+String:C10($total_i)+").")
	Else 
		ALERT:C41(Current method name:C684+" - FAILED ("+String:C10($failed_i)+"/"+String:C10($total_i)+")."+Char:C90(Carriage return:K15:38)+$failures_t)
	End if 
Else 
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 
