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
// Wayne Stewart, 2026-04-12 - Write shadow-type key (leafKey$type := 114 = OT Is Object)
//   so that OTr_zMapType can reliably identify the embedded sub-object as an OT Object
//   rather than descending into OTr_zArrayType. Without the shadow key, OTr_zMapType
//   would need to inspect the sub-object's content to decide whether it is an array
//   container or a user object. The shadow key short-circuits that heuristic.
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
		OB SET($parent_o; OTr_zShadowKey($leafKey_t); OT Is Object)
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
