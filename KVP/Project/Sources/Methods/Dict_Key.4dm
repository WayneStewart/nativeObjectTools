//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_Key (dict ID; key number) --> Text

// Returns the nth key from a dictionary.

// Access: Private

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Longint : Key number

// Returns: 
//   $0 : Text : The key's value as text

// Created by Rob Laveaux
// Modified by Gary Boudreaux on Dec 22, 2008
//   Corrected description of data type of $0 and data type and description of $2 in header
//   Added assignment of $2 to $index_i before it is used
// ----------------------------------------------------

C_LONGINT:C283($1; $2; $dictionary_i; $index_i)
C_TEXT:C284($0; $key_t)

$dictionary_i:=$1
$index_i:=$2  //GB20081222 - added this assignment that seems to have been overlooked

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i))
	
	// Return the value of the nth key
	If (($index_i>0) & ($index_i<=Size of array:C274(<>Dict_Keys_at{$dictionary_i})))
		$key_t:=<>Dict_Keys_at{$dictionary_i}{$index_i}
	End if 
	
End if 

Dict_LockInternalState(False:C215)

$0:=$key_t