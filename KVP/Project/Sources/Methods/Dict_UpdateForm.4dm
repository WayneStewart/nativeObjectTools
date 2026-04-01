//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_UpdateForm

// Method Type:    Private

// Parameters:

// Local Variables:
C_POINTER:C301($DictionaryIDArray_ptr; $SelectedDictionary_ptr)
C_LONGINT:C283($i; $NumberOfKVP_i)

// Created by Wayne Stewart (Jul 24, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------

$DictionaryIDArray_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Dictionary ID Array")
DELETE FROM ARRAY:C228($DictionaryIDArray_ptr->; 1; Size of array:C274($DictionaryIDArray_ptr->))

$NumberOfKVP_i:=Size of array:C274(<>Dict_Names_at)
For ($i; 1; $NumberOfKVP_i)
	APPEND TO ARRAY:C911($DictionaryIDArray_ptr->; $i)
End for 

$SelectedDictionary_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Selected Dictionary")

Case of 
	: ($NumberOfKVP_i=0)
		$SelectedDictionary_ptr->:=0
		
	: ($SelectedDictionary_ptr->>$NumberOfKVP_i)
		$SelectedDictionary_ptr->:=0
		
End case 


If ($SelectedDictionary_ptr->>0)
	Dict_UpdateDictionaryItemsDispl($DictionaryIDArray_ptr->{$SelectedDictionary_ptr->})
	
Else 
	Dict_UpdateDictionaryItemsDispl(0)  //  Clear the display
	
End if 

REDRAW WINDOW:C456
