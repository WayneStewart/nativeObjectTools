//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutObject ($handle_i : Integer; $tag_t : Text; \
//   $sourceHandle_i : Integer)

// Stores a deep copy of another handle's object at the given tag path.

// Access: Shared

// Parameters:
//   $handle_i       : Integer : Destination OTr handle
//   $tag_t          : Text    : Destination tag path
//   $sourceHandle_i : Integer : Source OTr handle

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $sourceHandle_i : Integer)

var $parent_o : Object
var $leafKey_t : Text
var $copy_o : Object

OTr__Lock

If (OTr__IsValidHandle($handle_i) & OTr__IsValidHandle($sourceHandle_i))
	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; True; \
		->$parent_o; ->$leafKey_t))
		$copy_o:=OB Copy(<>OTR_Objects_ao{$sourceHandle_i})
		OB SET($parent_o; $leafKey_t; $copy_o)
	End if
Else
	OTr__Error("Invalid handle"; Current method name)
End if

OTr__Unlock
