//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Values (dict ID; ->array)

// Fills an array with the values in a dictionary.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Pointer : Array to receive values

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_POINTER:C301($2; $array_ptr)

$dictionary_i:=$1
$array_ptr:=$2

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i))
	
	// Copy the array with the values
	If (Type:C295($array_ptr->)=Text array:K8:16)
		COPY ARRAY:C226(<>Dict_Values_at{$dictionary_i}; $array_ptr->)
	End if 
	
End if 

Dict_LockInternalState(False:C215)
