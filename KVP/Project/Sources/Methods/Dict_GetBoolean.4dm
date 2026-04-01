//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetBoolean (dict ID; key) --> Boolean

// Returns a Boolean value from a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Boolean : The key's value

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $key_t)
C_BOOLEAN:C305($0; $value_b)

$dictionary_i:=$1
$key_t:=$2

$value_b:=(Dict_GetValue($dictionary_i; $key_t)="True")

$0:=$value_b