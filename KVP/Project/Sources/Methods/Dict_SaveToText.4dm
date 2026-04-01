//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SaveToText (dict ID; path)

// Saves a dictionary as a file.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Path to the file to create (or update)

// Returns: Nothing

// Created by Wayne Stewart (Jan 2, 2013)

// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)

$dictionary_i:=$1

$0:=Dict_Save($dictionary_i)  //;->$filename_t)
