//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetTime (inObject; inTag) --> Time

// Retrieves a Time value from the specified tag path.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_h : Time : Stored value, or 00:00:00 on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Added If/Else native/text retrieval guard.
//   The stored type is inspected directly: if the property is Is text,
//   it is parsed via OTr_uTextToTime ("HH:MM:SS"); if it is Is time,
//   it is retrieved natively. Handles both storage paths and any legacy
//   text-stored times correctly.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_h : Time

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $storedType_i : Integer
var $rawText_t : Text

$result_h:=?00:00:00?

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$storedType_i:=OB Get type($parent_o; $leafKey_t)
			If ($storedType_i=Is text)
				// Text path: stored as "HH:MM:SS"
				$rawText_t:=OB Get($parent_o; $leafKey_t; Is text)
				$result_h:=OTr_uTextToTime($rawText_t)
			Else
				// Native path: stored as native Time
				$result_h:=OB Get($parent_o; $leafKey_t; Is time)
			End if
		End if
	End if
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
