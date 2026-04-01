//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Name (dict ID {; new name}) --> Text

// Allows you to set the dictionary name and then
// returns the name of the dictionary.
//  NB. Dictionary names must be unique, 
//  if they are not an error will be reported and
//  the name will be changed to include a suffix

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text    : New Dictionary Name  {Optional}

// Returns: 
//   $0 : Text : Dictionary Name

// Created by Rob Laveaux

// Modified by: Wayne Stewart (Mar 10, 2010)
//   Added the ability to set the Dictionary name

// Modified by: Wayne Stewart (Feb 13, 2012)
//   Dictionary names must be unique,
//     if they are not an error will be reported
// ----------------------------------------------------

C_TEXT:C284($0; $name_t)
C_LONGINT:C283($1; $dictionary_i; $ExistingDictionary_i)
C_TEXT:C284($2; $Name_t; <>Dict_StructureName_t)

$dictionary_i:=$1

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i))  // Only bother if this really is a dictionary
	
	If (Count parameters:C259=2)
		<>Dict_Names_at{$dictionary_i}:=""  // Set this name to blank, this will prevent confusion
		
		$Name_t:=$2  // This is the new name
		$ExistingDictionary_i:=Find in array:C230(<>Dict_Names_at; $Name_t)  //  Look for that name in the list of dictionaries
		
		Case of 
			: ($ExistingDictionary_i=-1)
				<>Dict_Names_at{$dictionary_i}:=$Name_t
				If (<>Dict_StructureName_t="@KVP.4d@")
				Else 
					EXECUTE METHOD:C1007("Host_Dict_SetVariable"; *; "OK"; "1"; "Error"; "0")
				End if 
				
			: ($ExistingDictionary_i=$dictionary_i)  //  Trying to rename it with its existing name, this shouldn't happen
				If (<>Dict_StructureName_t="@KVP.4d@")  // don't do anything, but still need to set OK
				Else 
					EXECUTE METHOD:C1007("Host_Dict_SetVariable"; *; "OK"; "1"; "Error"; "0")
				End if 
				
			Else 
				<>Dict_Names_at{$dictionary_i}:=$name_t+" <"+String:C10(<>Dict_SequentialCounter_i)+">"
				If (<>Dict_StructureName_t="@KVP.4d@")
				Else 
					EXECUTE METHOD:C1007("Host_Dict_SetVariable"; *; "OK"; "0"; "Error"; "-17001")
					Dict_ErrorDetails("Attempting to name Dictionary ID: "+String:C10($dictionary_i)+" with the name \""+$Name_t+"\" has failed."+Char:C90(Carriage return:K15:38)+\
						"Another dictionary (ID: "+String:C10($ExistingDictionary_i)+") already has that name."+Char:C90(Carriage return:K15:38)+\
						"The dictionary has been renamed: \""+<>Dict_Names_at{$dictionary_i}+"\"")
				End if 
				
		End case 
		
	End if 
	
	$name_t:=<>Dict_Names_at{$dictionary_i}  //  Return the new name
End if 

Dict_LockInternalState(False:C215)

$0:=$name_t