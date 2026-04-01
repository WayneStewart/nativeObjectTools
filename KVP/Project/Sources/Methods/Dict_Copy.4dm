//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// User name (OS): Wayne Stewart
// Date and time: Dec 10, 2009, 11:39:57
// ----------------------------------------------------
// Method: Dict_Copy
// Description
// This method will copy a Dict dictionary into a new dictionary
//

// Parameters
C_LONGINT:C283($inDictionary_i; $1)
C_TEXT:C284($InNewDictionaryName_t; $2)  //  OPTIONAL

C_LONGINT:C283($0; $NewlyCreatedDictionary_i)

//  Local Variables
ARRAY TEXT:C222($Keys_at; 0)
ARRAY TEXT:C222($Values_at; 0)
ARRAY LONGINT:C221($Types_ai; 0)


// ----------------------------------------------------

$inDictionary_i:=$1

If (Count parameters:C259=2)
	$InNewDictionaryName_t:=$2
	$NewlyCreatedDictionary_i:=Dict_New($InNewDictionaryName_t)
Else 
	$NewlyCreatedDictionary_i:=Dict_New
End if 

Dict_Keys($inDictionary_i; ->$Keys_at)
Dict_Values($inDictionary_i; ->$Values_at)
Dict_DataTypes($inDictionary_i; ->$Types_ai)

COPY ARRAY:C226($Keys_at; <>Dict_Keys_at{$NewlyCreatedDictionary_i})
COPY ARRAY:C226($Values_at; <>Dict_Values_at{$NewlyCreatedDictionary_i})
COPY ARRAY:C226($Types_ai; <>Dict_DataTypes_ai{$NewlyCreatedDictionary_i})

$0:=$NewlyCreatedDictionary_i