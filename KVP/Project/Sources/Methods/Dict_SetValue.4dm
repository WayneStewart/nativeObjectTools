//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetValue (dict ID; key; value as text; data type)

// Assigns a value to a dictionary given a key

// Access: Private

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
//   $3 : Text : Value to store
//   $4 : Longint : Data type

// Returns: Nothing

// Created by Rob Laveaux
// Modified by Dave Batton on Sep 23, 2007
//   Changed the APPEND TO ARRAY calls to 4D 2003 compatible code.
// Modified by Gary Boudreaux on Dec 22, 2008
//   Added description of $4 in header
// ----------------------------------------------------

C_LONGINT:C283($1; $4; $dictionary_i; $type_i; $index_i)
C_TEXT:C284($2; $3; $key_t; $value_t)

$dictionary_i:=$1
$key_t:=$2
$value_t:=$3
$type_i:=$4

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i; True:C214))
	
	// Check if the key exists
	$index_i:=Find in array:C230(<>Dict_Keys_at{$dictionary_i}; $key_t)
	
	If ($index_i=-1)
		// Add the new key.
		$index_i:=Size of array:C274(<>Dict_Keys_at{$dictionary_i})+1
		INSERT IN ARRAY:C227(<>Dict_Keys_at{$dictionary_i}; $index_i)
		INSERT IN ARRAY:C227(<>Dict_Values_at{$dictionary_i}; $index_i)
		INSERT IN ARRAY:C227(<>Dict_DataTypes_ai{$dictionary_i}; $index_i)
	End if 
	
	<>Dict_Keys_at{$dictionary_i}{$index_i}:=$key_t
	<>Dict_Values_at{$dictionary_i}{$index_i}:=$value_t
	<>Dict_DataTypes_ai{$dictionary_i}{$index_i}:=$type_i
	
End if 

Dict_LockInternalState(False:C215)
