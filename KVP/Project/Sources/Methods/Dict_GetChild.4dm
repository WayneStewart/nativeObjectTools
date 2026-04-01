//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetChild

// Method Type:    Shared

// Parameters:
C_LONGINT:C283($DictionaryID_i; $1)
C_TEXT:C284($ChildKey_t; $2)
C_TEXT:C284($ChildDictionaryName_t; $3)
C_TEXT:C284($DestructiveFlag_t; $4)

// Returns:
C_LONGINT:C283($0; $ChildDictionary_i)

// Local Variables:
C_LONGINT:C283($KeyNumber_i; $KeyCount_i; $Item_i; $KeyType_i)
C_TEXT:C284($KeyTag_t; $KeyValue_t)

// Created by Wayne Stewart (Jul 24, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------

$DictionaryID_i:=$1
$ChildKey_t:=$2


Case of 
	: (Count parameters:C259=3)
		$ChildDictionaryName_t:=$3
	: (Count parameters:C259=4)
		$ChildDictionaryName_t:=$3
		$DestructiveFlag_t:=$4
End case 

If ($ChildDictionaryName_t="")
	$ChildDictionaryName_t:=$ChildKey_t
End if 

//  Firstly create the new dictionary
$ChildDictionary_i:=Dict_New($ChildDictionaryName_t)

//  Then find all the child items in the dictionary
$KeyCount_i:=Count in array:C907(<>Dict_Keys_at{$DictionaryID_i}; $ChildKey_t+".@")
$KeyNumber_i:=0
For ($Item_i; 1; $KeyCount_i)
	$KeyNumber_i:=Find in array:C230(<>Dict_Keys_at{$DictionaryID_i}; $ChildKey_t+".@"; $KeyNumber_i)
	$KeyTag_t:=<>Dict_Keys_at{$DictionaryID_i}{$KeyNumber_i}
	$KeyTag_t:=Replace string:C233($KeyTag_t; $ChildKey_t+"."; "")
	$KeyValue_t:=<>Dict_Values_at{$DictionaryID_i}{$KeyNumber_i}
	$KeyType_i:=<>Dict_DataTypes_ai{$DictionaryID_i}{$KeyNumber_i}
	Dict_SetValue($ChildDictionary_i; $KeyTag_t; $KeyValue_t; $KeyType_i)
	$KeyNumber_i:=$KeyNumber_i+1
End for 

If ($DestructiveFlag_t="*")
	Dict_Remove($DictionaryID_i; $ChildKey_t+".@")  //  This will remove the child dictionary!
End if 

$0:=$ChildDictionary_i