//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetString (inObject; inTag) --> Text

// Retrieves a String/Text value from the specified tag path.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_t : Text : Stored value, or empty text on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-04 - Added OTr_zSetOK(1) on success.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_t : Text

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

$result_t:=""

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$result_t:=OB Get($parent_o; $leafKey_t)
			OTr_zSetOK(1)
		End if
	End if
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
