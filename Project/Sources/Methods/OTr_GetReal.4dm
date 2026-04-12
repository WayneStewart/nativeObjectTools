//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetReal (inObject; inTag) --> Real

// Retrieves a Real value from the specified tag path.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_r : Real : Stored value, or 0 on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is real type argument
//     to prevent crash when stored value is a non-Real type.
// Wayne Stewart, 2026-04-12 - Added OTr_zMapType type guard (shadow-key-first).
//   4D stores both Longint and Real as Is real at the JSON level; without this
//   guard, OTr_GetReal would silently succeed on a Longint property. Guard returns
//   an error, sets OK=0, and returns 0 when the shadow key is not Is real:K8:4.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_r : Real

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

$result_r:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			If (OTr_zMapType($parent_o; $leafKey_t)=Is real:K8:4)
				$result_r:=OB Get:C1224($parent_o; $leafKey_t; Is real:K8:4)
			Else
				OTr_zError("Type mismatch"; Current method name)
				OTr_zSetOK(0)
			End if
		End if
	End if
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
