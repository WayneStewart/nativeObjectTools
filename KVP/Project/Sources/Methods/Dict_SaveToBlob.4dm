//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SaveToBlob (dict ID; ->blob)

// Saves a dictionary as a blob.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Pointer : Blob to store dictionary

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_POINTER:C301($2; $destination_ptr)

$dictionary_i:=$1
$destination_ptr:=$2

Dict_Save($dictionary_i; $destination_ptr)
