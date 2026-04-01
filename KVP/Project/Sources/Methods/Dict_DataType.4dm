//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_DataType (dict ID; key name) --> Number

// Returns the data type of a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Longint : Data type

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($0; $1; $type_i; $index_i; $dictionary_i)
C_TEXT:C284($2; $key_t)

$dictionary_i:=$1
$key_t:=$2

Dict_LockInternalState(True:C214)

$type_i:=Is undefined:K8:13

If (Dict_IsValid($dictionary_i; True:C214))
	
	// Lookup the key and get its associated value
	$index_i:=Find in array:C230(<>Dict_Keys_at{$dictionary_i}; $key_t)
	If ($index_i#-1)
		$type_i:=<>Dict_DataTypes_ai{$dictionary_i}{$index_i}
	End if 
	
End if 

Dict_LockInternalState(False:C215)

$0:=$type_i