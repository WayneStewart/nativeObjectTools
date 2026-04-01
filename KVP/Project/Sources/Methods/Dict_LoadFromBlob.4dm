//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_LoadFromBlob (->blob) --> Longint

// LoaKVP a dictionary from a BLOB.

// Access: Shared

// Parameters: 
//   $1 : Pointer : Dictionary as blob

// Returns: 
//   $0 : Longint : Dictionary ID

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($0; $dictionary_i)
C_POINTER:C301($1; $source_ptr)

$source_ptr:=$1

$dictionary_i:=Dict_Load($source_ptr)

$0:=$dictionary_i