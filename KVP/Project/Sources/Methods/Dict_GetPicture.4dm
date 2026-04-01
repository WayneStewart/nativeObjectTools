//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetPicture

// Method Type:    Shared

// Parameters:

C_LONGINT:C283($1; $dictionary_i; $PictureIndex_i)
C_TEXT:C284($2; $key_t; $PictureIndex_t)
C_PICTURE:C286($0; $Value_pic)
// Local Variables:

// Created by Wayne Stewart (Jun 28, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------


$dictionary_i:=$1
$key_t:=$2

$PictureIndex_t:=Dict_GetValue($dictionary_i; $key_t)

If ($PictureIndex_t="Picture at:@")
	$PictureIndex_i:=Num:C11(Substring:C12($PictureIndex_t; 13))
Else   // "Blob at: "
	$PictureIndex_i:=Num:C11(Substring:C12($PictureIndex_t; 10))
End if 

If (Size of array:C274(<>Dict_PictValues_apic)>=$PictureIndex_i)
	$Value_pic:=<>Dict_PictValues_apic{$PictureIndex_i}
End if 

$0:=$Value_pic