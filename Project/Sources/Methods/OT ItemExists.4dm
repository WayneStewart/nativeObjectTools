//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT ItemExists (inObject; inTag) --> Longint

// Tests for the existence of an item. $inTag_t may refer to a top-level
// item, an embedded object, or an embedded item. Returns 1 if found,
// 0 if not. An invalid handle generates an error; a missing path does
// not (this is a query, not a mutation).

// **ORIGINAL DOCUMENTATION**

// *OT ItemExists* tests for the existence of the given item. *inTag* may refer to a top
// level item, an embedded object or an embedded item.

// If *inObject* is not a valid object handle, an error is generated, *OK* is set to
// zero, and zero is returned.

// If an item with the given tag exists, 1 is returned. Otherwise zero is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag of the item to query (inTag)

// Returns:
//   $exists_i : Integer : 1 if item exists, 0 if not

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$exists_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text

$exists_i:=0

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$exists_i:=1
		End if 
	End if 
	// Missing path: return 0 without error — this is a read-only query
	
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
