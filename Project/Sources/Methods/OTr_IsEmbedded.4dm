//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_IsEmbedded (inObject; inTag) --> Longint

// Tests whether the item referenced by $inTag_t is an embedded object.
// Returns 1 if the item exists and has OT Object type, 0 otherwise.

// **ORIGINAL DOCUMENTATION**

// *OT IsEmbedded* tests the item referenced by *inTag* to see if it is an embedded
// object.

// If *inObject* is not a valid object handle or if no item in object has the given tag,
// an error is generated, *OK* is set to zero, and zero is returned.

// If an item with the given tag exists and has the type *OT Is Object*, 1 is returned.
// If an item with the given tag exists and has any other type, zero is returned.



// Access: Shared

// Parameters:
//   $inObject_i    : Integer : OTr inObject
//   $inTag_t       : Text    : Tag of the item to query (inTag)

// Returns:
//   $isEmbedded_i : Integer : 1 if item is an embedded object, 0 if not

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$isEmbedded_i : Integer

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

$isEmbedded_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))

	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			If (OB Get type($parent_o; $leafKey_t)=Is object)
				$isEmbedded_i:=1
			End if
		Else
			OTr_zError("Item not found: "+$inTag_t; Current method name)
		End if
	Else
		OTr_zError("Invalid path: "+$inTag_t; Current method name)
	End if

Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
