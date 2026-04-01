//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SizeOfArray

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($DictionaryID_i; $1)
C_TEXT:C284($Key_t; $2)
C_LONGINT:C283($OutSize_i; $0)

// Local Variables:
C_TEXT:C284($ElementKeyLabel_t)

// Created by Wayne Stewart (Sep 12, 2007)
//     waynestewart@mac.com

// Discussion 
//   Dict_SizeOfArray returns the number of elements in an array item within an 
//   object. 
//   If Dictionary is not a valid object handle, if no item in the object has the given tag, 
//   or if the item’s type is not an array type, an error is generated, 
//   and zero is returned. 

//   Dict_SizeOfArray(Dictionary; Key) ->  Number 
//   Parameter           Type            Description 
//   Dictionary            Longint         A handle to an object 
//   Key               String          Tag of the item to query 
//   Function result     Number          The size of the item’s array

// ----------------------------------------------------

$DictionaryID_i:=$1
$Key_t:=$2

$OutSize_i:=0

Dict_LockInternalState(True:C214)

If (Dict_IsValid($DictionaryID_i))
	$ElementKeyLabel_t:=$Key_t+".count"
	$OutSize_i:=Dict_GetLongint($DictionaryID_i; $ElementKeyLabel_t)
End if 

Dict_LockInternalState(False:C215)

$0:=$OutSize_i