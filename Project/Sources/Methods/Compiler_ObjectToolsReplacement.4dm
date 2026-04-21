//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Compiler_ObjectToolsReplacement

// Declares all variables for the Object Tools Replacement component.

// Access: Private

// Parameters: None

// Returns: Nothing

// Created by Wayne Stewart (2026-03-31)
//     waynestewart@mac.com
// ----------------------------------------------------

C_BOOLEAN:C305(<>OTR_Initialised_b; OTR_Initialised_b)


If (Not:C34(<>OTR_Initialised_b))
	C_TEXT:C284(<>OTR_ErrorHandler_t; <>OTR_Semaphore_t)
	C_BOOLEAN:C305(<>OTR_Initialised_b)
	C_LONGINT:C283(<>OTR_Options_i)
	
	// The objects
	ARRAY BOOLEAN:C223(<>OTR_InUse_ab; 0)
	ARRAY OBJECT:C1221(<>OTR_Objects_ao; 0)
	
	Compiler_OTrSortInterprocess  // These are the arrays used in the sorting routines
	
End if 


If (Not:C34(OTR_Initialised_b))
	ARRAY TEXT:C222(OTR_callStack_at; 0)
	var OTR_LockCount_i : Integer
	var OTr_DummyVariableForTests_t : Text
	
	ARRAY LONGINT:C221(OTr_LongArrayForTests_ai; 0)
	ARRAY TEXT:C222(OTr_TextArrayForTests_at; 0)
	
	Compiler_OTrSortProcess  // These are the arrays used in the sorting routines
	
End if 
