//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_DeleteArrayElement 

// Method Type:    Protected
C_LONGINT:C283($DictionaryID_i; $1)
C_TEXT:C284($Key_t; $2)
C_LONGINT:C283($inIndex_i; $3)
C_LONGINT:C283($inHowMany_i; $4)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $NumberDeleted_i; $CurrentIndex_i; $SizeOfArray_i; $OlKVPizeOfArray_i)
C_LONGINT:C283($NewStartNumber_i; $Counter_i)
C_POINTER:C301($Object_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr; $ItemVariable_ptr)
C_TEXT:C284($ElementKeyLabel_t)

// Created by Wayne Stewart (Sep 12, 2007)
//     waynestewart@mac.com

// Discussion 
//   Dict_DeleteArrayElement deletes one or more elements from an array in Dictionary. 
//   If Dictionary is not a valid object handle, if no item in the object has the given tag, 
//   or if the item’s type is not an array type, an error is generated and OK is set to 
//   zero. 
//   Elements are deleted starting at the element specified by inWhere. The 
//   inHowMany parameter is the number of elements to delete. If inHowMany is not 
//   specified or zero, then one element is deleted. The size of the array shrinks by 
//   inHowMany elements. 
//   
//   Dict_DeleteArrayElement (Dictionary; Key; inWhere {; inHowMany}) 
//   Parameter       Type            Description 
//   Dictionary        Longint         A handle to an object 
//   Key           String          Tag of the array item to change 
//   inWhere         Number          Element to delete 
//   inHowMany       Number          How many elements to delete

// ----------------------------------------------------

Dict_Init  //  Check the component is initialised

$DictionaryID_i:=$1
$Key_t:=$2
$inIndex_i:=$3

Case of 
	: (Count parameters:C259=3)
		$inHowMany_i:=1
	: ($4=0)  //  Unlikely
		$inHowMany_i:=1
	Else 
		$inHowMany_i:=$4
End case 

$NumberDeleted_i:=0

Dict_LockInternalState(True:C214)

If (Dict_IsValid($DictionaryID_i))
	$inHowMany_i:=$inIndex_i+$inHowMany_i-1
	$OlKVPizeOfArray_i:=Dict_SizeOfArray($DictionaryID_i; $Key_t)
	$NewStartNumber_i:=$inIndex_i-1
	For ($CurrentIndex_i; $inIndex_i; $inHowMany_i)
		$ElementKeyLabel_t:=$Key_t+"."+String:C10($CurrentIndex_i)
		If (Dict_HasKey($DictionaryID_i; $ElementKeyLabel_t))
			Dict_Remove($DictionaryID_i; $ElementKeyLabel_t)
			$NumberDeleted_i:=$NumberDeleted_i+1
		End if 
	End for 
	$SizeOfArray_i:=Dict_SizeOfArray($DictionaryID_i; $Key_t)
	$SizeOfArray_i:=$SizeOfArray_i-$NumberDeleted_i
	Dict_SetLongint($DictionaryID_i; $Key_t+".count"; $SizeOfArray_i)
	
	$Counter_i:=0
	$inIndex_i:=$CurrentIndex_i  //  Copy the current item
	For ($CurrentIndex_i; $inIndex_i; $OlKVPizeOfArray_i)
		$ElementKeyLabel_t:=$Key_t+"."+String:C10($CurrentIndex_i)
		$Counter_i:=$Counter_i+1
		If (Dict_HasKey($DictionaryID_i; $ElementKeyLabel_t))
			Dict_RenameKey($DictionaryID_i; $ElementKeyLabel_t; $Key_t+"."+String:C10($NewStartNumber_i+$Counter_i))
		End if 
		
		
	End for 
	
	
End if 

Dict_LockInternalState(False:C215)
