//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetTime (dict ID; key) --> Time

// Returns a time value from a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Time : The key's value

// Created by Rob Laveaux
// ----------------------------------------------------

C_TIME:C306($0; $value_time)
C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $key_t)

$dictionary_i:=$1
$key_t:=$2

$value_time:=Time:C179(Dict_GetValue($dictionary_i; $key_t))

$0:=$value_time