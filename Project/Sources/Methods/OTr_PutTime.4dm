//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutTime (inObject; inTag; inValue)

// Stores a Time value at the specified tag path.

// **ORIGINAL DOCUMENTATION**

// *OT PutTime* puts *inValue* into *inObject*.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to
// zero. If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type Is Time, its value is replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_h  : Time    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Added type-consistency guard: refuses to overwrite an
//   existing item whose stored type differs from Time (OK=0, value unchanged).
// Wayne Stewart, 2026-04-11 - Added If/Else native/text storage guard.
//   OTr_uNativeDateInObject() probes the current process's "Dates inside objects"
//   setting at call time (per-process, per-call — see that method for rationale).
//   True  → OB SET with native Time value (no shadow key needed; OB Get type → Is time).
//   False → store as "HH:MM:SS" text via OTr_uTimeToText, plus a shadow key
//           (leafKey$type := 11) so OTr_zMapType can identify the stored text as
//           Is time (11) rather than OT Character (112).
// Wayne Stewart, 2026-04-12 - Type guard updated to use OTr_zMapType (shadow-key-first)
//   instead of OB Get type, ensuring correct rejection of a text-stored Time (shadow key
//   Is time = 11) that would otherwise pass an Is text check. Native path now also writes
//   the shadow key (leafKey$type := Is time = 11) so that OTr_zMapType is version-independent
//   and so that OTr_GetTime can branch on the shadow key rather than OB Get type alone.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_h : Time)

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
			If ($existingType_i#0) & ($existingType_i#Is time:K8:8)
				OTr_zError("Type mismatch"; Current method name)
			Else
				If (OTr_uNativeDateInObject)
					OB SET($parent_o; $leafKey_t; $inValue_h)
					OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is time:K8:8)
				Else
					OB SET($parent_o; $leafKey_t; OTr_uTimeToText($inValue_h))
					// Shadow key lets OTr_zMapType distinguish a text-stored time
					// (OT type 11) from an ordinary text string (OT type 112).
					OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is time:K8:8)
				End if
			End if
		Else
			If (OTr_uNativeDateInObject)
				OB SET($parent_o; $leafKey_t; $inValue_h)
				OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is time:K8:8)
			Else
				OB SET($parent_o; $leafKey_t; OTr_uTimeToText($inValue_h))
				// Shadow key lets OTr_zMapType distinguish a text-stored time
				// (Is time = 11) from an ordinary text string (OT Character = 112).
				OB SET($parent_o; OTr_zShadowKey($leafKey_t); Is time:K8:8)
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
