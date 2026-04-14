//%attributes = {"invisible":true}
// objectViewer
// Created by Wayne Stewart (2026-04-14)
//  Method is an autostart type
//     waynestewart@mac.com
// ----------------------------------------------------


var $ProcessID_i; $StackSize_i; $WindowID_i : Integer
var $Form_t; $DesiredProcessName_t : Text
var $Form_o : Object


// ----------------------------------------------------

$StackSize_i:=0
$Form_t:="objectViewer"
$DesiredProcessName_t:="$"+$Form_t

If (Current process name:C1392=$DesiredProcessName_t)
	$Form_o:=New object:C1471("objectPreview"; "")
	
	
	$WindowID_i:=Open form window:C675($Form_t; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4; *)
	SET WINDOW TITLE:C213("Object Viewer")
	DIALOG:C40($Form_t; $Form_o)
	CLOSE WINDOW:C154
	
	
	
Else 
	// This version allows for any number of processes
	// $ProcessID_i:=New Process(Current method name;$StackSize_i;$DesiredProcessName_t)
	
	// On the other hand, this version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 
