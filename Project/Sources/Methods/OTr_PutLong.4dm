//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutLong (inObject; inTag; inValue)

// Stores an Integer value at the specified tag path.

// **ORIGINAL DOCUMENTATION**

// OT PutLong puts inValue into inObject.

// If inObject is not a valid object handle, an error is generated and OK is set to zero.
// If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type Is Longint, its value is replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// OK is set to zero if the OT VariantItems option is not set, otherwise the existing item
// is deleted and a new item is created.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_i  : Integer : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Added type-consistency guard.
// Wayne Stewart, 2026-04-12 - Write shadow-type key (leafKey$type := Is longint = 5).
//   4D objects store all numeric scalars as Is real regardless of whether the value
//   was a Long or a Real; OB Get type cannot distinguish them. The shadow key is the
//   only reliable mechanism for OTr_ItemType and OTr_GetLong to know the stored type.
//   Type guard updated to use OTr_zMapType (shadow-key-first) instead of OB Get type,
//   so that a Real stored at the same tag (shadow key = Is real = 1) is correctly rejected.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_i : Integer)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $existingType_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$existingType_i:=OTr_zMapType($parent_o; $leafKey_t)
			If ($existingType_i#0) & ($existingType_i#Is longint:K8:6)
				OTr_zError("Type mismatch"; Current method name)
			Else
				OB SET($parent_o; $leafKey_t; $inValue_i)
				OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is longint:K8:6)
			End if
		Else
			OB SET($parent_o; $leafKey_t; $inValue_i)
			OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is longint:K8:6)
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
