//%attributes = {"invisible":true,"shared":true}

// ----------------------------------------------------
// Project Method: OTX DeleteItem

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i)
C_POINTER:C301($Object_ptr; $ItemVariable_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

// Discussion 
// OT DeleteItem deletes an item from an object. inTag may refer to embedded 
// items and objects. 
// If inObject is not a valid object handle or inTag refers to an item that does not 
// exist, an error is generated, OK is set to zero, and no delete is performed.OT DeleteItem(inObject; inTag) 
// Parameter  Type  Description 
// inObject   Longint A handle to an object 
// inTag   String Tag of the item to delete 
// 

// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$inTag_t:=$2

$Object_ptr:=OTX Get Object Pointer($inObject_i)  //  Find the object pointer, OK is set to 1 if the object exists


If (OK=1)  //                                                            Only work if valid pointer is found
	//                                                                  Set some pointers to the array elements
	$ListOfItemNames_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //             This is the item tag
	$ListOfItemVariables_ptr:=$Object_ptr->{<>OTX_ItemVariables_i}  //     This is the item variable ptr
	$ListOfItemTypes_ptr:=$Object_ptr->{<>OTX_ItemTypes_i}  //             This is the item type
	$ItemPosition_i:=OTX Get Item Position($Object_ptr; $inTag_t)  //     Get the item position within the object
	
	If ($ItemPosition_i=-1)  //                                           If the item does not exist, return "" & set OK to 0
		OK:=0
	Else 
		DELETE FROM ARRAY:C228($ListOfItemNames_ptr->; $ItemPosition_i; 1)  //     Delete the item tag
		DELETE FROM ARRAY:C228($ListOfItemTypes_ptr->; $ItemPosition_i; 1)  //     Delete the item type
		$ItemVariable_ptr:=$ListOfItemVariables_ptr->{$ItemPosition_i}  //  Find the rVar pointer
		rVar_ReturnVariable($ItemVariable_ptr)  //                         Return the rVar variable to the pool
		DELETE FROM ARRAY:C228($ListOfItemVariables_ptr->; $ItemPosition_i; 1)  // Delete the rVar pointer
		
	End if 
End if 