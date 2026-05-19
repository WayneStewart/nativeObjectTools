//%attributes = {"invisible":true,"shared":true,"preemptive":"incapable"}
// OTr ABOUT
// Created by Wayne Stewart (2026-05-10)
//  Method is an autostart type
//     waynestewart@mac.com
// ----------------------------------------------------

var $ProcessID_i; $StackSize_i; $WindowID_i : Integer
var $Form_t; $DesiredProcessName_t : Text
var $Form_o : Object
var $htmlFile_f : 4D:C1709.File


// ----------------------------------------------------

$StackSize_i:=0
$Form_t:=Current method name:C684
$DesiredProcessName_t:="$"+($Form_t)

OTr_z_Init

If (Current process name:C1392=$DesiredProcessName_t)
	
	$Form_o:=New object:C1471()
	$form_o.webAreaURL:=""
	$htmlFile_f:=File:C1566("/RESOURCES/about/index.html")
	If ($htmlFile_f.exists)
		$form_o.webAreaURL:=Convert path system to POSIX:C1106($htmlFile_f.platformPath)
		If (Is macOS:C1572)
			$form_o.webAreaURL:="file://"+$form_o.webAreaURL
		Else 
			$form_o.webAreaURL:="file:///"+Replace string:C233($form_o.webAreaURL; "\\"; "/")
		End if 
		
		$WindowID_i:=Open form window:C675($Form_t; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4; *)
		SET WINDOW TITLE:C213("OTr Reference")
		DIALOG:C40($Form_t; $Form_o)
		CLOSE WINDOW:C154
		
	Else 
		ALERT:C41("Documentation HTML not found at: "+$htmlFile_f.path)
	End if 
	
Else 
	// This version allows for any number of processes
	// $ProcessID_i:=New Process(Current method name;$StackSize_i;$DesiredProcessName_t)
	
	// On the other hand, this version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 
