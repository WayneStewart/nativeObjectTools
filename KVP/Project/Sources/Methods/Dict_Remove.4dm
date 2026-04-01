//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Remove (dict ID; key)

// Removes a key from a dictionary.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: Nothing

// Created by Rob Laveaux
// Modified by Gary Boudreaux on Dec 22, 2008
//   Corrected labeling of $2 in header
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i; $index_i)
C_TEXT:C284($2; $key_t)

$dictionary_i:=$1
$key_t:=$2

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i; True:C214))
	// Lookup the key and remove it from the dictionary
	$index_i:=Find in array:C230(<>Dict_Keys_at{$dictionary_i}; $key_t)
	While ($index_i#-1)
		DELETE FROM ARRAY:C228(<>Dict_Keys_at{$dictionary_i}; $index_i)
		DELETE FROM ARRAY:C228(<>Dict_Values_at{$dictionary_i}; $index_i)
		DELETE FROM ARRAY:C228(<>Dict_DataTypes_ai{$dictionary_i}; $index_i)  // wbs (Oct 2, 2009), need to remove element from Types array
		// Continue searching (useful if we specify a pattern to be matched)
		$index_i:=Find in array:C230(<>Dict_Keys_at{$dictionary_i}; $key_t)
	End while 
	
End if 

Dict_LockInternalState(False:C215)