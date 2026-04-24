//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT PutPointer (inObject; inTag; inValue)

// Stores a Pointer value at the specified tag path.
// The pointer is serialised to text via OTr_u_PointerToText
// and stored as the object property value.

// **VERY IMPORTANT NOTE**
// This command must *NOT* be used with pointers to local variables.

// **ORIGINAL DOCUMENTATION**

// OT PutPointer puts *inValue* into *inObject*.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to
// zero. If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type Is Pointer, its value is
// replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

// Warning: Under no circumstances should you attempt to store a pointer to a local or
// process variable in a compiled database and then try to retrieve that pointer in
// another process.

// Access: Shared

// Parameters:
//   $inObject_i  : Integer : OTr inObject
//   $inTag_t     : Text    : Tag path (inTag)
//   $inValue_ptr : Pointer : Pointer to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Writes a shadow-type key
//     (leafKey$type := Is pointer = 23) so OTr_z_MapType can distinguish a
//     serialised pointer from ordinary user text.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_ptr : Pointer)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
		OB SET:C1220($parent_o; $leafKey_t; OTr_u_PointerToText($inValue_ptr))
		OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is pointer:K8:14)
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
	OTr_z_SetOK(0)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
