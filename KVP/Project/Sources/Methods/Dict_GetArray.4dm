//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetArray (dict ID; key name; ->values)

// Returns an array of values from a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
//   $3 : Pointer : Text array to receive values

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
	
	// Clear the contents of the array
	$count_i:=Size of array:C274($value_ptr->)
	If ($count_i>0)
		DELETE FROM ARRAY:C228($value_ptr->; 1; $count_i)
	End if 
	
	// Resize the array to the required size
	$count_i:=Dict_GetLongint($dictionary_i; $key_t+".count")
	If ($count_i>0)
		INSERT IN ARRAY:C227($value_ptr->; 1; $count_i)
	End if 
	
	// Set the selected value
	$value_ptr->:=Dict_GetLongint($dictionary_i; $key_t+".selected")
	
	// Read the items
	For ($index_i; 1; $count_i)
		
		$suffix_t:="."+String:C10($index_i)
		
		Case of 
			: (($type_i=Text array:K8:16) | ($type_i=String array:K8:15))
				$value_ptr->{$index_i}:=Dict_GetText($dictionary_i; $key_t+$suffix_t)
			: (($type_i=LongInt array:K8:19) | ($type_i=Integer array:K8:18))
				$value_ptr->{$index_i}:=Dict_GetLongint($dictionary_i; $key_t+$suffix_t)
			: ($type_i=Real array:K8:17)
				$value_ptr->{$index_i}:=Dict_GetReal($dictionary_i; $key_t+$suffix_t)
			: ($type_i=Boolean array:K8:21)
				$value_ptr->{$index_i}:=Dict_GetBoolean($dictionary_i; $key_t+$suffix_t)
			: ($type_i=Date array:K8:20)
				$value_ptr->{$index_i}:=Dict_GetDate($dictionary_i; $key_t+$suffix_t)
			: ($type_i=Pointer array:K8:23)
				$value_ptr->{$index_i}:=Dict_GetPointer($dictionary_i; $key_t+$suffix_t)
		End case 
		
	End for 
	
End if 

Dict_LockInternalState(False:C215)
