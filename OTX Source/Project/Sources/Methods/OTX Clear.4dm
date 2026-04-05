//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX Clear

// Global and IP variables accessed:     None Used

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($ioObject_i; $1)

// Local Variables:
C_LONGINT:C283($arrayPos_i; $CurrentItem_i; $NumberOfItems_i)
C_POINTER:C301($Object_ptr; $ListOfItemVariables_ptr; $ItemVariable_ptr)

// Returns:

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

$ioObject_i:=$1


$arrayPos_i:=Find in array:C230(<>OTX_ListOfObjects_ai; $ioObject_i)

If ($arrayPos_i=-1)
	OK:=0  //  Error
Else 
	$Object_ptr:=<>OTX_Objects_aptr{$arrayPos_i}
	rVar_ReturnVariable($Object_ptr->{<>OTX_ItemNames_i})  //  Get rid of tags
	rVar_ReturnVariable($Object_ptr->{<>OTX_ItemTypes_i})  //  Get rid of types
	
	$ListOfItemVariables_ptr:=$Object_ptr->{<>OTX_ItemVariables_i}  //  This is the item variable ptr
	
	$NumberOfItems_i:=Size of array:C274($ListOfItemVariables_ptr->)
	
	For ($CurrentItem_i; 1; $NumberOfItems_i)
		$ItemVariable_ptr:=$ListOfItemVariables_ptr->{$CurrentItem_i}
		rVar_ReturnVariable($ItemVariable_ptr)  //  Get rid of this variable
		
	End for 
	
	rVar_ReturnVariable($ListOfItemVariables_ptr)  //  Get rid of item array now
	rVar_ReturnVariable($Object_ptr)  //  Get rid of this object now
	
	DELETE FROM ARRAY:C228(<>OTX_ListOfObjects_ai; $arrayPos_i)
	DELETE FROM ARRAY:C228(<>OTX_Objects_aptr; $arrayPos_i)
	
	
	OK:=1
End if 

