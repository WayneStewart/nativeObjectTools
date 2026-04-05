//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTX Init

// Initializes both the process and interprocess variables used by the OTX routines.

// Method Type:    Private

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

C_BOOLEAN:C305(<>OTX_Initialized_b; OTX_Initialized_b)

If (Not:C34(<>OTX_Initialized_b))  // So we only do this once.
	Compiler OTX
	<>OTX_Initialized_b:=True:C214
	<>OTX_ItemNames_i:=1
	<>OTX_ItemVariables_i:=2
	<>OTX_ItemTypes_i:=3
	
	
	
End if 

If (Not:C34(OTX_Initialized_b))  // So we only do this once.
	Compiler OTX
	OTX_Initialized_b:=True:C214
	
End if 


