//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetPointer (dict ID; key; pointer)

// Assigns a pointer value to a dictionary given a key

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text    : Key name
//   $3 : Pointer : Pointer to store

// Returns: Nothing

// Created by Rob Laveaux

//  Wayne Stewart
//  The initial version of this procedure worked in 2004
//   it suffered with the conversion to v11 :(
//   This part works OK but the retrieval doesn't

// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i; $tableNum_i; $fieldNum_i)
C_TEXT:C284($2; $key_t; $variableName_t)
C_POINTER:C301($3; $value_ptr)

$dictionary_i:=$1
$key_t:=$2
$value_ptr:=$3

// Convert the pointer to a text
RESOLVE POINTER:C394($value_ptr; $variableName_t; $tableNum_i; $fieldNum_i)
$variableName_t:=$variableName_t+";"+String:C10($tableNum_i)+";"+String:C10($fieldNum_i)
Dict_SetValue($dictionary_i; $key_t; $variableName_t; Is pointer:K8:14)
