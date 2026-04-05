//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Method: OTX ItemType
// Global and IP variables accessed:     None Used

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_POINTER:C301($Object_ptr; $3)

// Local Variables:
C_POINTER:C301($ListOfItemTypes_ptr)
C_LONGINT:C283($ItemPosition_i)

// Returns:
C_LONGINT:C283($0; $ItemType_i)

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

$inObject_i:=$1
$inTag_t:=$2

If (Count parameters:C259=3)
	$Object_ptr:=$3
	
Else 
	$Object_ptr:=OTX Get Object Pointer($inObject_i)
	
End if 



If (OK=1)
	$ItemPosition_i:=OTX Get Item Position($Object_ptr; $inTag_t)
	$ListOfItemTypes_ptr:=$Object_ptr->{<>OTX_ItemTypes_i}
	$ItemType_i:=$ListOfItemTypes_ptr->{$ItemPosition_i}
	$0:=$ItemType_i
	
Else 
	$0:=0
	
End if 