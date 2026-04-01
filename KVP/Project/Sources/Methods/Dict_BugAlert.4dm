//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_BugAlert (method{; details})
// The alert for displaying code bugs.

// Access Type: Private

// Parameters: 
//   $1 : Text : Method name (4D's 'Current method name' function doesn't work in components)
//   $2 : Text : Details about the problem (optional)

// Returns: Nothing

// Created by Dave Batton on Jul 15, 2003
// Modified by Dave Batton on Feb 16, 2004
//   Took out an unused Else statement on line 27.
// ----------------------------------------------------

// ### - Add localization support?

C_TEXT:C284($1; $2; $methodName_t; $description_t)

// Fnd_Gen_Init  ` Not needed here.

$methodName_t:=$1

If (Count parameters:C259>=2)
	$description_t:=$2
End if 

ALERT:C41("A problem has occurred in the "+$methodName_t+" method.\r\r"+$description_t+"\r\rPlease notify the database developer.")
TRACE:C157
