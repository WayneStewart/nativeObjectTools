//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_zSetOK (OK)-> integer

// As a local method this simply returns the state of the OK variable,
// When running as a component in a host database, it calls its "twin"
//    in the host and sets the corresponding OK variable in the
//    the host.

// Access: Private

// Parameters: 
//   $newOK : Integer : Overide the state of the OK variable


// Returns:
//   $OK : Integer : The state for the OK variable

// Created by Wayne Stewart (2026-04-02)
// ----------------------------------------------------

#DECLARE($newOK : Integer)->$OK : Integer

If (Count parameters:C259=1)
	OK:=$newOK
End if 

// Alert HOST database


//  Still to be written


$OK:=OK

