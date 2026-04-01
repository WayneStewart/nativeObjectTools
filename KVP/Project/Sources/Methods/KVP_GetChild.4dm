//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: KVP_GetChild

// Method Type:    Shared

// Parameters:
C_TEXT:C284($ParentDictionary_t; $1)
C_TEXT:C284($ChildKey_t; $2)
C_TEXT:C284($ChildDictionaryName_t; $3)
C_TEXT:C284($DestructiveFlag_t; $4)

// Returns:
C_TEXT:C284($0; $ChildDictionaryName_t)


// Local Variables:
C_LONGINT:C283($DictionaryID_i)
C_LONGINT:C283($ChildDictionary_i)

// Created by Wayne Stewart (Jul 24, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------

$ParentDictionary_t:=$1
$ChildKey_t:=$2

Case of 
	: (Count parameters:C259=3)
		$ChildDictionaryName_t:=$3
	: (Count parameters:C259=4)
		$ChildDictionaryName_t:=$3
		$DestructiveFlag_t:=$4
End case 

$DictionaryID_i:=Dict_Named($ParentDictionary_t)


$ChildDictionary_i:=Dict_GetChild($DictionaryID_i; $ChildKey_t; $ChildDictionaryName_t; $DestructiveFlag_t)

$ChildDictionaryName_t:=Dict_Name($ChildDictionary_i)

$0:=$ChildDictionaryName_t
