//%attributes = {"invisible":true,"shared":true}
// Dict_DisplayUsage
// Created by Wayne Stewart (Jul 24, 2012)
//  Method is an autostart type
//     waynestewart@mac.com

Dict_Init

C_LONGINT:C283($1; $ProcessID_i)
If (Count parameters:C259=1)
	Dict_CloseDialog(False:C215)
	$ProcessID_i:=Open form window:C675("Dictionary Viewer"; Plain form window:K39:10; On the right:K39:3; At the top:K39:5)
	SET WINDOW TITLE:C213("Dictionary Viewer")
	If (<>Dict_FoundationPresent_b)
		EXECUTE METHOD:C1007("Fnd_Menu_Window_Add")
	End if 
	DIALOG:C40("Dictionary Viewer")
	If (<>Dict_FoundationPresent_b)
		EXECUTE METHOD:C1007("Fnd_Menu_Window_Remove")
	End if 
	CLOSE WINDOW:C154
Else 
	// This version allows for any number of processes
	// $ProcessID_i:=New Process(Current method name;128*1024;Current method name;0)
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; 128*1024; "$"+Current method name:C684; 0; *)
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 