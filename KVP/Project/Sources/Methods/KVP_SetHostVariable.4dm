//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: KVP_SetHostVariable

// Method Type:    Private

// Parameters:
C_TEXT:C284($1; $2; $3; $4)

// Local Variables:
C_LONGINT:C283($NumberOfVars_i)

// Created by Wayne Stewart (Jun 14, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------

$NumberOfVars_i:=Count parameters:C259\2

If ($NumberOfVars_i=1)
	EXECUTE METHOD:C1007("KVP_Host_SetVariable"; *; $1; $2)
Else 
	EXECUTE METHOD:C1007("KVP_Host_SetVariable"; *; $1; $2; $3; $4)
End if 
