//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ItemType (inObject; inTag {; Actual}) --> Longint

// Returns the type constant for the item referenced by $inTag_t.

// **Default behaviour (Actual omitted or False):**
//   Returns the OTr-normalised type constant via OTr_zMapType (shadow-key-first,
//   with OT-compatible fallback). This is the correct mode for code that compares
//   the result against the four OT-named constants (OT Is Character, OT Character array,
//   OT Is Object, OT Is Record) or against 4D native type constants used as shadow
//   values (Is real:K8:4, Is longint:K8:6, Is Boolean:K8:9, Is date:K8:7,
//   Is time:K8:8, Is picture:K8:10, Is BLOB:K8:12, Is pointer:K8:14).

// **Actual mode (Actual = True):**
//   Returns the raw value stored in the shadow key (leafKey$type) for this item.
//   If no shadow key is present, returns OB Get type directly.
//   Use this to confirm what OTr's Put methods actually wrote — for diagnostics,
//   debugging, and cases where you need to distinguish the stored representation
//   from the OTr-normalised type. Returns the same value as the default in the
//   vast majority of cases; differs only when OTr_zMapType would have applied
//   a normalisation step (e.g. collapsing Is integer to Is longint in the
//   fallback path, or returning a default when no shadow key is present).

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject 
//   $inTag_t    : Text    : Tag of the item to query (inTag) 
//   $Actual_b  :  Boolean :  True = return raw shadow key value (optional)

// Returns:
//   $otType_i : Integer : Type constant (see above), or 0 on error

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Removed OTr_zSetOK(1) on success path.
//   The legacy ObjectTools plugin has no documented instances of setting
//   OK to 1; OTr matches that behaviour. OK is pulled to zero on error
//   (invalid handle, missing tag) and is not modified on success.
//   OT ItemType reference (p. 95): if inObject is not valid or if no item
//   has the given tag, an error is generated, OK is set to zero, and zero
//   is returned. This implementation is therefore correct.
// Wayne Stewart, 2026-04-12 - Added optional Actual parameter.
//   When True, returns the raw shadow key value (leafKey$type) written by
//   the Put method rather than the OTr_zMapType-normalised result.
//   Falls back to OB Get type if no shadow key is present.
//   Useful for diagnostics and distinguishing stored representation from
//   the OT-compatible normalised type.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $useActual_b : Boolean)->$otType_i : Integer

OTr_zAddToCallStack(Current method name:C684)

If (Count parameters:C259<3)
	$useActual_b:=False:C215
End if 

var $parent_o : Object
var $leafKey_t : Text

$otType_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			
			If ($useActual_b)
				// Actual mode: return the raw shadow key value, or OB Get type if absent.
				If (OB Is defined:C1231($parent_o; OTr_zShadowKey($leafKey_t)))
					$otType_i:=OB Get:C1224($parent_o; OTr_zShadowKey($leafKey_t); Is longint:K8:6)
				Else 
					$otType_i:=OB Get type:C1230($parent_o; $leafKey_t)
				End if 
			Else 
				// Default mode: OTr-normalised type via OTr_zMapType.
				$otType_i:=OTr_zMapType($parent_o; $leafKey_t)
			End if 
			
		Else 
			OTr_zError("Item not found: "+$inTag_t; Current method name:C684)
		End if 
	Else 
		OTr_zError("Invalid path: "+$inTag_t; Current method name:C684)
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name:C684)
