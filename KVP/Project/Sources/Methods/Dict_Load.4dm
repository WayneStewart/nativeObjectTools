//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_Load (->blob or path)

// Load a dictionary from either a blob or a file

// Access: Private

// Parameters: 
//   $1 : Pointer : Dictionary or path

// Returns: 
//   $0 : Longint : Dictionary ID

// Created by Rob Laveaux
// ----------------------------------------------------

C_LONGINT:C283($0; $dictionary_i; $index_i; $count_i; $type_i)
C_POINTER:C301($1; $source_ptr)
C_TEXT:C284($2)
_O_C_STRING:C293(16; $rootNode_s; $itemNode_s; $key_tNode_s; $type_iNode_s; $value_tNode_s)
C_TEXT:C284($tagName_t; $version_t; $name_t; $key_t; $value_t)

$source_ptr:=$1

// Parse the XML data
Case of 
	: (Count parameters:C259=2)  //  Text variable passed in
		$rootNode_s:=DOM Parse XML variable:C720($2; False:C215)
		
	: (Type:C295($source_ptr->)=Is BLOB:K8:12)
		$rootNode_s:=DOM Parse XML variable:C720($source_ptr->; False:C215)
		
	: (Type:C295($source_ptr->)=Is text:K8:3)
		$rootNode_s:=DOM Parse XML source:C719($source_ptr->; False:C215)
		
	Else 
		OK:=0
End case 

// If parsed successfully
If (OK=1)
	
	// Get some info from the root element
	DOM GET XML ELEMENT NAME:C730($rootNode_s; $tagName_t)
	DOM GET XML ATTRIBUTE BY NAME:C728($rootNode_s; "version"; $version_t)
	DOM GET XML ATTRIBUTE BY NAME:C728($rootNode_s; "name"; $name_t)
	
	// Check the tag name of the root element and the version to see if it looks valid
	If (($tagName_t="dictionary") & ($version_t="1.0"))
		
		// Everything looks valid, so let's create the dictionary
		$dictionary_i:=Dict_New($name_t)
		
		// Get the number of item nodes
		$count_i:=DOM Count XML elements:C726($rootNode_s; "item")
		
		For ($index_i; 1; $count_i)
			
			// Get the key, type and value
			$itemNode_s:=DOM Get XML element:C725($rootNode_s; "item"; $index_i)
			$key_tNode_s:=DOM Get XML element:C725($itemNode_s; "key"; 1; $key_t)
			$type_iNode_s:=DOM Get XML element:C725($itemNode_s; "type"; 1; $type_i)
			$value_tNode_s:=DOM Get XML element:C725($itemNode_s; "value"; 1; $value_t)
			
			// If we have a key and value, add it to the dictionary
			If (($key_t#"") & ($value_t#""))
				Dict_SetValue($dictionary_i; $key_t; $value_t; $type_i)
			End if 
			
		End for 
		
	End if 
	
	DOM CLOSE XML:C722($rootNode_s)
	
End if 

$0:=$dictionary_i