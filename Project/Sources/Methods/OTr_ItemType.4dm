//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ItemType ($handle_i : Integer; \
//   $tag_t : Text) --> $otType_i : Integer

// Returns the OT type constant for the item referenced by $tag_t.
// Type resolution: native 4D types map directly; Text properties are
// examined for blob:/pic:/ptr:/rec:/var: prefixes, then date/time
// patterns, before falling back to OT Character (112).

// Access: Shared

// Parameters:
//   $handle_i : Integer : A handle to an object
//   $tag_t    : Text    : Tag of the item to query

// Returns:
//   $otType_i : Integer : OT type constant, or 0 on error

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$otType_i : Integer

var $parent_o : Object
var $leafKey_t : Text

$otType_i:=0

OTr__Lock

If (OTr__IsValidHandle($handle_i))

	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$otType_i:=OTr__MapType($parent_o; $leafKey_t)
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
