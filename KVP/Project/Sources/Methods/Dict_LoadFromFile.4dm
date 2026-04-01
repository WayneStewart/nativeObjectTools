//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_LoadFromFile (path) --> Longint

// LoaKVP a dictionary from a file.

// Access: Shared

// Parameters: 
//   $1 : Text : File path

// Returns: 
//   $0 : Longint : Dictionary ID

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($0; $dictionary_i)
C_TEXT:C284($1; $filename_t)

$filename_t:=$1

$dictionary_i:=Dict_Load(->$filename_t)

$0:=$dictionary_i