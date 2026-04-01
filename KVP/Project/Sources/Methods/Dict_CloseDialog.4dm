//%attributes = {"invisible":true,"shared":true}

// ----------------------------------------------------
// Project Method: Dict_CloseDialog

// Global and IP variables accessed:
C_BOOLEAN:C305(<>Dict_CloseDialog_b)

If (False:C215)
	C_BOOLEAN:C305(Dict_CloseDialog; $1; $0)
End if 

// Method Type:    Protected

// Parameters:
C_BOOLEAN:C305($1)

// Local Variables:     None Used

// Returns:
C_BOOLEAN:C305($0)

// Created by Wayne Stewart Jul 24, 2012
//     waynestewart@mac.com
// ----------------------------------------------------

If (Count parameters:C259=1)
	<>Dict_CloseDialog_b:=$1
End if 

$0:=<>Dict_CloseDialog_b

