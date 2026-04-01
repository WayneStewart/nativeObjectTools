//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_Save (dict ID; ->blob or path)

// Saves a dictionary as either a blob or a file.

// Access Type: Private

// Parameters: 
//   $1 : Longint : Dictionary ID
//   $2 : Pointer : Blob or path

// Returns: Nothing

// Created by Rob Laveaux
// Modified by Dave Batton on Sep 24, 2007
//   Wrapped the XML command in EXECUTE statements so the method can be compiled
//   with 4D 2003. Also added an error message in case it gets run in 4D 2003.
// Modified by Dave Batton on Jan 8, 2008
//   Changed all of the hard-coded 4D commands in EXECUTE statements to use "Command name" instead.
// Modified by: Wayne Stewart (Aug 14, 2012)
//   Replaced global vars with locals?


// ----------------------------------------------------

C_LONGINT:C283($1; $dictionary_i; $index_i)
C_POINTER:C301($2; $Dict_Destination_ptr)
C_TEXT:C284($value_t; $0)


_O_C_STRING:C293(16; $Dict_RootNode_s; $Dict_ItemNode_s; $Dict_KeyNode_s; $Dict_TypeNode_s; $Dict_ValueNode_s)


$dictionary_i:=$1
If (Count parameters:C259=2)
	$Dict_Destination_ptr:=$2
End if 

Dict_LockInternalState(True:C214)

If (Dict_IsValid($dictionary_i))
	
	// Create the XML document
	$Dict_RootNode_s:=DOM Create XML Ref:C861("dictionary")
	
	// Set the version and name attributes for the root node
	DOM SET XML ATTRIBUTE:C866($Dict_RootNode_s; "version"; "1.0")
	DOM SET XML ATTRIBUTE:C866($Dict_RootNode_s; "name"; <>Dict_Names_at{$dictionary_i})
	
	// Loop through the items in the dictionary
	For ($index_i; 1; Size of array:C274(<>Dict_Keys_at{$dictionary_i}))
		
		// Create the item, key, type and value elements
		$Dict_ItemNode_s:=DOM Create XML element:C865($Dict_RootNode_s; "item")
		
		$Dict_KeyNode_s:=DOM Create XML element:C865($Dict_ItemNode_s; "key")
		$value_t:=<>Dict_Keys_at{$dictionary_i}{$index_i}
		DOM SET XML ELEMENT VALUE:C868($Dict_KeyNode_s; $value_t)
		
		$Dict_TypeNode_s:=DOM Create XML element:C865($Dict_ItemNode_s; "type")
		$value_t:=String:C10(<>Dict_DataTypes_ai{$dictionary_i}{$index_i})
		DOM SET XML ELEMENT VALUE:C868($Dict_TypeNode_s; $value_t)
		
		$Dict_ValueNode_s:=DOM Create XML element:C865($Dict_ItemNode_s; "value")
		$value_t:=<>Dict_Values_at{$dictionary_i}{$index_i}
		DOM SET XML ELEMENT VALUE:C868($Dict_ValueNode_s; $value_t)
		
	End for 
	
	// Save the XML data to a blob or to a file
	Case of 
		: (Is nil pointer:C315($Dict_Destination_ptr))
			DOM EXPORT TO VAR:C863($Dict_RootNode_s; $0)
		: (Type:C295($Dict_Destination_ptr->)=Is BLOB:K8:12)
			DOM EXPORT TO VAR:C863($Dict_RootNode_s; $Dict_Destination_ptr->)
		: (Type:C295($Dict_Destination_ptr->)=Is text:K8:3)
			DOM EXPORT TO FILE:C862($Dict_RootNode_s; $Dict_Destination_ptr->)
	End case 
	
	DOM CLOSE XML:C722($Dict_RootNode_s)
	
End if 

Dict_LockInternalState(False:C215)


