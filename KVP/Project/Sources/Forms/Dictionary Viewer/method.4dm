C_POINTER:C301($SelectedDictionary_ptr)
C_LONGINT:C283($i)
C_BOOLEAN:C305($CloseNow_b; $QuitNow_b; <>Dict_FoundationPresent_b)

If (<>Dict_FoundationPresent_b)
	EXECUTE METHOD:C1007("Fnd_Wnd_CloseNow"; $CloseNow_b)
	EXECUTE METHOD:C1007("Fnd_Gen_QuitNow"; $QuitNow_b)
	//EXECUTE METHOD
End if 

Case of 
	: (Form event code:C388=On Close Box:K2:21)
		If (<>Dict_FoundationPresent_b) & (Macintosh option down:C545)
			EXECUTE METHOD:C1007("Fnd_Wnd_CloseAllWindows"; *)
		End if 
		CANCEL:C270
		
	: (Dict_CloseDialog) | ($CloseNow_b) | ($QuitNow_b)
		CANCEL:C270
		Dict_CloseDialog(False:C215)  //  Reset it for next time!
		
		
	: (Form event code:C388=On Timer:K2:25)
		Dict_UpdateForm
		
	: (Form event code:C388=On Activate:K2:9)
		Dict_UpdateForm
		If (<>Dict_FoundationPresent_b)
			EXECUTE METHOD:C1007("Fnd_Gen_MenuBar")
		End if 
		
		
	: (Form event code:C388=On Outside Call:K2:11)
		Dict_UpdateForm
		
	: (Form event code:C388=On Load:K2:1)  //  Does this seem strange?
		//  On Load will only be called once, so why have it at the top of the case staement?
		SET TIMER:C645(60*15)  //  Update every 15 seconds
		$SelectedDictionary_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Selected Dictionary")
		If (Size of array:C274(<>Dict_Names_at)>0)
			$SelectedDictionary_ptr->:=1
		Else 
			$SelectedDictionary_ptr->:=0
		End if 
		
		Dict_UpdateForm
End case 
