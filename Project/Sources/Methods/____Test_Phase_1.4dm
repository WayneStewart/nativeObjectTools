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
	OTr_ClearAll

	//MARK:- OTr_GetVersion
	$version_t:=OTr_GetVersion
	$total_i:=$total_i+1
	If ($version_t#"")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_GetVersion returned empty text."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OTr_Register
	$regResult_i:=OTr_Register("phase1-test")
	$total_i:=$total_i+1
	If ($regResult_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_Register did not return 1."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OTr_CompiledApplication
	$compiled_i:=OTr_CompiledApplication
	$total_i:=$total_i+1
	If ($compiled_i=0) | ($compiled_i=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_CompiledApplication was not 0/1."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OTr_GetOptions / OTr_SetOptions
	$originalOptions_i:=OTr_GetOptions
	$newOptions_i:=1+4+8
	OTr_SetOptions($newOptions_i)
	$readOptions_i:=OTr_GetOptions

	$total_i:=$total_i+1
	If ($readOptions_i=$newOptions_i)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_SetOptions/OTr_GetOptions mismatch."+Char:C90(Carriage return:K15:38)
	End if 

	// Restore options for isolation.
	OTr_SetOptions($originalOptions_i)

	//MARK:- OTr_SetErrorHandler chaining
	$prevHandler_t:=OTr_SetErrorHandler("Handler_A")
	$prev2Handler_t:=OTr_SetErrorHandler("Handler_B")
	$prev3Handler_t:=OTr_SetErrorHandler("")

	$total_i:=$total_i+1
	If ($prev2Handler_t="Handler_A") & ($prev3Handler_t="Handler_B")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_SetErrorHandler chaining failed."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OTr_New / OTr_IsObject
	$h1_i:=OTr_New
	$total_i:=$total_i+1
	If ($h1_i>0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_New did not return positive handle."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OTr_IsObject($h1_i)=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_IsObject failed for new handle."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OTr_IsObject(0)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_IsObject should be 0 for handle 0."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OTr_IsObject(999999)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_IsObject should be 0 for invalid handle."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OTr_Copy
	$h2_i:=OTr_Copy($h1_i)
	$total_i:=$total_i+1
	If ($h2_i>0) & ($h2_i#$h1_i)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_Copy did not return a distinct handle."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OTr_IsObject($h2_i)=1)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Copied handle is not valid."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OTr_GetHandleList
	ARRAY LONGINT:C221($handles_ai; 0)
	OTr_GetHandleList(->$handles_ai)

	$total_i:=$total_i+1
	If (Size of array:C274($handles_ai)=2)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_GetHandleList should return 2 handles."+Char:C90(Carriage return:K15:38)
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

	//MARK:- OTr_Clear and slot reuse
	OTr_Clear($h1_i)

	$total_i:=$total_i+1
	If (OTr_IsObject($h1_i)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_Clear did not invalidate handle."+Char:C90(Carriage return:K15:38)
	End if 

	$h3_i:=OTr_New
	$total_i:=$total_i+1
	If ($h3_i=$h1_i)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_New did not reuse cleared slot."+Char:C90(Carriage return:K15:38)
	End if 

	//MARK:- OTr_ClearAll
	OTr_ClearAll

	ARRAY LONGINT:C221($handles_ai; 0)
	OTr_GetHandleList(->$handles_ai)

	$total_i:=$total_i+1
	If (Size of array:C274($handles_ai)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_ClearAll did not empty handle list."+Char:C90(Carriage return:K15:38)
	End if 

	$total_i:=$total_i+1
	If (OTr_IsObject($h2_i)=0) & (OTr_IsObject($h3_i)=0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_ClearAll left one or more handles valid."+Char:C90(Carriage return:K15:38)
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
