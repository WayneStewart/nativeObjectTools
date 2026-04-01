//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: KVP_Boolean

// Method Type:    Shared

// Parameters:
C_TEXT:C284($1)
C_BOOLEAN:C305($2; $0)

// Local Variables:
C_TEXT:C284($KeyIdentifier_t; $DictionaryName_t; $Key_t)
C_LONGINT:C283($Dictionary_i; $Position_i)

// Created by Wayne Stewart (Jun 19, 2012)
//     waynestewart@mac.com
//   
// ----------------------------------------------------

$KeyIdentifier_t:=$1
KVP_ParseDictionaryAndKey($KeyIdentifier_t; ->$Dictionary_i; ->$Key_t)

If (Count parameters:C259=2)
	Dict_SetBoolean($Dictionary_i; $Key_t; $2)
	$0:=$2
Else 
	$0:=Dict_GetBoolean($Dictionary_i; $Key_t)
End if 

