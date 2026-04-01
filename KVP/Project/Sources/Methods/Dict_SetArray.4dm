//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetArray (dict ID; key; ->array)

// Stores an array of values inside a dictionary.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key
//   $3 : Pointer : Array

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i; $type_i; $index_i; $count_i)
C_TEXT:C284($2; $key_t; $suffix_t)
C_POINTER:C301($3; $value_ptr)

$dictionary_i:=$1
$key_t:=$2
$value_ptr:=$3

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i))
	
	$type_i:=Type:C295($value_ptr->)
	$count_i:=Size of array:C274($value_ptr->)
	
	// Remove all previous entries related to the array
	Dict_Remove($dictionary_i; $key_t+".@")
	
	// Store the array value itself
	Dict_SetLongint($dictionary_i; $key_t+".selected"; $value_ptr->)
	Dict_SetLongint($dictionary_i; $key_t+".count"; Size of array:C274($value_ptr->))
	
	// Store the items in the array
	For ($index_i; 1; $count_i)
		$suffix_t:="."+String:C10($index_i)
		Case of 
			: (($type_i=Text array:K8:16) | ($type_i=String array:K8:15))
				Dict_SetText($dictionary_i; $key_t+$suffix_t; $value_ptr->{$index_i})
			: (($type_i=LongInt array:K8:19) | ($type_i=Integer array:K8:18))
				Dict_SetLongint($dictionary_i; $key_t+$suffix_t; $value_ptr->{$index_i})
			: ($type_i=Real array:K8:17)
				Dict_SetReal($dictionary_i; $key_t+$suffix_t; $value_ptr->{$index_i})
			: ($type_i=Boolean array:K8:21)
				Dict_SetBoolean($dictionary_i; $key_t+$suffix_t; $value_ptr->{$index_i})
			: ($type_i=Date array:K8:20)
				Dict_SetDate($dictionary_i; $key_t+$suffix_t; $value_ptr->{$index_i})
			: ($type_i=Pointer array:K8:23)
				Dict_SetPointer($dictionary_i; $key_t+$suffix_t; $value_ptr->{$index_i})
		End case 
	End for 
	
End if 

Dict_LockInternalState(False:C215)
