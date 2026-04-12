//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutBoolean (inObject; inTag; inValue)

// Stores a Boolean value at the specified tag path.

// **ORIGINAL DOCUMENTATION**

// *OT PutBoolean* puts *inValue* into *inObject*. The value zero is considered False,
// any non- zero value is considered True.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to
// zero. If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type Is Boolean, its value is
// replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_b  : Boolean : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Added type-consistency guard: refuses to overwrite an
//   existing item whose stored type differs from Boolean (OK=0, value unchanged).
// Wayne Stewart, 2026-04-12 - Type guard updated to use OTr_z_MapType (shadow-key-first)
//   instead of OB Get type. Write shadow-type key (leafKey$type := Is Boolean = 6)
//   so that OTr_ItemType and OTr_GetBoolean can reliably identify the stored type
//   even if OB Get type behaves unexpectedly across 4D versions.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_b : Boolean)

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
			If ($existingType_i#0) & ($existingType_i#Is boolean:K8:9)
				OTr_z_Error("Type mismatch"; Current method name:C684)
			Else 
				OB SET:C1220($parent_o; $leafKey_t; $inValue_b)
				OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is boolean:K8:9)
			End if 
		Else 
			OB SET:C1220($parent_o; $leafKey_t; $inValue_b)
			OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is boolean:K8:9)
		End if 
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
