//%attributes = {"invisible":true,"shared":true}


// ----------------------------------------------------
// Project Method: OTX ObjectToBLOB


// Method Type:    Protected

// Parameters:
C_LONGINT:C283($InObject_i; $1)
C_POINTER:C301($Blob_ptr; $2)

// Local Variables:
C_LONGINT:C283($CurrentItem_i; $ItemCount_i; $OffSet_i; $ItemType_i)
C_BOOLEAN:C305($Error_b)
C_POINTER:C301($Object_ptr; $ItemsArray_ptr; $ItemNamesArray_ptr; $Item_ptr; $ItemTypesArray_ptr)
C_TEXT:C284($ObjectTag_t; $ItemTag_t)

// Created by Wayne Stewart (Sep 7, 2007)
//     waynestewart@mac.com
//  Object Tools replacement routine
//  The 3rd paramater is not available, blob will be cleared
//    prior to storage of object

// OT ObjectToBLOB(inObject; ioBLOB {; inAppend}) 
//  Description 
//  OT ObjectToBLOB stores an object into a BLOB. The previous contents of the
//  BLOB, if any, are completely replaced, unless a non-zero value is passed in
//  inAppend, in which case the object is appended to inBLOB.
//  Once stored within a BLOB, you must retrieve an object from a it with
//  OT BLOBToObject, not with BLOB TO VARIABLE.
//  If inObject is not a valid object handle, if ioBLOB is not a valid BLOB, or if
//  memory cannot be allocated to copy the object, an error is generated, OK is set
//  to zero, and ioBLOB is cleared. OT ObjectToBLOB(inObject; ioBLOB {; inAppend})
//  Parameter      Type          Description
//  inObject       Longint  ->   An object handle
//  ioBLOB         BLOB     ->   A BLOB which receives the object
// ----------------------------------------------------

$InObject_i:=$1
$Blob_ptr:=$2
$Error_b:=False:C215
$ObjectTag_t:="Object"
$OffSet_i:=0

If (OTX IsObject($InObject_i)=1)
	$Object_ptr:=OTX Get Object Pointer($inObject_i)
	$ItemCount_i:=OTX ItemCount($InObject_i)
	If (OK=1)
		
		SET BLOB SIZE:C606($Blob_ptr->; 0)
		VARIABLE TO BLOB:C532($ObjectTag_t; $Blob_ptr->; $OffSet_i)  //  1st is "Object"
		VARIABLE TO BLOB:C532($ItemCount_i; $Blob_ptr->; $OffSet_i)  //  2nd is # of items
		
		$ItemTypesArray_ptr:=$Object_ptr->{<>OTX_ItemTypes_i}
		For ($CurrentItem_i; 1; $ItemCount_i)
			$ItemType_i:=$ItemTypesArray_ptr->{$CurrentItem_i}
			VARIABLE TO BLOB:C532($ItemType_i; $Blob_ptr->; $OffSet_i)  //  Store the item type
		End for 
		
		$ItemNamesArray_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //  Get a pointer to the array of item names
		For ($CurrentItem_i; 1; $ItemCount_i)
			$ItemTag_t:=$ItemNamesArray_ptr->{$CurrentItem_i}  //  Get the item name
			VARIABLE TO BLOB:C532($ItemTag_t; $Blob_ptr->; $OffSet_i)  //  Store the item tag
		End for 
		
		$ItemsArray_ptr:=$Object_ptr->{<>OTX_ItemVariables_i}  //  Get a pointer to the array of item pointers
		For ($CurrentItem_i; 1; $ItemCount_i)
			$Item_ptr:=$ItemsArray_ptr->{$CurrentItem_i}  //  Get the pointer to the item
			VARIABLE TO BLOB:C532($Item_ptr->; $Blob_ptr->; $OffSet_i)  //  Store the item
		End for 
		
		$ObjectTag_t:="End Object"
		VARIABLE TO BLOB:C532($ObjectTag_t; $Blob_ptr->; $OffSet_i)  //  Last is "End Object"
		
	End if 
	
Else 
	OK:=0
End if 
