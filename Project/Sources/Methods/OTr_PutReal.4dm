//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutReal (inObject; inTag; inValue)

// Stores a Real value at the specified tag path.

// **ORIGINAL DOCUMENTATION**

// OT PutReal puts *inValue* into *inObject*.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to
// zero. If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type Is Real, its value is replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_r  : Real    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Added type-consistency guard: refuses to overwrite an
//   existing item whose stored type differs from numeric/real (OK=0, value unchanged).
//   Note: 4D objects store all numeric scalars (Long, Integer, Real) as Is real at the
//   JSON level, so the guard cannot distinguish between Real and Long subtypes.
// Wayne Stewart, 2026-04-12 - Type guard updated to use OTr_z_MapType (shadow-key-first)
//   instead of OB Get type. A Longint stored at the same tag (shadow key = 5) is
//   correctly rejected. Write shadow-type key (leafKey$type := Is real = 1) so that
//   OTr_ItemType and OTr_GetReal can distinguish a Real from a Longint (shadow key = Is longint = 5)
//   when both are stored as Is real at the JSON level.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_r : Real)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $existingType_i : Integer

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$existingType_i:=OTr_z_MapType($parent_o; $leafKey_t)
			If ($existingType_i#0) & ($existingType_i#Is real:K8:4)
				OTr_z_Error("Type mismatch"; Current method name:C684)
			Else 
				OB SET:C1220($parent_o; $leafKey_t; $inValue_r)
				OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is real:K8:4)
			End if 
		Else 
			OB SET:C1220($parent_o; $leafKey_t; $inValue_r)
			OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is real:K8:4)
		End if 
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
