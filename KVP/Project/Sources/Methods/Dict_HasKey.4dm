//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_HasKey (dict ID; key) --> Boolean

// Checks whether a dictionary contains a given key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Boolean : True if the key exists

// Created by Rob Laveaux
// ----------------------------------------------------

C_BOOLEAN:C305($0; $hasKey_b)
C_TEXT:C284($2; $key_t)
C_LONGINT:C283($1; $dictionary_i; $index_i)

$dictionary_i:=$1
$key_t:=$2

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i; True:C214))
	
	// Check if the key exists
	$index_i:=Find in array:C230(<>Dict_Keys_at{$dictionary_i}; $key_t)
	$hasKey_b:=($index_i#-1)
	
End if 

Dict_LockInternalState(False:C215)

$0:=$hasKey_b