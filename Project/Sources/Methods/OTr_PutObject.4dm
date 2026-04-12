//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutObject (inObject; inTag; inObject)

// Stores a deep copy of another handle's object at the given tag path.

// **ORIGINAL DOCUMENTATION**

// OT PutObject puts * *inObject into inObject* *.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to
// zero. If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type *OT Is Object (114)*, its value
// is replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

// Note: An object put into another object still remains in memory. It is still your
// responsibility to clear it when you no longer need it by calling *OT Clear*. Do not do
// the following: *OT* PutObject ($object;"bad thing!"; *OT* New)

// The handle which is created by *OT New* and passed to OT *PutObject* is forever
// lost and is an instant leak. See Also

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
