//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_GetAvailablePictureSlot

// Method Type:    Private

// Parameters:
C_TEXT:C284($IndexedLocation_t; $1)
// Local Variables:
C_LONGINT:C283($Position_i)
C_PICTURE:C286($Blank_pic)

// Created by Wayne Stewart (Jun 28, 2012)
//     waynestewart@mac.com

//   Returns the array index of an available picture slot
C_LONGINT:C283($0)
// ----------------------------------------------------

$IndexedLocation_t:=$1

$Position_i:=Find in array:C230(<>Dict_PictIndexSlots_at; "")
If ($Position_i>0)
	<>Dict_PictIndexSlots_at{$Position_i}:=$IndexedLocation_t
Else 
	APPEND TO ARRAY:C911(<>Dict_PictIndexSlots_at; $IndexedLocation_t)
	$Position_i:=Size of array:C274(<>Dict_PictIndexSlots_at)
	ARRAY PICTURE:C279(<>Dict_PictValues_apic; $Position_i)
End if 

$0:=$Position_i