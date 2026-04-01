//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetLongint (dict ID; key; longint value)

// Assigns a longint value to a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
//   $3 : Longint : Value to store

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $3; $dictionary_i; $value_i)
C_TEXT:C284($2; $key_t)

$dictionary_i:=$1
$key_t:=$2
$value_i:=$3

Dict_SetValue($dictionary_i; $key_t; String:C10($value_i); Is longint:K8:6)
