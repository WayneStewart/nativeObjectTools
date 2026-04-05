//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX InsertElement

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_LONGINT:C283($inWhere_i; $3)
C_LONGINT:C283($inHowMany_i; $4)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i)
C_POINTER:C301($Object_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr; $ItemVariable_ptr)

// Created by Wayne Stewart (Sep 13, 2007)
//     waynestewart@mac.com

//  Discussion 
//    OT InsertElement inserts one or more elements into an array in inObject. 

//    If inObject is not a valid object handle, if no item in the object has the given tag, 
//    or if the item’s type is not an array type, an error is generated and OK is set to 
//    zero. 

//    The new elements are inserted before the element specified by inWhere, and are 
//    initialized to an empty value for the array type. All elements beyond inWhere 
//    are moved up to make room for the new elements. 

//    If inWhere is greater than the size of the array, the elements are added to the end 
//    of the array. 

//    OT InsertElement(inObject; inTag; inWhere {; inHowMany}) 
//    Parameter      Type            Description 
//    inObject       Longint         A handle to an object 
//    inTag          String          Tag of the array item to change 
//    inWhere        Number          Where to insert 
//    inHowMany      Number          How many elements to insert

// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$inTag_t:=$2
$inWhere_i:=$3

Case of 
	: (Count parameters:C259=3)
		$inHowMany_i:=1
	: ($4=0)  //  Unlikely
		$inHowMany_i:=1
	Else 
		$inHowMany_i:=$4
End case 


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
			$ItemVariable_ptr:=$ListOfItemVariables_ptr->{$ItemPosition_i}  // Get the pointer to the array
			INSERT IN ARRAY:C227($ItemVariable_ptr->; $inWhere_i; $inHowMany_i)  //   Insert the elements
		Else 
			OK:=0  //                                                         otherwise set OK to 0
		End if 
	End if 
End if 

