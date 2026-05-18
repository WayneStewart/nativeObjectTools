var $o : Object
$o:=FORM Event:C1606

C_BOOLEAN:C305($CloseNow_b; $QuitNow_b)


//If (Storage.log.foundationPresent)
//EXECUTE METHOD("Fnd_Wnd_CloseNow"; $CloseNow_b)
//EXECUTE METHOD("Fnd_Gen_QuitNow"; $QuitNow_b)
//EXECUTE METHOD("Fnd_Gen_FormMethod"; $QuitNow_b)
//End if 


Case of 
	: ($o.code=On Load:K2:1)
		WA SET PREFERENCE:C1041(*; "webAreaDocs"; WA enable Web inspector:K62:7; True:C214)
		
	: ($o.code=On Close Box:K2:21)
		//If (Macintosh option down) & (Storage.log.foundationPresent)
		//If (Storage.log.foundationPresent)
		//EXECUTE METHOD("Fnd_Wnd_CloseAllWindows")
		//End if 
		//End if 
		CANCEL:C270
		
	: ($CloseNow_b) | ($QuitNow_b)
		CANCEL:C270
		
End case 

