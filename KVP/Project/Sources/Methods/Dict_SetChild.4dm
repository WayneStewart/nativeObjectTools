//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// User name (OS): Wayne Stewart
// Date and time: Jul 21, 2012
If (False:C215)
	Dict_SetChild
End if 
// ----------------------------------------------------
// Method: Dict_SetChild
// Description
//   This method inserts an existing
//      KVP Dictionary into another dictionary
//   By passing the optional "*" parameter, the source
//   dictionary will be destroyed once it is copied
//      4D won't let me pass a naked *

// Parameters
C_LONGINT:C283($ParentDictionary_i; $1)
C_LONGINT:C283($ChildDictionary_i; $2)
C_TEXT:C284($KeyPrefix_t; $3)
C_TEXT:C284($DestructiveFlag_t; $4)

//  Local Variables
C_LONGINT:C283($KeyCount_i; $KeyNumber_i; $KeyType_i)
C_TEXT:C284($KeyValue_t; $KeyTag_t; $KeyPrefix_t)

// ----------------------------------------------------

$ParentDictionary_i:=$1
$ChildDictionary_i:=$2

Case of 
	: (Count parameters:C259=3)
		$KeyPrefix_t:=$3
	: (Count parameters:C259=4)
		$KeyPrefix_t:=$3
		$DestructiveFlag_t:=$4
End case 

If ($KeyPrefix_t="")
	$KeyPrefix_t:=Dict_Name($ChildDictionary_i)
End if 

//  Firstly insert all the items from the inserted dictionary
$KeyCount_i:=Dict_ItemCount($ChildDictionary_i)
For ($KeyNumber_i; 1; $KeyCount_i)
	$KeyTag_t:=<>Dict_Keys_at{$ChildDictionary_i}{$KeyNumber_i}
	$KeyTag_t:=$KeyPrefix_t+"."+$KeyTag_t
	$KeyValue_t:=<>Dict_Values_at{$ChildDictionary_i}{$KeyNumber_i}
	$KeyType_i:=<>Dict_DataTypes_ai{$ChildDictionary_i}{$KeyNumber_i}
	Dict_SetValue($ParentDictionary_i; $KeyTag_t; $KeyValue_t; $KeyType_i)
End for 

//  Then delete the previous dictionary if requested to do so
If ($DestructiveFlag_t="*")
	Dict_Release($ChildDictionary_i)
End if 
