//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetBlob

// Method Type:    Shared

// Parameters:
C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $key_t)
C_BLOB:C604($3; $BlobValue_x)

// Local Variables:
C_PICTURE:C286($BlobStoredInPicture_pic)

// Created by Wayne Stewart (Jun 29, 2012)
//     waynestewart@mac.com
//   
// ----------------------------------------------------

$dictionary_i:=$1
$key_t:=$2
$BlobValue_x:=$3

BLOB TO PICTURE:C682($BlobValue_x; $BlobStoredInPicture_pic; "blob")

Dict_SetPicture($dictionary_i; $key_t; $BlobStoredInPicture_pic; True:C214)

