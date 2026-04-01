//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_IsEmbedded ($handle_i : Integer; \
//   $tag_t : Text) --> $isEmbedded_i : Integer

// Tests whether the item referenced by $tag_t is an embedded object.
// Returns 1 if the item exists and has OT Object type, 0 otherwise.

// Access: Shared

// Parameters:
//   $handle_i    : Integer : A handle to an object
//   $tag_t       : Text    : Tag of the item to query

// Returns:
//   $isEmbedded_i : Integer : 1 if item is an embedded object, 0 if not

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$isEmbedded_i : Integer

var $parent_o : Object
var $leafKey_t : Text

$isEmbedded_i:=0

OTr__Lock

If (OTr__IsValidHandle($handle_i))

	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			If (OB Get type($parent_o; $leafKey_t)=Is object)
				$isEmbedded_i:=1
			End if
		Else
			OTr__Error("Item not found: "+$tag_t; Current method name)
		End if
	Else
		OTr__Error("Invalid path: "+$tag_t; Current method name)
	End if

Else
	OTr__Error("Invalid handle"; Current method name)
End if

OTr__Unlock
