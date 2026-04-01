
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
C_POINTER:C301($PicturePreview_ptr; $BlobText_ptr)
C_PICTURE:C286($Original_Pic; $Blank_pic)

// ----------------------------------------------------


Case of 
	: (Form event code:C388=On Clicked:K2:4)
		$Column_ptr:=OBJECT Get pointer:C1124(Object with focus:K67:3)
		$Row_i:=$Column_ptr->  //$Row_i equals 5
		$BlobText_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Blob_Data")
		
		If (KVP_Text(<>Dict_PictIndexSlots_at{$Row_i})="Picture@")
			OBJECT SET VISIBLE:C603(*; "Blob_Data"; False:C215)
			OBJECT SET VISIBLE:C603(*; "Picture Preview"; True:C214)
			$PicturePreview_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Picture Preview")
			$PicturePreview_ptr->:=<>Dict_PictValues_apic{$Row_i}
			$BlobText_ptr->:=""
		Else 
			OBJECT SET VISIBLE:C603(*; "Blob_Data"; True:C214)
			OBJECT SET VISIBLE:C603(*; "Picture Preview"; False:C215)
			//$PicturePreview_ptr->:=$Blank_pic
			$BlobText_ptr->:="Blob: Size = "+String:C10(Picture size:C356(<>Dict_PictValues_apic{$Row_i}))+" bytes."
			
		End if 
		
		
		//$DictionaryIDArray_ptr:=OBJECT Get pointer(Object named;"Dictionary ID Array")
		
		//$DictionaryID_i:=$DictionaryIDArray_ptr->{$Row_i}
		
		//Dict_UpdateDictionaryItemsDispl ($DictionaryID_i)
		
		//$SelectedDictionary_ptr:=OBJECT Get pointer(Object named;"Selected Dictionary")
		
		//$SelectedDictionary_ptr->:=$Row_i
End case 