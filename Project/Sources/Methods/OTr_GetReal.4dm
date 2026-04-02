//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetReal ($handle_i : Integer; $tag_t : Text) \
//   --> $value_r : Real

// Retrieves a Real value from the specified tag path.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path

// Returns:
//   $value_r : Real : Stored value, or 0 on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$value_r : Real

var $parent_o : Object
var $leafKey_t : Text

$value_r:=0

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$value_r:=OB Get($parent_o; $leafKey_t)
		End if
	End if
End if

OTr_zUnlock
