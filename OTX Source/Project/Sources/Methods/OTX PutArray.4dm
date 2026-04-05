//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX PutArray

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_POINTER:C301($PointerToArray_ptr; $3)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i)
C_POINTER:C301($Object_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr; $ItemVariable_ptr)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

//  Discussion 
//   OT PutArray puts inArray into inObject. The element count and current element 
//   are stored with the array elements and are restored by OT GetArray. You may not 
//   store two-dimensional arrays in objects. 
//   If inObject is not a valid object handle, an error is generated and OK is set to 
//   zero. 
//   If no item in the object has the given tag, a new item is created. 
//   If an item with the given tag exists and has a compatible type (see below), its 
//   value is replaced. 
//   If an item with the given tag exists and has any other type, an error is generated 
//   and OK is set to zero if the OT VariantItems option is not set, otherwise the 
//   existing item is deleted and a new item is created. 

//   Array Type Compatibility 
//   Except for String and Text arrays, you must put and get arrays into the same 
//   type of array variable. String and Text arrays, however, may be mixed and 
//   matched, because ObjectTools stores both types of array with an item type of 
//   text.

//   OT PutArray (inObject; inTag; inArray) 
//   Parameter       Type                Description 
//   inObject        Longint             A handle to an object 
//   inTag           String              Tag of the item to set 
//   inArray         Pointer to array    One-dimensional array to store

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
		APPEND TO ARRAY:C911($ListOfItemNames_ptr->; $inTag_t)  //                  Store the item tag
		$ItemVariable_ptr:=rVar_GetVariableByType($MethodItemType_i)  //     Get an rVar to store the variable data
		APPEND TO ARRAY:C911($ListOfItemVariables_ptr->; $ItemVariable_ptr)  //      Store the pointer in the array 
		COPY ARRAY:C226($PointerToArray_ptr->; $ItemVariable_ptr->)  //            copy new array over old array
		APPEND TO ARRAY:C911($ListOfItemTypes_ptr->; $MethodItemType_i)  //          Store the data type
	Else 
		$ItemType_i:=$ListOfItemTypes_ptr->{$ItemPosition_i}  //               Get the item type
		If ($ItemType_i=$MethodItemType_i)  //                                 if it is the correct type
			$ItemVariable_ptr:=$ListOfItemVariables_ptr->{$ItemPosition_i}  //  
			COPY ARRAY:C226($PointerToArray_ptr->; $ItemVariable_ptr->)  //          copy new array over old array
		Else 
			OK:=0  //                                                           otherwise set OK to 0
		End if 
	End if 
End if 







