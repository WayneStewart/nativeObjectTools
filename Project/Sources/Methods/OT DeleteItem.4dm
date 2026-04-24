//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT DeleteItem (inObject; inTag)

// Deletes the item referenced by $inTag_t. Embedded objects are deleted
// recursively. BLOB and Picture parallel array slots referenced by
// the deleted item (or any sub-items) are released.

// **ORIGINAL DOCUMENTATION**

// *OT DeleteItem* deletes an item from an object. *inTag* may refer to embedded items
// and objects.

// If *inObject* is not a valid object handle or *inTag* refers to an item that does not
// exist, an error is generated, *OK* is set to zero, and no delete is performed.

// Note: Deleting an embedded object recursively deletes all of its items.

// Import/Export Routines

// The following routines provide the ability to import and export objects to 4D *BLOB*
// variables. This allows you to easily save and restore objects either to the database
// or to files on disk.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag of the item to delete (inTag)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-04 - Fixed: missing OB REMOVE call (item was
//   never deleted). Added OTr_z_SetOK(1) on success.
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_z_SetOK(1) on
//   success path (see OTr-OK0-Conditions specification).
// Wayne Stewart, 2026-04-10 - Also removes any sibling shadow-type
//   key (leafKey$type) so that a subsequent Put of an unrelated
//   value at the same leaf is not misreported by OTr_z_MapType.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			OB REMOVE:C1226($parent_o; $leafKey_t)
			OB REMOVE:C1226($parent_o; OTr_z_ShadowKey($leafKey_t))
		Else 
			OTr_z_Error("Item not found: "+$inTag_t; Current method name:C684)
		End if 
		
	Else 
		OTr_z_Error("Invalid path: "+$inTag_t; Current method name:C684)
	End if 
	
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
