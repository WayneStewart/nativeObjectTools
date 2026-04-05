//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX GetArray

// Method Type:    Protected

C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_POINTER:C301($PointerToArray_ptr; $3)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i)
C_POINTER:C301($Object_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr; $ItemVariable_ptr)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

// Discussion 
//   OT GetArray gets an array value in inObject from the item referenced by inTag. 
//   If the object is not a valid object handle, an error is generated, OK is set to zero, 
//   and outArray is cleared. 
//   If no item in the object has the given tag, outArray is cleared. If the 
//   FailOnNoItem option is set, an error is generated and OK is set to zero. 
//   If an item with the given tag exists and has a compatible type, the array’s 
//   contents are replaced. 
//   If an item with the given tag exists and has any other type, an error is generated, 
//   OK is set to zero, and array is cleared. 

//   Array Type Compatibility 
//   Except for String and Text arrays, you must put and get arrays into the same 
//   type of array variable. String and Text arrays, however, may be mixed and 
//   matched, because ObjectTools stores both types of array with an item type of 
//   text.

//   OT GetArray(inObject; inTag; outArray) 
//   Parameter       Type            Description 
//   inObject        Longint         A handle to an object 
//   inTag           String          Tag of the item to set 
//   outArray        Array           Array to receive the item’s contents 

// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$inTag_t:=$2
$PointerToArray_ptr:=$3

$MethodItemType_i:=Type:C295($PointerToArray_ptr->)

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
		If ($ItemType_i=$MethodItemType_i)  //                                if it is the correct type
			$ItemVariable_ptr:=$ListOfItemVariables_ptr->{$ItemPosition_i}  //  
			COPY ARRAY:C226($ItemVariable_ptr->; $PointerToArray_ptr->)  //  copy new array over old array
		Else 
			OK:=0  //                                                         otherwise set OK to 0
		End if 
	End if 
End if 


