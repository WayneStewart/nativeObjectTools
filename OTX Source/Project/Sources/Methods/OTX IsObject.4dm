//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX IsObject

// Global and IP variables accessed:     None Used

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)

// Local Variables:
C_LONGINT:C283($arrayPos_i)

// Returns:
C_LONGINT:C283($0)

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$arrayPos_i:=Find in array:C230(<>OTX_ListOfObjects_ai; $inObject_i)

If ($arrayPos_i=-1)
	$0:=0  //  Doesn't exist
Else 
	$0:=1
End if 