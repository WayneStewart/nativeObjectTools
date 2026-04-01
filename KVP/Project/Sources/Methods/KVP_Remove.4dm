//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Remove (key)

// Removes a key from a dictionary.

// Access: Shared

// Parameters: 
//   $1 : Text : Key name
C_TEXT:C284($1; $KeyIdentifier_t)
// Returns: Nothing

// Created by Wayne Stewart (Sep 7, 2012)
// ----------------------------------------------------


C_TEXT:C284($KeyIdentifier_t; $Key_t)
C_LONGINT:C283($Dictionary_i)

$KeyIdentifier_t:=$1
KVP_ParseDictionaryAndKey($KeyIdentifier_t; ->$Dictionary_i; ->$Key_t)

Dict_Remove($Dictionary_i; $Key_t)