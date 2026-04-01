//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetValue (dict ID; key) --> Text

// Returns a value from a dictionary given a key

// Access: Private

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Text : The key's value as text

// Created by Rob Laveaux
// Modified by Gary Boudreaux on Dec 22, 2008
//   Corrected description of data type of $0 in header
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i; $index_i)
C_TEXT:C284($0; $2; $value_t; $key_t)

$dictionary_i:=$1
$key_t:=$2

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i; True:C214))
	
	// Lookup the key and get its associated value
	$index_i:=Find in array:C230(<>Dict_Keys_at{$dictionary_i}; $key_t)
	If ($index_i#-1)
		$value_t:=<>Dict_Values_at{$dictionary_i}{$index_i}
	End if 
	
End if 


Dict_LockInternalState(False:C215)

$0:=$value_t