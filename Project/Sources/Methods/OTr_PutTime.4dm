//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutTime (inObject; inTag; inValue)

// Stores a Time value at the specified tag path.

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
//           OT Time (type 11) rather than OT Character (112).
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_h : Time)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t) \
			& (OB Get type($parent_o; $leafKey_t)#Is time:K8:8) \
			& (OB Get type($parent_o; $leafKey_t)#Is text:K8:3))
			OTr_zError("Type mismatch"; Current method name)
		Else
			If (OTr_uNativeDateInObject)
				OB SET($parent_o; $leafKey_t; $inValue_h)
				// No shadow key: OB Get type returns Is time, unambiguous.
			Else
				OB SET($parent_o; $leafKey_t; OTr_uTimeToText($inValue_h))
				// Shadow key lets OTr_zMapType distinguish a text-stored time
				// (OT type 11) from an ordinary text string (OT type 112).
				OB SET($parent_o; OTr_zShadowKey($leafKey_t); 11)
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
