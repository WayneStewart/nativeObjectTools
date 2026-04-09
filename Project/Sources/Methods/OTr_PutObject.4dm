//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutObject (inObject; inTag; inObject)

// Stores a deep copy of another handle's object at the given tag path.

// Access: Shared

// Parameters:
//   $inObject_i       : Integer : OTr inObject (destination)
//   $inTag_t          : Text    : Tag path (inTag)
//   $inSourceObject_i : Integer : OTr inObject (source to embed — inObject)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inSourceObject_i : Integer)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $copy_o : Object

OTr_zLock

If (OTr_zIsValidHandle($inObject_i) & OTr_zIsValidHandle($inSourceObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True; \
		->$parent_o; ->$leafKey_t))
		$copy_o:=OB Copy(<>OTR_Objects_ao{$inSourceObject_i})
		OB SET($parent_o; $leafKey_t; $copy_o)
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
