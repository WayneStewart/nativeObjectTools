//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SaveToFile (dict ID; path)

// Saves a dictionary as a file.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Path to the file to create (or update)

// Returns: Nothing

// Created by Rob Laveaux
// Modified by Gary Boudreaux on Dec 22, 2008
//   Corrected description of data type of $2 in header
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)
C_TEXT:C284($2; $filename_t)

$dictionary_i:=$1
$filename_t:=$2

Dict_Save($dictionary_i; ->$filename_t)
