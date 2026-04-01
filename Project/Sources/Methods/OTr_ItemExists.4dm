//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ItemExists ($handle_i : Integer; \
//   $tag_t : Text) --> $exists_i : Integer

// Tests for the existence of an item. $tag_t may refer to a top-level
// item, an embedded object, or an embedded item. Returns 1 if found,
// 0 if not. An invalid handle generates an error; a missing path does
// not (this is a query, not a mutation).

// Access: Shared

// Parameters:
//   $handle_i : Integer : A handle to an object
//   $tag_t    : Text    : Tag of the item to query

// Returns:
//   $exists_i : Integer : 1 if item exists, 0 if not

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$exists_i : Integer

var $parent_o : Object
var $leafKey_t : Text

$exists_i:=0

OTr__Lock

If (OTr__IsValidHandle($handle_i))

	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$exists_i:=1
		End if
	End if
	// Missing path: return 0 without error — this is a read-only query

Else
	OTr__Error("Invalid handle"; Current method name)
End if

OTr__Unlock
