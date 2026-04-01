//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetBoolean (dict ID; key; Boolean value)

// Assigns a Boolean value to a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
//   $3 : Boolean : Value to store

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $key_t)
C_BOOLEAN:C305($3; $value_i)

$dictionary_i:=$1
$key_t:=$2
$value_i:=$3

Dict_SetValue($dictionary_i; $key_t; String:C10(Num:C11($value_i); "True;;False"); Is boolean:K8:9)
