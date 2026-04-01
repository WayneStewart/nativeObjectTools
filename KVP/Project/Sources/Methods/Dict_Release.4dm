//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Release (dict ID)

// Decrements the retain count of a dictionary and deletes it when the retain count reaches 0.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i; $count_i; $index_i)

$dictionary_i:=$1

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i; True:C214))
	
	// Decrement the retain count
	If (<>Dict_RetainCounts_ai{$dictionary_i}>0)
		<>Dict_RetainCounts_ai{$dictionary_i}:=<>Dict_RetainCounts_ai{$dictionary_i}-1
	End if 
	
	// If the retain count is 0, delete the dictionary
	If (<>Dict_RetainCounts_ai{$dictionary_i}<1)
		//  Blank out the dictionary name to allow this name to be reused
		<>Dict_Names_at{$dictionary_i}:=""
		
		// Delete the items in the dictionary
		$count_i:=Size of array:C274(<>Dict_Keys_at{$dictionary_i})
		If ($count_i>0)
			DELETE FROM ARRAY:C228(<>Dict_Keys_at{$dictionary_i}; 1; $count_i)
			Dict_DeleteAllPictures($dictionary_i)
			DELETE FROM ARRAY:C228(<>Dict_Values_at{$dictionary_i}; 1; $count_i)
			DELETE FROM ARRAY:C228(<>Dict_DataTypes_ai{$dictionary_i}; 1; $count_i)
		End if 
		
		// Remove all deleted dictionaries at the end
		// Since the index is the reference, we can only remove at the end
		$index_i:=Size of array:C274(<>Dict_RetainCounts_ai)
		While ($index_i>0)
			If (<>Dict_RetainCounts_ai{$index_i}=0)
				DELETE FROM ARRAY:C228(<>Dict_Names_at; $index_i)
				DELETE FROM ARRAY:C228(<>Dict_RetainCounts_ai; $index_i)
				DELETE FROM ARRAY:C228(<>Dict_Keys_at; $index_i)
				DELETE FROM ARRAY:C228(<>Dict_Values_at; $index_i)
				DELETE FROM ARRAY:C228(<>Dict_DataTypes_ai; $index_i)
				$index_i:=$index_i-1
			Else 
				$index_i:=0
			End if 
		End while 
		
	End if 
	
End if 

Dict_LockInternalState(False:C215)
