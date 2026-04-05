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
// Wayne Stewart, 2026-04-05 - Implemented host-database OK propagation.
// ----------------------------------------------------

#DECLARE($newOK : Integer)->$OK : Integer

OTr_zInit  // Make certain everything is initalised

If (Count parameters:C259=1)
	OK:=$newOK
	
	If (Storage:C1525.OTr.structureName="nativeObjectTools")
	Else 
		EXECUTE METHOD:C1007("OT Host CheckVariable"; *; "OK"; String:C10($newOK))
	End if 
	
End if 

$OK:=OK

