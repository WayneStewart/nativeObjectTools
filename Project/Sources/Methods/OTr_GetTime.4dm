//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetTime ($handle_i : Integer; $tag_t : Text) \
//   --> $value_h : Time

// Retrieves a Time value from the specified tag path.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path

// Returns:
//   $value_h : Time : Stored value, or 00:00:00 when missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$value_h : Time

var $parent_o : Object
var $leafKey_t : Text

$value_h:=?00:00:00?

OTr__Lock

If (OTr__IsValidHandle($handle_i))
	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$value_h:=OB Get($parent_o; $leafKey_t)
		End if
	End if
End if

OTr__Unlock
