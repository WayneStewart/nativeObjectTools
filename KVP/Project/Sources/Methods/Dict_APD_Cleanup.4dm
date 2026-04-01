//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_APD_Cleanup

// Global and IP variables accessed:
C_BOOLEAN:C305(<>Dict_APD_Cleanup_b)

If (False:C215)
	C_BOOLEAN:C305(Dict_APD_Cleanup; $1; $0)
End if 

// Method Type:    Protected

// Parameters:
C_BOOLEAN:C305($1)

// Local Variables:
C_LONGINT:C283($Process_i)

// Returns:
C_BOOLEAN:C305($0)

// Created by Wayne Stewart Aug 9, 2012
//     waynestewart@mac.com
// ----------------------------------------------------

If (Count parameters:C259=1)
	<>Dict_APD_Cleanup_b:=$1
End if 

If (<>Dict_APD_Cleanup_b)
	Dict_APD_CleanupProcess  //  This will launch the process
Else 
	$Process_i:=Process number:C372("$Dict_APD_CleanupProcess")
	If ($Process_i>0)
		RESUME PROCESS:C320($Process_i)
	End if 
End if 

$0:=<>Dict_APD_Cleanup_b



