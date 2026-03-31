//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutBoolean ($handle_i : Integer; $tag_t : Text; \
//   $value_b : Boolean)

// Stores a Boolean value at the specified tag path.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path
//   $value_b  : Boolean : Value to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $value_b : Boolean)

var $parent_o : Object
var $leafKey_t : Text

OTr__Lock

If (OTr__IsValidHandle($handle_i))
	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; True; \
		->$parent_o; ->$leafKey_t))
		OB SET($parent_o; $leafKey_t; $value_b)
	End if
Else
	OTr__Error("Invalid handle"; Current method name)
End if

OTr__Unlock
