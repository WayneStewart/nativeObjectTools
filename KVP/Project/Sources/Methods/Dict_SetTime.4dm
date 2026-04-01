//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetTime (dict ID; key; time value)

// Assigns a time value to a dictionary given a key

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
//   $3 : Time : Value to store

// Returns: Nothing

// Created by Rob Laveaux
// Modified by Gary Boudreaux on Dec 22, 2008
//   Corrected description of data type of $3 in header
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $key_t)
C_TIME:C306($3; $value_time)

$dictionary_i:=$1
$key_t:=$2
$value_time:=$3

Dict_SetValue($dictionary_i; $key_t; String:C10($value_time; HH MM SS:K7:1); Is time:K8:8)
