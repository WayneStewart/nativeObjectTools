//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_DataTypes (dict ID; ->array)

// Fills an array with the data types stored in a dictionary.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Pointer : Array to receive data types

// Returns: Nothing

// Created by Wayne Stewart
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_POINTER:C301($2; $array_ptr)

$dictionary_i:=$1
$array_ptr:=$2

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i))
	
	// Copy the array with the values
	If (Type:C295($array_ptr->)=LongInt array:K8:19)
		COPY ARRAY:C226(<>Dict_DataTypes_ai{$dictionary_i}; $array_ptr->)
	End if 
	
End if 

Dict_LockInternalState(False:C215)


