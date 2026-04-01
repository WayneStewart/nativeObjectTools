//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: KVP_Copy


// Method Type:    Shared

// Parameters:
C_TEXT:C284($OldDictionaryName_t; $1)
C_TEXT:C284($NewDictionaryName_t; $2; $0)

// Local Variables:
C_LONGINT:C283($DictionaryID_i)

// Created by Wayne Stewart (Jun 15, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------

$OldDictionaryName_t:=$1
If (Count parameters:C259=2)
	$NewDictionaryName_t:=$2
Else 
	$NewDictionaryName_t:=$OldDictionaryName_t+" <"+String:C10(<>Dict_SequentialCounter_i+1)+">"
End if 

$DictionaryID_i:=Dict_Copy(Dict_Named($OldDictionaryName_t); $NewDictionaryName_t)

$0:=Dict_Name($DictionaryID_i)