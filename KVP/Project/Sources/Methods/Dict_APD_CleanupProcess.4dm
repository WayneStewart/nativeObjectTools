//%attributes = {"invisible":true}
// Dict_APD_CleanupProcess
// Created by Wayne Stewart (Aug 9, 2012)
//  Method is an autostart type
//     waynestewart@mac.com

C_LONGINT:C283($1; $ProcessID_i; $NumberOfProcesses_i; $Dictionary_i; $ProcessState_i; $ProcessTime_i)
C_BOOLEAN:C305($CloseNow_b; $QuitNow_b)
C_TEXT:C284($DictionaryName_t; $ProcessName_t)

If (False:C215)  //  Copy this to your Compiler Method!
	C_LONGINT:C283(Dict_APD_CleanupProcess; $1)
End if 

If (Count parameters:C259=1)
	
	Dict_Init
	
	
	Repeat 
		$Dictionary_i:=Find in array:C230(<>Dict_Names_at; "*APD@")
		While ($Dictionary_i>-1)
			$ProcessID_i:=Num:C11(<>Dict_Names_at{$Dictionary_i})
			
			If (Process state:C330($ProcessID_i)=Aborted:K13:1)
				Dict_Release($Dictionary_i)
			Else 
				PROCESS PROPERTIES:C336($ProcessID_i; $ProcessName_t; $ProcessState_i; $ProcessTime_i)
				If (Dict_EnabledProcess($ProcessName_t))
				Else 
					Dict_Release($Dictionary_i)
				End if 
				
			End if 
			$Dictionary_i:=$Dictionary_i+1
			$Dictionary_i:=Find in array:C230(<>Dict_Names_at; "*APD@"; $Dictionary_i)
		End while 
		
		If (<>Dict_FoundationPresent_b)
			EXECUTE METHOD:C1007("Fnd_Gen_QuitNow"; $QuitNow_b)
		End if 
		
		DELAY PROCESS:C323(Current process:C322; 150)  //  Check again in 2.5 seconds
	Until ((Not:C34(<>Dict_APD_Cleanup_b)) | ($CloseNow_b) | ($QuitNow_b))
	
Else 
	// This version allows for any number of processes
	// $ProcessID_i:=New Process(Current method name;128*1024;Current method name;0)
	// This version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; 128*1024; "$"+Current method name:C684; 0; *)
	RESUME PROCESS:C320($ProcessID_i)
	//SHOW PROCESS($ProcessID_i)
	//BRING TO FRONT($ProcessID_i)
End if 

