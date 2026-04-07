//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetLong (inObject; inTag) --> Longint

// Retrieves an Integer value from the specified tag path.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_i : Integer : Stored value, or 0 on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_i : Integer

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

$result_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$result_i:=OB Get($parent_o; $leafKey_t)
		End if
	End if
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
