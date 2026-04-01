
// ----------------------------------------------------
// User name (OS): Wayne Stewart
// Date and time: Jul 12, 2012
If (False:C215)
	// Dictionary Viewer.List Box
End if 
// ----------------------------------------------------
// Method: Dictionary Viewer.List Box
// Description
// 
//
// Local Parameters
C_LONGINT:C283($Row_i; $DictionaryID_i; $key_i; $NumberOfKeys_i)
C_POINTER:C301($Column_ptr; $KVP_ID_ptr; $DictionaryIDArray_ptr; $SelectedDictionary_ptr)
C_TEXT:C284($DataType_t)
// ----------------------------------------------------


Case of 
	: (Form event code:C388=On Clicked:K2:4)
		$Column_ptr:=OBJECT Get pointer:C1124(Object with focus:K67:3)
		$Row_i:=$Column_ptr->  //$Row_i equals 5
		
		$DictionaryIDArray_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Dictionary ID Array")
		
		$DictionaryID_i:=$DictionaryIDArray_ptr->{$Row_i}
		
		Dict_UpdateDictionaryItemsDispl($DictionaryID_i)
		
		$SelectedDictionary_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Selected Dictionary")
		
		$SelectedDictionary_ptr->:=$Row_i
End case 