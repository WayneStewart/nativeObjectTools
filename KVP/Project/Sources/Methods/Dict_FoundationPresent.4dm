//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// User name (OS): Wayne Stewart
// Date and time: Feb 17, 2012, 20:51:26
// ----------------------------------------------------
// Method: Dict_FoundationPresent
If (False:C215)
	Dict_FoundationPresent
End if 

// Description
// 
//
// Parameters
C_BOOLEAN:C305(<>Dict_FoundationPresent_b; $0)  //  Returns true if Foundation is installed

// ----------------------------------------------------

//  Do this once only
If (<>Dict_FoundationPresent_b)  //  it will never become untrue once set to true
Else 
	ARRAY TEXT:C222($InstalledComponents_at; 0)
	COMPONENT LIST:C1001($InstalledComponents_at)
	<>Dict_FoundationPresent_b:=(Find in array:C230($InstalledComponents_at; "Foundation@")>0)
End if 

$0:=<>Dict_FoundationPresent_b