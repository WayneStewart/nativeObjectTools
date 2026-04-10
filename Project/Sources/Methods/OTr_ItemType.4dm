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
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_zSetOK(1) on
//   success path. Per the canonical OTr contract (OTr-OK0-Conditions),
//   OK is pulled to zero on error only and is never guaranteed to be
//   one on success. The earlier addition was a misreading of the
//   specification; call sites must not rely on OK=1 as a positive
//   indicator.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$otType_i : Integer

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

$otType_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))

	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$otType_i:=OTr_zMapType($parent_o; $leafKey_t)
		Else
			OTr_zError("Item not found: "+$inTag_t; Current method name)
		End if
	Else
		OTr_zError("Invalid path: "+$inTag_t; Current method name)
	End if

Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
