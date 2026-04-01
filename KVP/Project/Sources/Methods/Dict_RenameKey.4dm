//%attributes = {"invisible":true,"shared":true}

// ----------------------------------------------------
// User name (OS): Wayne Stewart
// Date and time: Oct 3, 2009, 07:38:16
// ----------------------------------------------------
// Method: Dict_RenameKey
// Description
// Renames the key tag value 
//
// Parameters
C_LONGINT:C283($Dictionary_i; $1; $index_i)
C_TEXT:C284($OldTag_t; $2)
C_TEXT:C284($NewTag_t; $3)

// ----------------------------------------------------

$Dictionary_i:=$1
$OldTag_t:=$2
$NewTag_t:=$3

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i; True:C214))
	
	// Lookup the key and rename it
	$index_i:=Find in array:C230(<>Dict_Keys_at{$dictionary_i}; $OldTag_t)
	If ($index_i#-1)
		<>Dict_Keys_at{$dictionary_i}{$index_i}:=$NewTag_t
	End if 
	
End if 

Dict_LockInternalState(False:C215)
