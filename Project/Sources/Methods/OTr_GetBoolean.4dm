//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetBoolean ($handle_i : Integer; $tag_t : Text) \
//   --> $value_i : Integer

// Retrieves a Boolean value from the specified tag path as 1/0 for
// legacy ObjectTools compatibility.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path

// Returns:
//   $value_i : Integer : 1 when True, otherwise 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$value_i : Integer

var $parent_o : Object
var $leafKey_t : Text
var $value_b : Boolean

$value_i:=0

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$value_b:=OB Get($parent_o; $leafKey_t)
			If ($value_b)
				$value_i:=1
			End if
		End if
	End if
End if

OTr_zUnlock
