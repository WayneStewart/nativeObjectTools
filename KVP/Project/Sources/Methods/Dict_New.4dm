//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_New ({name}) --> Longint

// Creates a new dictionary and returns a reference to it.

// Access: Shared

// Parameters: 
//   $1 : Text : Name (optional)

// Returns: 
//   $0 : Longint : Dictionary ID

// Created by Rob Laveaux

// Modified by: Wayne Stewart (Feb 13, 2012)


// ----------------------------------------------------

C_TEXT:C284($1; $name_t)
C_LONGINT:C283($0; $dictionary_i; $ExistingDictionary_i; $count_i)

Dict_LockInternalState(True:C214)  // Includes call to Dict_Init

// Increment the Dictionary Counter
<>Dict_SequentialCounter_i:=<>Dict_SequentialCounter_i+1
If (Count parameters:C259>=1)
	$name_t:=$1
Else 
	$name_t:="Dictionary: "+String:C10(<>Dict_SequentialCounter_i)
End if 

// Check if there is an unused dictionary left
$dictionary_i:=Find in array:C230(<>Dict_RetainCounts_ai; 0)

// If all dictionaries are in use, create a new one
If ($dictionary_i=-1)
	$dictionary_i:=Size of array:C274(<>Dict_Names_at)+1
	INSERT IN ARRAY:C227(<>Dict_Names_at; $dictionary_i)
	INSERT IN ARRAY:C227(<>Dict_RetainCounts_ai; $dictionary_i)
	INSERT IN ARRAY:C227(<>Dict_Keys_at; $dictionary_i)
	INSERT IN ARRAY:C227(<>Dict_Values_at; $dictionary_i)
	INSERT IN ARRAY:C227(<>Dict_DataTypes_ai; $dictionary_i)
End if 

// Set the retain count to 1
<>Dict_RetainCounts_ai{$dictionary_i}:=1  //  Must be run before dictionry is named

//  Name the dictionary, this might report an error!
Dict_Name($dictionary_i; $name_t)

// Make sure the dictionary is empty (because of a side effect of INSERT ELEMENT)
$count_i:=Size of array:C274(<>Dict_Keys_at{$dictionary_i})
If ($count_i>0)
	DELETE FROM ARRAY:C228(<>Dict_Keys_at{$dictionary_i}; 1; $count_i)
End if 
$count_i:=Size of array:C274(<>Dict_Values_at{$dictionary_i})
If ($count_i>0)
	DELETE FROM ARRAY:C228(<>Dict_Values_at{$dictionary_i}; 1; $count_i)
End if 
$count_i:=Size of array:C274(<>Dict_DataTypes_ai{$dictionary_i})
If ($count_i>0)
	DELETE FROM ARRAY:C228(<>Dict_DataTypes_ai{$dictionary_i}; 1; $count_i)
End if 

Dict_LockInternalState(False:C215)

$0:=$dictionary_i
