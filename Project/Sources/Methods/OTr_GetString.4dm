//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetString ($handle_i : Integer; $tag_t : Text) \
//   --> $value_t : Text

// Retrieves a String/Text value from the specified tag path.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path

// Returns:
//   $value_t : Text : Stored value, or empty text when missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$value_t : Text

var $parent_o : Object
var $leafKey_t : Text

$value_t:=""

OTr__Lock

If (OTr__IsValidHandle($handle_i))
	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$value_t:=OB Get($parent_o; $leafKey_t)
		End if
	End if
End if

OTr__Unlock
