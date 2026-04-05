//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX ItemExists

// Global and IP variables accessed:     None Used

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i)
C_POINTER:C301($Object_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr)

// Returns:
C_LONGINT:C283($0)

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$inTag_t:=$2

$Object_ptr:=OTX Get Object Pointer($inObject_i)  //  Find the object pointer, OK is set to 1 if the object exists

If (OK=1)  //  Only work if valid pointer is found
	//  Set some pointers to the array elements
	$ListOfItemNames_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //  This is the item tag
	$ListOfItemVariables_ptr:=$Object_ptr->{<>OTX_ItemVariables_i}  //  This is the item variable ptr
	$ListOfItemTypes_ptr:=$Object_ptr->{<>OTX_ItemTypes_i}  //  This is the item type
	$ItemPosition_i:=OTX Get Item Position($Object_ptr; $inTag_t)  //  Get the item position within the object
	If ($ItemPosition_i=-1)  //  If the item does not exist, return "" & set OK to 0
		OK:=0
	Else 
		OK:=1
	End if 
End if 

$0:=OK