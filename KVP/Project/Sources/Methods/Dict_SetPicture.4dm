//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetPicture (dict ID; key; Picture; Blob or Pic?)

// Assigns a Picture to a dictionary given a key

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
//   $3 : Picture : Picture to store
//   $4 : Boolean : Actually a Blob

// Returns: Nothing

// Created by Wayne Stewart (Jun 27, 2012)

// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i; $PictureIndex_i)
C_TEXT:C284($2; $key_t; $PictureIndex_t)
C_PICTURE:C286($3; $value_pic)

$dictionary_i:=$1
$key_t:=$2
$value_pic:=$3

//  Find a slot in the pictures array to store the picture
$PictureIndex_i:=Dict_GetAvailablePictureSlot(Dict_Name($dictionary_i)+"."+$key_t)



Case of 
	: (Count parameters:C259=3)
		//  Create a tag to reference the picture later
		$PictureIndex_t:="Picture at: "+String:C10($PictureIndex_i)
		
	: ($4)
		//  Create a tag to reference the Blob later
		$PictureIndex_t:="Blob at: "+String:C10($PictureIndex_i)
		
	Else 
		//  Create a tag to reference the picture later
		$PictureIndex_t:="Picture at: "+String:C10($PictureIndex_i)
		
End case 

//  Store that tag as a text value
Dict_SetValue($dictionary_i; $key_t; $PictureIndex_t; Is text:K8:3)

//  Now insert the picture in the array
<>Dict_PictValues_apic{$PictureIndex_i}:=$value_pic

