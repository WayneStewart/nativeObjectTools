//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetBlob (dict ID; key) --> Text

// Returns a text value from a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name
C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $key_t)

// Returns: 
//   $0 : BLOB : The key's value
C_BLOB:C604($0; $BlobValue_x)

// Local Variables
C_PICTURE:C286($BlobStoredInPicture_pic)

// Created by Wayne Stewart
// ----------------------------------------------------

$dictionary_i:=$1
$key_t:=$2

$BlobStoredInPicture_pic:=Dict_GetPicture($dictionary_i; $key_t)

PICTURE TO BLOB:C692($BlobStoredInPicture_pic; $BlobValue_x; "blob")

$0:=$BlobValue_x