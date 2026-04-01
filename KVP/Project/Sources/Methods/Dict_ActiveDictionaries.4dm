//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_ActiveDictionaries

// Method Type:    Shared
// Parameters:
C_POINTER:C301($1; $ArrayOfDictionaries_ptr)

// Local Variables:
C_LONGINT:C283($NumberOfDictionaries_i; $CurrentDictionary_i)

// Created by Wayne Stewart (Apr 9, 2015)
//     waynestewart@mac.com
//   
// ----------------------------------------------------

$ArrayOfDictionaries_ptr:=$1

ARRAY LONGINT:C221($ArrayOfDictionaries_ptr->; 0)

Dict_LockInternalState(True:C214)

$NumberOfDictionaries_i:=Size of array:C274(<>Dict_RetainCounts_ai)

For ($CurrentDictionary_i; 1; $NumberOfDictionaries_i)
	If (<>Dict_RetainCounts_ai{$CurrentDictionary_i}>0)
		APPEND TO ARRAY:C911($ArrayOfDictionaries_ptr->; $CurrentDictionary_i)
	End if 
End for 

Dict_LockInternalState(False:C215)
