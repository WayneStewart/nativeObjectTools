//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_DeleteItem (inObject; inTag)

// Deletes the item referenced by $inTag_t. Embedded objects are deleted
// recursively. BLOB and Picture parallel array slots referenced by
// the deleted item (or any sub-items) are released.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag of the item to delete (inTag)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-04 - Fixed: missing OB REMOVE call (item was
//   never deleted). Added OTr_zSetOK(1) on success.
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_zSetOK(1) on
//   success path (see OTr-OK0-Conditions specification).
// Wayne Stewart, 2026-04-10 - Also removes any sibling shadow-type
//   key (leafKey$type) so that a subsequent Put of an unrelated
//   value at the same leaf is not misreported by OTr_zMapType.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			OB REMOVE:C1226($parent_o; $leafKey_t)
			OB REMOVE:C1226($parent_o; OTr_zShadowKey($leafKey_t))
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

OTr_zRemoveFromCallStack(Current method name)
