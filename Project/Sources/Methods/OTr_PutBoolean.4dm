//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutBoolean (inObject; inTag; inValue)

// Stores a Boolean value at the specified tag path.

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
// Wayne Stewart, 2026-04-12 - Type guard updated to use OTr_zMapType (shadow-key-first)
//   instead of OB Get type. Write shadow-type key (leafKey$type := Is Boolean = 6)
//   so that OTr_ItemType and OTr_GetBoolean can reliably identify the stored type
//   even if OB Get type behaves unexpectedly across 4D versions.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_b : Boolean)

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
			If ($existingType_i#0) & ($existingType_i#Is Boolean:K8:9)
				OTr_zError("Type mismatch"; Current method name)
			Else
				OB SET($parent_o; $leafKey_t; $inValue_b)
				OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is Boolean:K8:9)
			End if
		Else
			OB SET($parent_o; $leafKey_t; $inValue_b)
			OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is Boolean:K8:9)
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
