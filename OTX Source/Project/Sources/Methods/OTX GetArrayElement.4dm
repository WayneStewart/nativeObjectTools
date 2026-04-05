//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX GetArrayElement

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_LONGINT:C283($inIndex_i; $3)
C_LONGINT:C283($inArrayType_i; $4)
C_POINTER:C301($io_ArrayElement_ptr; $5)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i)
C_POINTER:C301($Object_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr; $ItemVariable_ptr)

// Created by Wayne Stewart (Sep 13, 2007)
//     waynestewart@mac.com

//  This method is called by OTX GetArray[TYPE]
//    That way the parent method can be very simple
// ----------------------------------------------------

$inObject_i:=$1
$inTag_t:=$2
$inIndex_i:=$3
$MethodItemType_i:=$4
$io_ArrayElement_ptr:=$5

$Object_ptr:=OTX Get Object Pointer($inObject_i)  //  Find the object pointer, OK is set to 1 if the object exists

If (OK=1)  //                         Only work if valid pointer is found, set some pointers to the array elements
	$ListOfItemNames_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //               This is the item tag
	$ListOfItemVariables_ptr:=$Object_ptr->{<>OTX_ItemVariables_i}  //       This is the item variable ptr
	$ListOfItemTypes_ptr:=$Object_ptr->{<>OTX_ItemTypes_i}  //               This is the item type
	$ItemPosition_i:=OTX Get Item Position($Object_ptr; $inTag_t)  //       Get the item position within the object
	If ($ItemPosition_i=-1)  //                                              If the item does not exist, set OK to 0
		OK:=0
	Else 
		$ItemType_i:=$ListOfItemTypes_ptr->{$ItemPosition_i}  //               Get the item type
		If ($ItemType_i=$MethodItemType_i)  //                                 if it is the correct type
			$ItemVariable_ptr:=$ListOfItemVariables_ptr->{$ItemPosition_i}  //  Get the pointer to the array
			If (Size of array:C274($ItemVariable_ptr->)>=$inIndex_i)
				$io_ArrayElement_ptr->:=$ItemVariable_ptr->{$inIndex_i}  //          assign the value
			Else 
				OK:=0  //  otherwise set OK to 0
			End if 
		Else 
			OK:=0  //  otherwise set OK to 0
		End if 
	End if 
End if 

