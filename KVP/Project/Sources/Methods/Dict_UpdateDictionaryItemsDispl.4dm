//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_UpdateDictionaryItemsDispl

// Method Type:    Private

// Parameters:
C_LONGINT:C283($1; $DictionaryID_i)
// Local Variables:
C_LONGINT:C283($DictionaryID_i; $key_i; $NumberOfKeys_i)
C_POINTER:C301($KVP_ID_ptr; $DictionaryIDArray_ptr; $DictionaryKeys_ptr; $DictionaryTypes_ptr; $DictionaryValues_ptr)
C_TEXT:C284($DataType_t)

// Created by Wayne Stewart (Jul 24, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------


$DictionaryID_i:=$1

LISTBOX DELETE ROWS:C914(*; "Dictionary Data Display Array"; 1; LISTBOX Get number of rows:C915(*; "Dictionary Data Display Array"))
$NumberOfKeys_i:=Dict_ItemCount($DictionaryID_i)

$KVP_ID_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "KVP ID Array")
$DictionaryKeys_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Dictionary Keys Array")
$DictionaryTypes_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Dictionary Types Array")
$DictionaryValues_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Dictionary Values Array")

COPY ARRAY:C226(<>Dict_Keys_at{$DictionaryID_i}; $DictionaryKeys_ptr->)
COPY ARRAY:C226(<>Dict_Values_at{$DictionaryID_i}; $DictionaryValues_ptr->)

For ($key_i; 1; $NumberOfKeys_i)
	APPEND TO ARRAY:C911($KVP_ID_ptr->; $key_i)
	//APPEND TO ARRAY($DictionaryKeys_ptr->{$key_i};<>Dict_Keys_at{$DictionaryID_i}{$key_i})
	//APPEND TO ARRAY($DictionaryValues_ptr->{$key_i};<>Dict_Values_at{$DictionaryID_i}{$key_i})
	
	Case of 
		: (<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i}=Is longint:K8:6)
			$DataType_t:="Is LongInt"
			
		: (<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i}=Is real:K8:4)
			$DataType_t:="Is Real"
			
		: (<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i}=Is text:K8:3)
			$DataType_t:="Is Text"
			
		: (<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i}=Is time:K8:8)
			$DataType_t:="Is Time"
			
		: (<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i}=Is BLOB:K8:12)
			$DataType_t:="Is BLOB"
			
		: (<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i}=Is picture:K8:10)
			$DataType_t:="Is Picture"
			
		: (<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i}=Is pointer:K8:14)
			$DataType_t:="Is Pointer"
			
		: (<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i}=Is boolean:K8:9)
			$DataType_t:="Is Boolean"
			
		: (<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i}=Is date:K8:7)
			$DataType_t:="Is Date"
			
		Else 
			$DataType_t:=String:C10(<>Dict_DataTypes_ai{$DictionaryID_i}{$key_i})
			
	End case 
	
	APPEND TO ARRAY:C911($DictionaryTypes_ptr->; $DataType_t)
	
	
End for 

