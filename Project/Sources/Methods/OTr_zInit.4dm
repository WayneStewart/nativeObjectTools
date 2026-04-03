//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zInit

// Initialises the OTr registry arrays and default module state.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------


If (Storage:C1525.OTr=Null:C1517)
	
	var $fullpath : Object
	var $name : Text
	var $ApplicationVersion_i : Integer
	
	If (Application type:C494#4D Remote mode:K5:5)
		$fullpath:=Path to object:C1547(Structure file:C489(*))
		$name:=$fullpath.name
	End if 
	
	$ApplicationVersion_i:=Num:C11(Application version:C493)
	Use (Storage:C1525)
		Storage:C1525.OTr:=New shared object:C1526("structureName"; $name; "nativeBlobInObject"; ($ApplicationVersion_i>=1920))
	End use 
End if 




C_BOOLEAN:C305(<>OTR_Initialised_b)

Compiler_OTr


If (Not:C34(<>OTR_Initialised_b))
	
	
	<>OTR_Options_i:=4  // AutoCreateObjects on by default.
	<>OTR_ErrorHandler_t:=""
	
	<>OTR_Semaphore_t:="$OTr_Registry"
	
	<>OTR_Initialised_b:=True:C214
End if 

