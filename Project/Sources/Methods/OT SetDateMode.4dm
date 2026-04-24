//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT SetDateMode ({inMode}) --> Text

// Gets or sets the current process's Date/Time storage mode for OTr objects.
// The setting is per-process. Omit the parameter to use as a getter only.

// The three mode tokens correspond to 4D's "Dates inside objects" parameter:
// - "native"  — store Date/Time as native 4D types (default since v17)
// - "iso"     — store as ISO text without timezone ("YYYY-MM-DD")
// - "iso-tz"  — store as ISO text with timezone suffix

// All OTr Date/Time put methods detect the current mode via OTr_u_NativeDateInObject
// at the time of each call. See also: OTr_u_NativeDateInObject.

// Reference: 4D KB 78256 — https://kb.4d.com/assetid=78256

// Access: Shared

// Parameters:
//   $inMode_t : Text : Mode token — "native", "iso", or "iso-tz" (optional)

// Returns:
//   $outMode_t : Text : Current mode token after any change

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inMode_t : Text)->$outMode_t : Text

OTr_z_AddToCallStack(Current method name:C684)

OTr_z_Init

var $mode_t : Text

// Normalise input
If (Count parameters:C259>=1)
	$mode_t:=Lowercase:C14($inMode_t)
Else 
	$mode_t:=""
End if 

// Apply if a valid token was supplied
Case of 
	: ($mode_t="native")
		SET DATABASE PARAMETER:C642(POP3 log file:K5:61; Activity network:K5:63)
		
	: ($mode_t="iso")
		SET DATABASE PARAMETER:C642(POP3 log file:K5:61; Activity language:K5:62)
		
	: ($mode_t="iso-tz")
		SET DATABASE PARAMETER:C642(POP3 log file:K5:61; Activity operations:K5:64)
		
	: ($mode_t="")
		// Getter — no change
		
	Else 
		// Unknown token — ignore silently; return current mode below
End case 

// Return the current mode by probing (reflects whatever SET DATABASE PARAMETER
// the current process is now using, whether set by this method or by the caller)
If (OTr_u_NativeDateInObject)
	$outMode_t:="native"
Else 
	// Distinguish iso-tz from iso by checking whether 4D would include a timezone.
	// Probe: write a known date and inspect the JSON representation.
	var $probe_o : Object
	var $json_t : Text
	$probe_o:=New object:C1471("d"; Current date:C33)
	$json_t:=JSON Stringify:C1217($probe_o)
	If (Position:C15("T00:00:00.000Z"; $json_t)>0) | (Position:C15("+"; $json_t)>0)
		$outMode_t:="iso-tz"
	Else 
		$outMode_t:="iso"
	End if 
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
