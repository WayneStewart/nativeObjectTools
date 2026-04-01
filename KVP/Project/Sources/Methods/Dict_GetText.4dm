//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetText (dict ID; key) --> Text

// Returns a text value from a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Text : The key's value

// Created by Rob Laveaux
// ----------------------------------------------------

C_TEXT:C284($0; $2; $key_t; $value_t)
C_LONGINT:C283($1; $dictionary_i; $index_i)

$dictionary_i:=$1
$key_t:=$2

$value_t:=Dict_GetValue($dictionary_i; $key_t)

$0:=$value_t