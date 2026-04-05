//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTX Get Item Position
// Global and IP variables accessed:     None Used

// Method Type:    Private

// Parameters:
C_POINTER:C301($Object_ptr; $1)
C_TEXT:C284($inTag_t; $2)

// Local Variables:
C_POINTER:C301($ListOfItemNames_ptr)

// Returns:
C_LONGINT:C283($0; $ItemPosition_i)

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

$Object_ptr:=$1
$inTag_t:=$2

$ListOfItemNames_ptr:=$Object_ptr->{<>OTX_ItemNames_i}
$ItemPosition_i:=Find in array:C230($ListOfItemNames_ptr->; $inTag_t)

$0:=$ItemPosition_i