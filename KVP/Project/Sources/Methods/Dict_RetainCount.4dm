//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_RetainCount (dict ID) --> Longint

// Returns the retain count for a dictionary

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID

// Returns: 
//   $0 : Longint : Retain count

// Created by Rob Laveaux
// Modified by Dave Batton on Sep 23, 2007
//   Added a default retain count to be returned if the reference is not valid.
// ----------------------------------------------------

C_LONGINT:C283($0; $1; $retainCount_i; $dictionary_i)

$dictionary_i:=$1

Dict_LockInternalState(True:C214)

$retainCount_i:=0  // DB070923

If (Dict_IsValid($dictionary_i))
	$retainCount_i:=<>Dict_RetainCounts_ai{$dictionary_i}
End if 

Dict_LockInternalState(False:C215)

$0:=$retainCount_i