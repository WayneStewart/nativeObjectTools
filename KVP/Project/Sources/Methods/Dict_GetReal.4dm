//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetReal (dict ID; key) --> Real

// Returns a real value from a dictionary given a key

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Real : The key's value

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $key_t; $text_t)
C_REAL:C285($0; $value_r)

$dictionary_i:=$1
$key_t:=$2

$text_t:=Dict_GetValue($dictionary_i; $key_t)

// If the decimal separator is a comma, convert the period back to a comma
If (String:C10(1/2)="0,5")
	$text_t:=Replace string:C233($text_t; "."; ",")
End if 
$value_r:=Num:C11($text_t)


$0:=$value_r