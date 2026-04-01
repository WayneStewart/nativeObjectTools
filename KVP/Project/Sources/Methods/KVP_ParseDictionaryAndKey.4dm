//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: KVP_ParseDictionaryAndKey

// Method Type:    Private

// Parameters:
C_TEXT:C284($1; $KeyIdentifier_t)
C_POINTER:C301($2; $3)

// Local Variables:
C_LONGINT:C283($Position_i; $Dictionary_i; $ProcessNumber_i)
C_TEXT:C284($DictionaryName_t; $Key_t)

// Created by Wayne Stewart (Jul 26, 2012)
//     waynestewart@mac.com
//   
// ----------------------------------------------------

Dict_Init

$KeyIdentifier_t:=$1
$Position_i:=Position:C15("."; $1; *)  //  The * option is faster when 4D is compiled.
$DictionaryName_t:=Substring:C12($1; 1; $Position_i-1)
$Key_t:=Substring:C12($1; $Position_i+1; MAXTEXTLENBEFOREV11:K35:3)

Case of 
	: (Dict_APD_ID_i#0) & (Length:C16($DictionaryName_t)=1) & (Character code:C91($DictionaryName_t[[1]])=42)
		$Dictionary_i:=Dict_APD_ID_i  //  Return the dictionary ID
		//  If Dict_APD_ID_i has a value then:
		//     1/  It is an APD
		//     2/   It has already been initialised (see next case)
		
	: (Length:C16($DictionaryName_t)=1)  // Potentially an "Anonymous process dictionary"
		//  Why not just do $DictionaryName_t="*"?
		//  It's a lot faster doing it this way...
		
		If (Character code:C91($DictionaryName_t[[1]])=42)  //  Is it "*"?  (Once again - faster)
			//  Check to see if the APD has been initialised
			
			//  Build the APD name, this will only ever happen once per process
			$ProcessNumber_i:=Current process:C322
			$DictionaryName_t:="*APD"+String:C10($ProcessNumber_i)
			
			//  I could do this by calling Dict_Named but don't really need overhead
			$Dictionary_i:=Find in array:C230(<>Dict_Names_at; $DictionaryName_t)
			
			If (Dict_IsValid($Dictionary_i))  //  An existing dictionary with that name already exists. 
				//  This can only happen if it was created from a now closed process, 
				//    we should therefore delete the dictionary (no need to check contents).
				<>Dict_RetainCounts_ai{$dictionary_i}:=1  //  Just in case retain had been called
				Dict_Release($Dictionary_i)
			End if 
			
			//  Now we need to create the APD dictionary
			Dict_APD_ID_i:=Dict_New($DictionaryName_t)  // assign the number to the tracking variable
			$Dictionary_i:=Dict_APD_ID_i  //  Return the dictionary ID
			
		Else 
			//  It must be some other 1 character dictionary name
			$Dictionary_i:=Find in array:C230(<>Dict_Names_at; $DictionaryName_t)
			If ($Dictionary_i=-1)  //  Dictionary not declared, we will declare it!
				$Dictionary_i:=Dict_New($DictionaryName_t)
			End if 
			
		End if 
		
	Else 
		
		//  I could do this by calling Dict_Named but don't really need overhead
		//$Dictionary_i:=Dict_Named ($DictionaryName_t)
		
		$Dictionary_i:=Find in array:C230(<>Dict_Names_at; $DictionaryName_t)
		If ($Dictionary_i=-1)  //  Dictionary not declared, we will declare it!
			$Dictionary_i:=Dict_New($DictionaryName_t)
		End if 
		
		
End case 


$2->:=$Dictionary_i
$3->:=$Key_t