//%attributes = {"invisible":true,"shared":true}

// ----------------------------------------------------
// Project Method: OTX ItemCount

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($InObject_i; $1)
C_LONGINT:C283($0; $ItemCount_i)

// Local Variables:
C_POINTER:C301($Object_ptr)

// Created by Wayne Stewart (Sep 7, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

$InObject_i:=$1
$ItemCount_i:=0  // initialise to 0

If (OTX IsObject($InObject_i)=1)
	$Object_ptr:=OTX Get Object Pointer($inObject_i)  //  Get the object pointer
	$Object_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //  Now point to one of the sub arrays
	$ItemCount_i:=Size of array:C274($Object_ptr->)  //  Can use any of the arrays
	OK:=1  //  Signal all went well
Else 
	OK:=0
End if 

$0:=$ItemCount_i