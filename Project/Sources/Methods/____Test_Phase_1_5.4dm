//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_1_5

// Short unit tests for Phase 1.5 simple export methods.

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

	var $handle_i : Integer
	var $json_t : Text
	var $tempFile_t : Text
	var $readBack_t : Text

	//MARK:- baseline
	OT ClearAll
	$handle_i:=OT New

	//MARK:- OT SaveToText
	$json_t:=OT SaveToText($handle_i)
	$total_i:=$total_i+1
	If ($json_t="{}")
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT SaveToText expected {} but got: "+$json_t+Char(Carriage return)
	End if

	$json_t:=OT SaveToText($handle_i; True)
	$total_i:=$total_i+1
	If (Position("{"; $json_t)>0)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT SaveToText pretty output missing {."+Char(Carriage return)
	End if

	//MARK:- OT SaveToFile
	$tempFile_t:=Temporary folder+"OTR_Phase_1_5_Test.json"

	OT SaveToFile($handle_i; $tempFile_t)
	$readBack_t:=Document to text($tempFile_t; "UTF-8")
	$total_i:=$total_i+1
	If (Position("{"; $readBack_t)>0)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT SaveToFile did not create readable JSON file."+Char(Carriage return)
	End if

	DELETE DOCUMENT($tempFile_t)

	//MARK:- OT SaveToClipboard
	OT SaveToClipboard($handle_i)
	$json_t:=Get text from pasteboard
	$total_i:=$total_i+1
	If (Position("{"; $json_t)>0)
		$passed_i:=$passed_i+1
	Else
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OT SaveToClipboard did not place JSON text on clipboard."+Char(Carriage return)
	End if

	//MARK:- done
	OT ClearAll

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
