//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_IsValid (dict ID) --> Boolean

// Checks whether a dictionary reference is valid.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID

// Returns: 
//   $0 : Boolean : True if the dictionary reference is valid

// Created by Rob Laveaux
// Modified by Dave Batton on Sep 21, 2007
//   Removed second parameter. No longer displays error message if not valid.
// ----------------------------------------------------

C_BOOLEAN:C305($0; $isValid_b)
C_LONGINT:C283($1; $dictionary_i)

$dictionary_i:=$1

$isValid_b:=False:C215

Dict_LockInternalState(True:C214)

// Check if the index is valid and the retain count larger than 0
If (($dictionary_i>0) & ($dictionary_i<=Size of array:C274(<>Dict_RetainCounts_ai)))
	$isValid_b:=(<>Dict_RetainCounts_ai{$dictionary_i}>0)
End if 

Dict_LockInternalState(False:C215)

$0:=$isValid_b
