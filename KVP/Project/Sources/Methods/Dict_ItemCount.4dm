//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_ItemCount (dict ID) --> Number

// Returns the number of items in a dictionary.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID

// Returns: 
//   $0 : Longint : Item count

// Created by Rob Laveaux
// Modified by Gary Boudreaux on Dec 22, 2008
//   Corrected description of $1 in header
// ----------------------------------------------------

C_LONGINT:C283($0; $1; $count_i; $dictionary_i)

$dictionary_i:=$1

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i))
	$count_i:=Size of array:C274(<>Dict_Keys_at{$dictionary_i})
End if 

Dict_LockInternalState(False:C215)

$0:=$count_i