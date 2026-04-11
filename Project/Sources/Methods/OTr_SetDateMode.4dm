//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SetDateMode ({inMode}) --> Text

// Gets or sets the current process's Date/Time storage mode for OTr objects.

// Access: Shared

// Parameters (all optional):
//   $inMode_t : Text : Desired mode token (case-insensitive):
//                        "native"  — store Date/Time as native 4D types (default since v17)
//                        "iso"     — store as ISO text without timezone ("YYYY-MM-DD")
//                        "iso-tz"  — store as ISO text with timezone suffix
//                      Omit to use as getter only (no SET DATABASE PARAMETER call).

// Returns:
//   $outMode_t : Text : Current mode token after any change:
//                         "native", "iso", or "iso-tz"

// Background:
//   This method wraps SET DATABASE PARAMETER (Dates inside objects; ...) and provides
//   a readable, OTr-consistent API for controlling how Date and Time values are stored
//   in 4D Object properties. The setting is per-process: calling this method affects
//   only the current process. All other OTr Date/Time put methods (OTr_PutDate,
//   OTr_PutTime, OTr_PutArrayDate, OTr_PutArrayTime, OTr_PutRecord) detect the
//   current mode via OTr_uNativeDateInObject at the time of each call.
//
//   The three modes correspond to the three 4D constant values for Dates inside objects:
//     "native"  → Date type (2)              — native 4D Date/Time in object
//     "iso"     → String type without time zone (0) — "YYYY-MM-DD" text
//     "iso-tz"  → String type with time zone (1)   — ISO with timezone offset
//
//   Typical use: call OTr_SetDateMode("iso") at process startup if the host database
//   uses the legacy ISO-string compatibility mode. Calling OTr_SetDateMode("native")
//   is safe but redundant in most databases (native is the default since 4D v17).
//
//   Reference: 4D KB 78256 — https://kb.4d.com/assetid=78256
//   See also: OTr_uNativeDateInObject, OTr-Phase-002-Spec.md §Date/Time Storage Strategy

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inMode_t : Text)->$outMode_t : Text

OTr_zAddToCallStack(Current method name:C684)

OTr_zInit

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
		SET DATABASE PARAMETER:C642(Dates inside objects:K5:61; Date type:K5:63)

	: ($mode_t="iso")
		SET DATABASE PARAMETER:C642(Dates inside objects:K5:61; String type without time zone:K5:62)

	: ($mode_t="iso-tz")
		SET DATABASE PARAMETER:C642(Dates inside objects:K5:61; String type with time zone:K5:64)

	: ($mode_t="")
		// Getter — no change

	Else
		// Unknown token — ignore silently; return current mode below
End case

// Return the current mode by probing (reflects whatever SET DATABASE PARAMETER
// the current process is now using, whether set by this method or by the caller)
If (OTr_uNativeDateInObject)
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

OTr_zRemoveFromCallStack(Current method name:C684)
