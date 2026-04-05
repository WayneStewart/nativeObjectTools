//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX RenameItem

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_TEXT:C284($inNewTag_t; $3)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i; $NewItemPosition_i)
C_POINTER:C301($Object_ptr; $ItemVariable_ptr)
C_POINTER:C301($ListOfItemNames_ptr)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

// Discussion 
// OTX RenameItem renames the item referenced by inTag to the item referenced by 
// inNewTag. 

// If the object handle is invalid, or if the item does not exist, or if an existing item 
// has the same name as inNewTag, an error is generated, OK is set to zero, and no 
// rename is performed.

// OTX RenameItem(inObject; inTag; inNewTag) 
// Parameter     Type        Description 
// inObject      Longint     A handle to an object 
// inTag         String      A full item tag 
// inNewTag      String      The new item tag 

// OTX RenameItem($obj;"old_name";"new_name")

// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$inTag_t:=$2
$inNewTag_t:=$3

$Object_ptr:=OTX Get Object Pointer($inObject_i)  //  Find the object pointer, OK is set to 1 if the object exists

If (OK=1)  //                                                            Only work if valid pointer is found
	$ItemPosition_i:=OTX Get Item Position($Object_ptr; $inTag_t)  //     Get the item position within the object
	If ($ItemPosition_i=-1)  //                                           If the item does not exist set OK to 0
		OK:=0
	Else 
		$NewItemPosition_i:=OTX Get Item Position($Object_ptr; $inNewTag_t)  //  
		If ($NewItemPosition_i=-1)  //                                      If the item does not exist set OK to 1
			OK:=1
			$ListOfItemNames_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //        Get the item Names Array  
			$ListOfItemNames_ptr->{$ItemPosition_i}:=$inNewTag_t  //         Rename that element
		Else 
			OK:=0  //                                                         The item exists
		End if 
	End if 
End if 