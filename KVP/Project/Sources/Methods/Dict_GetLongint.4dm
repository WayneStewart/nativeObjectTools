//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetLongint (dict ID; key) --> Longint

// Returns a longint value from a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Longint : The key's value

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($0; $1; $value_i; $dictionary_i)
C_TEXT:C284($2; $key_t)

$dictionary_i:=$1
$key_t:=$2

$value_i:=Num:C11(Dict_GetValue($dictionary_i; $key_t))

$0:=$value_i