//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetDate (dict ID; key) --> Date

// Returns a date value from a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Date : The key's value

// Created by Rob Laveaux
// ----------------------------------------------------

C_DATE:C307($0; $value_d)
C_LONGINT:C283($1; $dictionary_i; $year_i; $month_i; $day_i)
C_TEXT:C284($2; $key_t; $text_t)

$dictionary_i:=$1
$key_t:=$2

$text_t:=Dict_GetValue($dictionary_i; $key_t)

// Convert the text value back to a date
If ($text_t#"")
	$year_i:=Num:C11(Substring:C12($text_t; 1; 4))
	$month_i:=Num:C11(Substring:C12($text_t; 6; 2))
	$day_i:=Num:C11(Substring:C12($text_t; 9; 2))
	$value_d:=Add to date:C393(!00-00-00!; $year_i; $month_i; $day_i)
End if 

$0:=$value_d