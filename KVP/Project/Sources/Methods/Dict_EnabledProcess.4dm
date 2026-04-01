//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_EnabledProcess

// Global and IP variables accessed:

// Method Type:    Protected

// Parameters:
C_TEXT:C284($procName_t; $1)
C_BOOLEAN:C305($0)

// Local Variables:

// Created by Wayne Stewart (Aug 9, 2007)
//     waynestewart@mac.com
//  Returns true if this is a user process

// Modified by: Wayne Stewart (Mar 26, 2013)
//  Allowed web process to have apd


// ----------------------------------------------------

If (Count parameters:C259=1)
	$procName_t:=$1
Else 
	$procName_t:=""
End if 

$0:=False:C215

Case of   //  If this is the name of the process - there should be nothing running there
	: ($procName_t="$xx")
	: ($procName_t="Internal Bridge Process")
	: ($procName_t="Internal Timer Process")
	: ($procName_t="Fnd_Shell_Quitter")
	: ($procName_t="Fnd_Wnd_CloseAllWindows2")
		//: ($procName_t="/@")
	: ($procName_t="Design process")
		//: ($procName_t="Application process")
	: ($procName_t="$4D Compiler")
	: ($procName_t="Cache@")
	: ($procName_t="$Version@")
		//: ($procName_t="Web@")
	: ($procName_t="$Dict_DisplayUsage")
	: ($procName_t="$Dict_APD_CleanupProcess")
	: ($procName_t="SOAP@")
		
	Else 
		$0:=True:C214
		
End case 