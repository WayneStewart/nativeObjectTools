//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetDate (dict ID; key; date value)

// Assigns a date value to a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
//   $3 : Date : Value to store

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $key_t; $text_t)
C_DATE:C307($3; $value_d)

$dictionary_i:=$1
$key_t:=$2
$value_d:=$3

// Convert the date to a string in the YYYY-MM-DD format
$text_t:=String:C10(Year of:C25($value_d); "0000")+"-"+String:C10(Month of:C24($value_d); "00")+"-"+String:C10(Day of:C23($value_d); "00")

Dict_SetValue($dictionary_i; $key_t; $text_t; Is date:K8:7)
