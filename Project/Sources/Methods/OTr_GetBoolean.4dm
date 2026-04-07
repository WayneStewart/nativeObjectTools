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
			$value_b:=OB Get($parent_o; $leafKey_t)
			If ($value_b)
				$result_i:=1
			End if
		End if
	End if
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
