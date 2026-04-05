//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX ResizeArray

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_LONGINT:C283($inSize_i; $3)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i)
C_POINTER:C301($Object_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr; $ItemVariable_ptr)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

// Discussion 
//   OT ResizeArray resizes an array in inObject. 
//   If inObject is not a valid object handle, if no item in the object has the given tag, 
//   or if the item’s type is not an array type, an error is generated and OK is set to 
//   zero. 

//   If inSize is greater than the current size of the array, empty elements are added 
//   to the end of the array. If inSize is less than the current size of the array, elements 
//   from inSize + 1 to the end of the array are deleted.

//   OT ResizeArray (inObject; inTag; inSize) 
//   Parameter       Type            Description 
//   inObject        Longint         A handle to an object 
//   inTag           String          Tag of the array item to change 
//   inSize          Number          New array size
// ----------------------------------------------------

$inObject_i:=$1
$inTag_t:=$2
$inSize_i:=$3

$Object_ptr:=OTX Get Object Pointer($inObject_i)  //  Find the object pointer, OK is set to 1 if the object exists

If (OK=1)  //                         Only work if valid pointer is found, set some pointers to the array elements
	$ListOfItemNames_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //               This is the item tag
	$ListOfItemVariables_ptr:=$Object_ptr->{<>OTX_ItemVariables_i}  //       This is the item variable ptr
	$ListOfItemTypes_ptr:=$Object_ptr->{<>OTX_ItemTypes_i}  //               This is the item type
	$ItemPosition_i:=OTX Get Item Position($Object_ptr; $inTag_t)  //       Get the item position within the object
	If ($ItemPosition_i=-1)  //                                              If the item does not exist, create it
		OK:=0  //                                                             Set OK to 0
	Else 
		$ItemType_i:=$ListOfItemTypes_ptr->{$ItemPosition_i}  //              Get the item type
		If (rVar_IsAnArray($ItemType_i))  //                                if it is the correct type
			$ItemVariable_ptr:=$ListOfItemVariables_ptr->{$ItemPosition_i}  //  
			rVar_ArrSetSize($ItemVariable_ptr; $inSize_i)
		Else 
			OK:=0  //                                                         otherwise set OK to 0
		End if 
	End if 
End if 