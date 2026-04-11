//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ItemType (inObject; inTag) --> Longint

// Returns the OT type constant for the item referenced by $inTag_t.
// Type resolution: native 4D types (including Picture and BLOB) map
// directly; text properties are examined for ISO-8601 date (YYYY-MM-DD)
// and HH:MM:SS time patterns before falling back to OT Character (112).
// See OTr_zMapType for the full discriminator.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag of the item to query (inTag)

// Returns:
//   $otType_i : Integer : OT type constant, or 0 on error

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
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$otType_i : Integer

OTr_zAddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text

$otType_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$otType_i:=OTr_zMapType($parent_o; $leafKey_t)
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
