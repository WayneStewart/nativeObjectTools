//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Init

// Initialises the dictionary module.

// Access: Private

// Parameters: None

// Returns: Nothing

// Created by Rob Laveaux
// ----------------------------------------------------




If (Storage:C1525.dict.initialised=Null:C1517)
	Use (Storage:C1525)
		Storage:C1525.v4:=New shared object:C1526("initialised"; False:C215)
		
		
		
		
		
	End use 
End if 




C_BOOLEAN:C305(<>Dict_Initialised_b; Dict_Initialised_b)
C_LONGINT:C283(<>Dict_LockCount_ai)

If (Not:C34(<>Dict_Initialised_b))
	Compiler_Dict
	<>Dict_SequentialCounter_i:=0
	<>Dict_LockCount_ai:=0
	
	ARRAY TEXT:C222(<>Dict_Names_at; 0)
	ARRAY LONGINT:C221(<>Dict_RetainCounts_ai; 0)
	
	ARRAY TEXT:C222(<>Dict_Keys_at; 0; 0)
	ARRAY TEXT:C222(<>Dict_Values_at; 0; 0)
	ARRAY LONGINT:C221(<>Dict_DataTypes_ai; 0; 0)
	
	ARRAY PICTURE:C279(<>Dict_PictValues_apic; 0)  //  This will be rarely used so I will not bother with two dimensional array
	ARRAY TEXT:C222(<>Dict_PictIndexSlots_at; 0)  //  To track which slots are free
	
	<>Dict_Initialised_b:=True:C214
	<>Dict_StructureName_t:=Structure file:C489(*)
	
	Dict_FoundationPresent
	Dict_CheckHostMethods
	
	<>Dict_SemaphoreName_t:="$Dict_InternalState"
	
End if 

If (Not:C34(Dict_Initialised_b))
	Compiler_Dict
	Dict_APD_ID_i:=0
	Dict_Initialised_b:=True:C214
	
End if 
