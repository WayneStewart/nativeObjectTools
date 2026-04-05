//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTX Get Object Pointer
// Global and IP variables accessed:     None Used

// Method Type:    Private

// Parameters:
C_LONGINT:C283($inObject_i; $1)

// Local Variables:
C_LONGINT:C283($arrayPos_i)

// Returns:
C_POINTER:C301($0; $Object_ptr)

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

$inObject_i:=$1


$arrayPos_i:=Find in array:C230(<>OTX_ListOfObjects_ai; $inObject_i)

If ($arrayPos_i=-1)
	OK:=0  //  Error
Else 
	$Object_ptr:=<>OTX_Objects_aptr{$arrayPos_i}
	OK:=1
End if 

$0:=$Object_ptr