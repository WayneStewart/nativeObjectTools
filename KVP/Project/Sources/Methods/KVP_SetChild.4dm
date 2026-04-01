//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// User name (OS): Wayne Stewart
// Date and time: Jul 12, 2012
If (False:C215)
	KVP_SetChild
End if 
// ----------------------------------------------------
// Method: KVP_SetChild
// Description
//   This method inserts or extracts a 
//      KVP Dictionary into an existing dictionary
//   By passing the optional "*" parameter, 
//      4D won't let me pass a naked *

// Parameters
C_TEXT:C284($ParentDictionary_t; $1)
C_TEXT:C284($ChildDictionary_t; $2)
C_TEXT:C284($KeyPrefix_t; $3)
C_TEXT:C284($DestructiveFlag_t; $4)

//  Local Variables
C_LONGINT:C283($ParentDictionary_i; $ChildDictionary_i)

// ----------------------------------------------------

$ParentDictionary_t:=$1
$ChildDictionary_t:=$2

Case of 
	: (Count parameters:C259=3)
		$KeyPrefix_t:=$3
	: (Count parameters:C259=4)
		$KeyPrefix_t:=$3
		$DestructiveFlag_t:=$4
End case 




$ParentDictionary_i:=Dict_Named($ParentDictionary_t)
$ChildDictionary_i:=Dict_Named($ChildDictionary_t)

Dict_SetChild($ParentDictionary_i; $ChildDictionary_i; $KeyPrefix_t; $DestructiveFlag_t)

