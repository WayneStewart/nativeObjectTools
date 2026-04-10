//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetBoolean (inObject; inTag) --> Longint

// Retrieves a Boolean value from the specified tag path as 1/0 for
// legacy ObjectTools compatibility.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_i : Integer : 1 when True, otherwise 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is boolean type argument
//     to prevent crash when stored value is a non-Boolean type.
// Wayne Stewart, 2026-04-11 - Added type pre-check: if stored type is not
//     Is boolean, generates an error, sets OK=0, and returns 0 (False).
//     Matches OT behaviour — coercion from other types is not performed.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_i : Integer

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $value_b : Boolean

$result_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			If (OB Get type($parent_o; $leafKey_t)=Is boolean:K8:9)
				$value_b:=OB Get:C1224($parent_o; $leafKey_t; Is boolean:K8:9)
				If ($value_b)
					$result_i:=1
				End if
			Else
				OTr_zError("Type mismatch"; Current method name)
			End if
		End if
	End if
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
