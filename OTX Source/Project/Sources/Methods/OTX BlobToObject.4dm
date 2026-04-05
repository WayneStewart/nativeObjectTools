//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX BlobToObject 


// Method Type:    Protected

// Parameters:
C_POINTER:C301($Blob_ptr; $1)
C_LONGINT:C283($Object_i; $2; $0)

// Local Variables:
C_LONGINT:C283($CurrentItem_i; $ItemCount_i; $OffSet_i; $ItemType_i)
C_BOOLEAN:C305($Error_b)
C_POINTER:C301($Object_ptr; $ItemsArray_ptr; $ItemNamesArray_ptr; $Item_ptr; $ItemTypesArray_ptr)
C_TEXT:C284($ObjectTag_t; $ItemTag_t)

// Created by Wayne Stewart (Sep 7, 2007)
//     waynestewart@mac.com

// Discussion 
//  OT BLOBToObject retrieves an object from a BLOB into a new object handle. The 
//  Object must have been stored in the BLOB with OT ObjectToBLOB, not with 
//  VARIABLE TO BLOB. 
//  If ioOffset is not passed in it defaults to zero. 
//  If the bytes at the given offset do not describe an object stored with 
//  OT ObjectToBLOB, an error is generated, OK is set to zero, ioOffset is left 
//  untouched and a null handle (0) is returned. 
//  See Also 

//  OT BLOBToObject(inBLOB {; ioOffset})  ->  Longint 
//  Parameter     Type      Description 
//  inBLOB        BLOB      A BLOB which contains an object 
//  ioOffset      Longint   The offset within the BLOB where the object can be found 
//  Warning The handle returned is a new object that is added to ObjectTools’ 
//  internal list of objects. You must be sure to clear the new object with OT Clear 
//  when you no longer need it.

// ----------------------------------------------------

If (Count parameters:C259=2)
	$Object_i:=$2
	OTX Clear($Object_i)  //  If you pass in an existing object it will be cleared
End if 

$Object_i:=OTX New

$Blob_ptr:=$1
$OffSet_i:=0

BLOB TO VARIABLE:C533($Blob_ptr->; $ObjectTag_t; $OffSet_i)

If (OK=1)  // if the first var is not text, something is wrong
	If ($ObjectTag_t="Object")  // if the first var is not "Object", something is wrong
		BLOB TO VARIABLE:C533($Blob_ptr->; $ItemCount_i; $OffSet_i)
		$Object_ptr:=OTX Get Object Pointer($Object_i)
		
		$ItemTypesArray_ptr:=$Object_ptr->{<>OTX_ItemTypes_i}
		For ($CurrentItem_i; 1; $ItemCount_i)
			BLOB TO VARIABLE:C533($Blob_ptr->; $ItemType_i; $OffSet_i)  // Retrieve item type
			APPEND TO ARRAY:C911($ItemTypesArray_ptr->; $ItemType_i)  //  Store the item type
		End for 
		
		$ItemNamesArray_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //  Get a pointer to the array of item names
		For ($CurrentItem_i; 1; $ItemCount_i)
			BLOB TO VARIABLE:C533($Blob_ptr->; $ItemTag_t; $OffSet_i)  // Retrieve item name
			APPEND TO ARRAY:C911($ItemNamesArray_ptr->; $ItemTag_t)  //  Store the item tag
		End for 
		
		$ItemsArray_ptr:=$Object_ptr->{<>OTX_ItemVariables_i}  //  Get a pointer to the array of item pointers
		For ($CurrentItem_i; 1; $ItemCount_i)
			$ItemType_i:=$ItemTypesArray_ptr->{$CurrentItem_i}
			$Item_ptr:=rVar_GetVariableByType($ItemType_i)
			APPEND TO ARRAY:C911($ItemsArray_ptr->; $Item_ptr)  //  Store the item 
			BLOB TO VARIABLE:C533($Blob_ptr->; $Item_ptr->; $OffSet_i)
		End for 
		
		BLOB TO VARIABLE:C533($Blob_ptr->; $ObjectTag_t; $OffSet_i)
		
		If ($ObjectTag_t#"End Object")  // if the last var is not "End Object", something is wrong
			OK:=0
			OTX Clear($Object_i)
			$Object_i:=0
			
		End if 
		
		
	Else 
		OK:=0
		OTX Clear($Object_i)
		$Object_i:=0
		
	End if 
	
Else 
	OTX Clear($Object_i)
	$Object_i:=0
	
End if 

$0:=$Object_i