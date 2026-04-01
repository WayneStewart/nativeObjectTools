//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_ResizeArray

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($DictionaryID_i; $1)
C_TEXT:C284($Key_t; $2)
C_LONGINT:C283($inSize_i; $3)

// Local Variables:
C_LONGINT:C283($CurrentSize_i)
C_TEXT:C284($ElementKeyLabel_t)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

// Discussion 
//   Dict_ResizeArray resizes an array in Dictionary. 
//   If Dictionary is not a valid object handle, if no item in the object has the given tag, 
//   or if the item’s type is not an array type, an error is generated and OK is set to 
//   zero. 

//   If inSize is greater than the current size of the array, empty elements are added 
//   to the end of the array. If inSize is less than the current size of the array, elements 
//   from inSize + 1 to the end of the array are deleted.

//   Dict_ResizeArray (Dictionary; Key; inSize) 
//   Parameter       Type            Description 
//   Dictionary        Longint         A handle to an object 
//   Key           String          Tag of the array item to change 
//   inSize          Number          New array size
// ----------------------------------------------------

$DictionaryID_i:=$1
$Key_t:=$2
$inSize_i:=$3

Dict_LockInternalState(True:C214)

If (Dict_IsValid($DictionaryID_i))
	$CurrentSize_i:=Dict_SizeOfArray($DictionaryID_i; $Key_t)
	
	Case of 
		: ($CurrentSize_i=$inSize_i)  //  Simplest case: do nothing
		: ($CurrentSize_i<$inSize_i)
			While ($CurrentSize_i<$inSize_i)
				Dict_InsertArrayElement($DictionaryID_i; $Key_t; $CurrentSize_i+1)
				$CurrentSize_i:=Dict_SizeOfArray($DictionaryID_i; $Key_t)  //        Get the size of the array
			End while 
		: ($CurrentSize_i>$inSize_i)  //  Need to shrink array
			Repeat 
				Dict_DeleteArrayElement($DictionaryID_i; $Key_t; $CurrentSize_i)  //  Delete the top most element
				$CurrentSize_i:=Dict_SizeOfArray($DictionaryID_i; $Key_t)  //        Get the size of the array
			Until ($inSize_i>=$CurrentSize_i)  //                                     Repeat if necessary
	End case 
End if 

Dict_LockInternalState(False:C215)