//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_LoadFromText (Text Variable) --> Longint

// LoaKVP a dictionary from a Text Variable.

// Access: Shared

// Parameters: 
//   $1 : Text : Text Variable containing Dictionary data in XML format

// Returns: 
//   $0 : Longint : Dictionary ID

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($0; $dictionary_i)
C_TEXT:C284($1; $DictionaryAsText_t)
C_POINTER:C301($Nil_ptr)

$DictionaryAsText_t:=$1

$dictionary_i:=Dict_Load($Nil_ptr; $DictionaryAsText_t)

$0:=$dictionary_i