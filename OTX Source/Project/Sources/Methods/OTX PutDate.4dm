//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX PutDate
// Global and IP variables accessed:     None Used

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_DATE:C307($inValue_i; $3)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i)
C_POINTER:C301($Object_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr; $ItemVariable_ptr)


// Returns:    Nothing

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$inTag_t:=$2
$inValue_i:=$3

$MethodItemType_i:=Is date:K8:7

$Object_ptr:=OTX Get Object Pointer($inObject_i)  //  Find the object pointer, OK is set to 1 if the object exists

If (OK=1)  //  Only work if valid pointer is found
	//  Set some pointers to the array elements
	$ListOfItemNames_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //  This is the item tag
	$ListOfItemVariables_ptr:=$Object_ptr->{<>OTX_ItemVariables_i}  //  This is the item variable ptr
	$ListOfItemTypes_ptr:=$Object_ptr->{<>OTX_ItemTypes_i}  //  This is the item type
	
	$ItemPosition_i:=OTX Get Item Position($Object_ptr; $inTag_t)  //  Get the item position within the object
	
	If ($ItemPosition_i=-1)  //  If the item does not exist, create and set it
		APPEND TO ARRAY:C911($ListOfItemNames_ptr->; $inTag_t)  //                   Store the item tag
		$ItemVariable_ptr:=rVar_GetVariableByType($MethodItemType_i)  //  Get an rVar to store the variable data
		$ItemVariable_ptr->:=$inValue_i  //                                    Assign the value
		APPEND TO ARRAY:C911($ListOfItemVariables_ptr->; $ItemVariable_ptr)  //      Store the pointer in the array 
		APPEND TO ARRAY:C911($ListOfItemTypes_ptr->; $MethodItemType_i)  //          Store the data type
		
	Else 
		$ItemType_i:=$ListOfItemTypes_ptr->{$ItemPosition_i}  //  Get the item type
		If ($ItemType_i=$MethodItemType_i)  //  if it is the correct type
			$ItemVariable_ptr:=$ListOfItemVariables_ptr->{$ItemPosition_i}
			$ItemVariable_ptr->:=$inValue_i  //  assign the value
			
		Else 
			OK:=0  //  otherwise set OK to 0
			
		End if 
	End if 
End if 

