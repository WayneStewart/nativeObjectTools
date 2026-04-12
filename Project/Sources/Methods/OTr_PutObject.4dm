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
//   so that OTr_z_MapType can reliably identify the embedded sub-object as an OT Object
//   rather than descending into OTr_z_ArrayType. Without the shadow key, OTr_z_MapType
//   would need to inspect the sub-object's content to decide whether it is an array
//   container or a user object. The shadow key short-circuits that heuristic.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inSourceObject_i : Integer)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $copy_o : Object

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i) & OTr_z_IsValidHandle($inSourceObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; \
		->$parent_o; ->$leafKey_t))
		$copy_o:=OB Copy:C1225(<>OTR_Objects_ao{$inSourceObject_i})
		OB SET:C1220($parent_o; $leafKey_t; $copy_o)
		OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); OT Is Object)
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
