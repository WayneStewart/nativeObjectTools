//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_2

// Unit tests for Phase 2 scalar put/get and object path methods.

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

	var $hRoot_i : Integer
	var $hObj_i : Integer
	var $hObjOut_i : Integer

	var $long_i : Integer
	var $real_r : Real
	var $text_t : Text
	var $date_d : Date
	var $time_h : Time
	var $bool_i : Integer

	//MARK:- baseline
	OTr_ClearAll
	$hRoot_i:=OTr_New
	$hObj_i:=OTr_New

	//MARK:- scalar put/get
	OTr_PutLong($hRoot_i; "long.value"; 42)
	$long_i:=OTr_GetLong($hRoot_i; "long.value")
	$total_i:=$total_i+1
	If ($long_i=42)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Put/GetLong failed."+Char(Carriage return)
	End if

	OTr_PutReal($hRoot_i; "real.value"; 3.14)
	$real_r:=OTr_GetReal($hRoot_i; "real.value")
	$total_i:=$total_i+1
	If ($real_r=3.14)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Put/GetReal failed."+Char(Carriage return)
	End if

	OTr_PutString($hRoot_i; "text.string"; "alpha")
	$text_t:=OTr_GetString($hRoot_i; "text.string")
	$total_i:=$total_i+1
	If ($text_t="alpha")
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Put/GetString failed."+Char(Carriage return)
	End if

	OTr_PutText($hRoot_i; "text.text"; "beta")
	$text_t:=OTr_GetText($hRoot_i; "text.text")
	$total_i:=$total_i+1
	If ($text_t="beta")
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Put/GetText failed."+Char(Carriage return)
	End if

	$date_d:=Current date
	OTr_PutDate($hRoot_i; "date.value"; $date_d)
	$total_i:=$total_i+1
	If (OTr_GetDate($hRoot_i; "date.value")=$date_d)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Put/GetDate failed."+Char(Carriage return)
	End if

	$time_h:=Current time
	OTr_PutTime($hRoot_i; "time.value"; $time_h)
	$total_i:=$total_i+1
	If (OTr_GetTime($hRoot_i; "time.value")=$time_h)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Put/GetTime failed."+Char(Carriage return)
	End if

	OTr_PutBoolean($hRoot_i; "bool.value"; True)
	$bool_i:=OTr_GetBoolean($hRoot_i; "bool.value")
	$total_i:=$total_i+1
	If ($bool_i=1)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Put/GetBoolean failed for True."+Char(Carriage return)
	End if

	OTr_PutBoolean($hRoot_i; "bool.value"; False)
	$bool_i:=OTr_GetBoolean($hRoot_i; "bool.value")
	$total_i:=$total_i+1
	If ($bool_i=0)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Put/GetBoolean failed for False."+Char(Carriage return)
	End if

	//MARK:- object put/get
	OTr_PutText($hObj_i; "inside"; "value")
	OTr_PutObject($hRoot_i; "obj.child"; $hObj_i)

	$hObjOut_i:=OTr_GetObject($hRoot_i; "obj.child")
	$total_i:=$total_i+1
	If ($hObjOut_i>0)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetObject did not return a handle."+Char(Carriage return)
	End if

	$total_i:=$total_i+1
	If (OTr_GetText($hObjOut_i; "inside")="value")
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Put/GetObject content check failed."+Char(Carriage return)
	End if

	OTr_PutText($hObj_i; "inside"; "changed")
	$total_i:=$total_i+1
	If (OTr_GetText($hObjOut_i; "inside")="value")
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"GetObject should return deep copy semantics."+Char(Carriage return)
	End if

	//MARK:- missing-path defaults
	$total_i:=$total_i+1
	If (OTr_GetLong($hRoot_i; "missing.path")=0)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Missing long default should be 0."+Char(Carriage return)
	End if

	$total_i:=$total_i+1
	If (OTr_GetText($hRoot_i; "missing.path")="")
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"Missing text default should be empty."+Char(Carriage return)
	End if

	//MARK:- done
	OTr_ClearAll

	If ($failed_i=0)
		ALERT(Current method name+" - all tests passed ("+String($passed_i)+"/"+String($total_i)+").")
	Else
		ALERT(Current method name+" - FAILED ("+String($failed_i)+"/"+String($total_i)+")."+Char(Carriage return)+$failures_t)
	End if
Else 
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 
