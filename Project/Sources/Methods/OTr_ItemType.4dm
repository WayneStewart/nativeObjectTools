//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ItemType (inObject; inTag {; Actual}) --> Longint

// Returns the OTr-normalised type constant for the item referenced by $inTag_t.

// When the optional $Actual_b parameter is True, returns the raw shadow key value
// instead, bypassing normalisation. Use True for diagnostics and debugging only.

// **ORIGINAL DOCUMENTATION**

// *OT ItemType* returns the type of the item referenced by *inTag*.

// If *inObject* is not a valid object handle or if no item in the object has the given
// tag, an error is generated, *OK* is set to zero, and zero is returned.

// If an item with the given tag exists, its type is returned.

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

var $parent_o : Object
var $leafKey_t : Text
var $actualMode_b : Boolean

If (Count parameters:C259<3)
	$actualMode_b:=False:C215
Else
	$actualMode_b:=$useActual_b
End if

$otType_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))

	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))

			If ($actualMode_b)
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
