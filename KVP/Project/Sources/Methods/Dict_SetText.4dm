//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetText (dict ID; key; text value)

// Assigns a text value to a dictionary given a key

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
//   $3 : Text : Value to store

// Returns: Nothing

// Created by Rob Laveaux
// Modified by Gary Boudreaux on Dec 22, 2008
//   Corrected description of data type of $3 in header
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $3; $key_t; $value_t)

$dictionary_i:=$1
$key_t:=$2
$value_t:=$3

Dict_SetValue($dictionary_i; $key_t; $value_t; Is text:K8:3)