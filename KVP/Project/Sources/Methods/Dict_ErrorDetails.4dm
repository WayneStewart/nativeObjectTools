//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_ErrorDetails

// Global and IP variables accessed:
C_TEXT:C284(<>Dict_ErrorDetails_t)

If (False:C215)
	C_TEXT:C284(Dict_ErrorDetails; $1; $0)
End if 

// Method Type:    Shared

// Parameters:
C_TEXT:C284($1)

// Local Variables:
C_TEXT:C284($Dict_ErrorDetails_t)

// Returns:
C_TEXT:C284($0)

// Created by Wayne Stewart Jun 14, 2012
//     waynestewart@mac.com
// ----------------------------------------------------

If (Count parameters:C259=1)
	$Dict_ErrorDetails_t:=$1
	<>Dict_ErrorDetails_t:=$Dict_ErrorDetails_t
Else 
	$Dict_ErrorDetails_t:=<>Dict_ErrorDetails_t
	<>Dict_ErrorDetails_t:=""
End if 

$0:=$Dict_ErrorDetails_t