//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Keys (dict ID; ->keys array)

// Fills an array with the keys in a dictionary.

// Access Type: Protected

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Pointer : Text array

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_POINTER:C301($2; $array_ptr)

$dictionary_i:=$1
$array_ptr:=$2

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i))
	
	// Copy the array with the keys
	If (Type:C295($array_ptr->)=Text array:K8:16)
		COPY ARRAY:C226(<>Dict_Keys_at{$dictionary_i}; $array_ptr->)
	End if 
	
End if 

Dict_LockInternalState(False:C215)
