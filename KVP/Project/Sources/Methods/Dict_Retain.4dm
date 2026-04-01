//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Retain (dict ID)

// Increments the retain count for a dictionary.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i)

$dictionary_i:=$1

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i))
	<>Dict_RetainCounts_ai{$dictionary_i}:=<>Dict_RetainCounts_ai{$dictionary_i}+1
End if 

Dict_LockInternalState(False:C215)
