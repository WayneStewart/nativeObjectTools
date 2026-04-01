//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_ID (name) --> Number

// Returns the reference number of the dictionary with the specified name.
// Returns 0 if the dictionary does not exist.

// Access: Shared

// Parameters: 
//   $1 : Text : A dictionary name

// Returns: 
//   $0 : Longint : The dictionary's reference number

// Created by Dave Batton on Sep 23, 2007
// ----------------------------------------------------

C_LONGINT:C283($0; $dictionary_i; $element_i)
C_TEXT:C284($1; $name_t)

$name_t:=$1

$dictionary_i:=0

Dict_LockInternalState(True:C214)

$element_i:=Find in array:C230(<>Dict_Names_at; $name_t)
If ($element_i>0)
	$dictionary_i:=$element_i
End if 

Dict_LockInternalState(False:C215)

$0:=$dictionary_i
