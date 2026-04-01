//%attributes = {"invisible":true}


If (True:C214)
	
	
	C_LONGINT:C283($MyDictionary_i; $NewDictionary_i; $dictionary_i; $ExistingDictionary_i; $RetreivedDictionary_i)
	C_TEXT:C284($NewName_t; $textVar_t)
	
	$dictionary_i:=4
	$NewName_t:="My dictionary"
	$ExistingDictionary_i:=3
	
	//Dict_BugAlert ("Dict_Name";"An attempt to name a dictionary (ID "+String($dictionary_i)+") with the name \""+$NewName_t+"\" has failed."+Char(Carriage return)+"Another dictionary (ID "+String($ExistingDictionary_i)+") already has that name.")\
				
	//
	//
	//KVP_New ("Original")
	//
	//
	//
	//KVP_Text ("Original.Name";"Wayne")
	//
	//ARRAY TEXT($MyChildren_at;4)
	//
	//$MyChildren_at{1}:="Kirsty"
	//$MyChildren_at{2}:="Andrew"
	//$MyChildren_at{3}:="Penny"
	//$MyChildren_at{4}:="Alice"
	//
	//KVP_SetArray ("Original.Child";->$MyChildren_at)
	//
	//
	//ALERT(KVP_Text ("Original.Child.1")+" father is "+KVP_Text ("Original.Name"))
	//KVP_Release ("Original")
	
	
	
	
	//
	//C_TEXT(TempVar_t)
	//C_TEXT(OtherVar_t)
	//C_POINTER(MyPointer_ptr)
	//
	//$MyDictionary_i:=Dict_New 
	//
	//ARRAY TEXT(Actors_at;2)
	//
	//Actors_at{1}:="Fred Astaire"
	//Actors_at{2}:="Ginger Rogers"
	//
	//
	//
	//
	//Dict_SetPointer ($MyDictionary_i;"Actor";->Actors_at{2})
	//
	//Actors_at{2}:="Eric Blore"
	//
	//$temp_ptr:=Dict_GetPointer ($MyDictionary_i;"Actor")
	//ALERT($temp_ptr->)
	//
	//Dict_Release ($MyDictionary_i)
	//
	//
	
	
	
	
	If (True:C214)
		
		$MyDictionary_i:=Dict_New
		
		
		Dict_Name($MyDictionary_i; "Original Dictionary")
		
		Dict_SetText($MyDictionary_i; "Name"; "Wayne Stewart")
		Dict_SetDate($MyDictionary_i; "Date of Birth"; !1962-07-26!)
		
		ARRAY TEXT:C222($MyChildren_at; 4)
		
		$MyChildren_at{1}:="Kirsty"
		$MyChildren_at{2}:="Andrew"
		$MyChildren_at{3}:="Penny"
		$MyChildren_at{4}:="Alice"
		
		Dict_SetArray($MyDictionary_i; "Child"; ->$MyChildren_at)
		
		$NewDictionary_i:=Dict_Copy($MyDictionary_i; "Modified Dictionary")
		
		Dict_SetArrayText(Dict_Named("Modified Dictionary"); "Child"; 1; "Kersti Priebbenow née Stewart")
		
		
		KVP_SetChild("Original Dictionary"; "Modified Dictionary"; ""; "*")
		
		//Dict_SaveToFile ($MyDictionary_i;Get 4D folder(Database Folder)+"Original.xml")
		//Dict_SaveToFile (Dict_Named ("Modified Dictionary");Get 4D folder(Database Folder)+"Modified.xml")
		
		SET TEXT TO PASTEBOARD:C523(Dict_SaveToText($MyDictionary_i))
		
		//SHOW ON DISK(Get 4D folder(Database Folder);*)
		
		KVP_Remove("Original Dictionary.Modified@")
		//$RetreivedDictionary_i:=Dict_GetChild ($MyDictionary_i;"Modified Dictionary";"Copy #2")
		
		
		Dict_Release($MyDictionary_i)
		//Dict_Release (Dict_Named ("Modified Dictionary"))
		Dict_Release($RetreivedDictionary_i)
		
		$textVar_t:=Get text from pasteboard:C524
		
		$Dictionary_i:=Dict_LoadFromText($textVar_t)
		
		Dict_Release($Dictionary_i)
		
		
	End if 
	
End if 