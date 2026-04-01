//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: KVP_Blob


// Method Type:    Shared

// Parameters:
C_TEXT:C284($1)
C_BLOB:C604($2; $0)

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
	Dict_SetBlob($Dictionary_i; $Key_t; $2; True:C214)
End if 

$0:=Dict_GetBlob($Dictionary_i; $Key_t)