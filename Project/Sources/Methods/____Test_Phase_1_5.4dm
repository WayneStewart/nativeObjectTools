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
	OTr_ClearAll
	$handle_i:=OTr_New
	
	//MARK:- OTr_SaveToText
	$json_t:=OTr_SaveToText($handle_i)
	$total_i:=$total_i+1
	If ($json_t="{}")
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_SaveToText expected {} but got: "+$json_t+Char:C90(Carriage return:K15:38)
	End if 
	
	$json_t:=OTr_SaveToText($handle_i; True:C214)
	$total_i:=$total_i+1
	If (Position:C15("{"; $json_t)>0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_SaveToText pretty output missing {."+Char:C90(Carriage return:K15:38)
	End if 
	
	//MARK:- OTr_SaveToFile
	$tempFile_t:=Temporary folder:C486+"OTR_Phase_1_5_Test.json"
	
	OTr_SaveToFile($handle_i; $tempFile_t)
	$readBack_t:=Document to text:C1236($tempFile_t; "UTF-8")
	$total_i:=$total_i+1
	If (Position:C15("{"; $readBack_t)>0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_SaveToFile did not create readable JSON file."+Char:C90(Carriage return:K15:38)
	End if 
	
	DELETE DOCUMENT:C159($tempFile_t)
	
	//MARK:- OTr_SaveToClipboard
	OTr_SaveToClipboard($handle_i)
	$json_t:=Get text from pasteboard:C524
	$total_i:=$total_i+1
	If (Position:C15("{"; $json_t)>0)
		$passed_i:=$passed_i+1
	Else 
		$failed_i:=$failed_i+1
		$failures_t:=$failures_t+"OTr_SaveToClipboard did not place JSON text on clipboard."+Char:C90(Carriage return:K15:38)
	End if 
	
	//MARK:- done
	OTr_ClearAll
	
	var $message_t : Text
	
	//MARK:- final report
	If ($failed_i=0)
		$message_t:=Current method name:C684+" - all tests passed ("+String:C10($passed_i)+"/"+String:C10($total_i)+")."
	Else 
		$message_t:=Current method name:C684+" - FAILED ("+String:C10($failed_i)+"/"+String:C10($total_i)+")."+Char:C90(Carriage return:K15:38)+$failures_t
	End if 
	ALERT:C41($message_t)
	SET TEXT TO PASTEBOARD:C523($message_t)
	
	//If ($failed_i=0)
	//ALERT(Current method name+" - all tests passed ("+String($passed_i)+"/"+String($total_i)+").")
	//Else 
	//ALERT(Current method name+" - FAILED ("+String($failed_i)+"/"+String($total_i)+")."+Char(Carriage return)+$failures_t)
	//End if 
	
	
Else 
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 
