//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Named (name}) --> Dictionary Id
// Returns the ID of a dictionary after passing the name
// Access: Shared

// Parameters: 
//   $1 : Text    : Dictionary Name

// Returns: 
//   $0 : longint : Dictionary ID

// Created by Wayne Stewart (Feb 13, 2012)
// This is identical to the Dict_ID method

// ----------------------------------------------------

C_LONGINT:C283($0; $dictionary_i; $element_i)
C_TEXT:C284($1; $name_t)

$name_t:=$1

If ($name_t="*")  //  "Anonymous process dictionary"
	$name_t:="*APD"+String:C10(Current process:C322)
End if 

$dictionary_i:=0

Dict_LockInternalState(True:C214)

$element_i:=Find in array:C230(<>Dict_Names_at; $name_t)
If ($element_i>0)
	$dictionary_i:=$element_i
End if 

Dict_LockInternalState(False:C215)

$0:=$dictionary_i
