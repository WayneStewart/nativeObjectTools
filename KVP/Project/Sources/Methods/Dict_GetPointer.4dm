//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetPointer (dict ID; key) --> Pointer

// Returns a pointer value from a dictionary given a key.

// Access: Shared

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Text : Key name

// Returns: 
//   $0 : Pointer : The key's value

// Created by Rob Laveaux

//  Wayne Stewart
//  The initial version of this procedure worked in 2004
//   it suffered with the conversion to v11 :(

// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i; $tableNum_i; $fieldNum_i; $position_i)
C_TEXT:C284($2; $key_t; $variableName_t; $text_t)
C_POINTER:C301($0; $value_ptr)

$dictionary_i:=$1
$key_t:=$2

$text_t:=Dict_GetValue($dictionary_i; $key_t)

If ($text_t#"")
	
	// Convert the text to a pointer
	
	// Split the stored values
	$position_i:=Position:C15(";"; $text_t)
	$variableName_t:=Substring:C12($text_t; 1; $position_i-1)
	$text_t:=Substring:C12($text_t; $position_i+1)
	
	$position_i:=Position:C15(";"; $text_t)
	$tableNum_i:=Num:C11(Substring:C12($text_t; 1; $position_i-1))
	$text_t:=Substring:C12($text_t; $position_i+1)
	
	$fieldNum_i:=Num:C11($text_t)
	
	If (True:C214)  //  This is the new version
		
		
		
		
		// Construct a pointer from the various parts
		Case of 
			: (($variableName_t#"") & ($tableNum_i=-1))  //  This is a pointer to a variable 
				EXECUTE METHOD:C1007("Host_Dict_GetPointer"; $value_ptr; $variableName_t)
				
				//$value_ptr:=Get pointer($variableName_t)
				
			: (($variableName_t#"") & ($tableNum_i>0))  //  This is a pointer to an array element
				$value_ptr:=Get pointer:C304($variableName_t+"{"+String:C10($tableNum_i)+"}")  // Not sure if this works
				
			: (($tableNum_i>0) & ($fieldNum_i=0))  //  This is a pointer to a table
				$value_ptr:=Table:C252($tableNum_i)
				
			: (($tableNum_i>0) & ($fieldNum_i>0))  //  This is a pointer to a field
				$value_ptr:=Field:C253($tableNum_i; $fieldNum_i)
		End case 
		
	Else 
		
		// Construct a pointer from the various parts
		Case of 
			: (($variableName_t#"") & ($tableNum_i=-1))  //  This is a pointer to a variable 
				$value_ptr:=Get pointer:C304($variableName_t)
				
			: (($variableName_t#"") & ($tableNum_i>0))  //  This is a pointer to an array element
				$value_ptr:=Get pointer:C304($variableName_t+"{"+String:C10($tableNum_i)+"}")  // Not sure if this works
				
			: (($tableNum_i>0) & ($fieldNum_i=0))  //  This is a pointer to a table
				$value_ptr:=Table:C252($tableNum_i)
				
			: (($tableNum_i>0) & ($fieldNum_i>0))  //  This is a pointer to a field
				$value_ptr:=Field:C253($tableNum_i; $fieldNum_i)
		End case 
		
	End if 
	
	
	
End if 

$0:=$value_ptr