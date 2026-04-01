//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetReal (dict ID; key; real value)

// Assigns a real value to a dictionary given a key

// Access: Private

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
//   $3 : Real : Value to store

// Returns: Nothing

// Created by Rob Laveaux

// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $key_t; $text_t)
C_REAL:C285($3; $value_r)

$dictionary_i:=$1
$key_t:=$2
$value_r:=$3

// Convert the real to a text and make sure the period is used as a decimal separator
$text_t:=String:C10($value_r)
If (String:C10(1/2)="0,5")
	$text_t:=Replace string:C233($text_t; ","; ".")
End if 

Dict_SetValue($dictionary_i; $key_t; $text_t; Is real:K8:4)
