//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutPicture (inObject; inTag; inValue)

// Stores a Picture value at the specified tag path.
// Pictures are stored natively in the object via OB SET.

// **ORIGINAL DOCUMENTATION**

// OT PutPicture puts *inValue* into *inObject*.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to
// zero. If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type Is Picture, its value is
// replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

// Access: Shared

// Parameters:
//   $inObject_i  : Integer : OTr inObject
//   $inTag_t     : Text    : Tag path (inTag)
//   $inValue_pic : Picture : Picture to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Removed proxy string/release call;
//     Picture now stored natively via OB SET.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-12 - Write shadow-type key (leafKey$type := Is picture = 3)
//   after storing the Picture. OB Get type reports Is object (38) rather than
//   Is picture (3) for Picture properties in 4D v19-v20; the shadow key
//   allows OTr_z_MapType to return the correct type (Is picture = 3) despite this misreport.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_pic : Picture)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
		OB SET:C1220($parent_o; $leafKey_t; $inValue_pic)
		OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is picture:K8:10)
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
	OTr_z_SetOK(0)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
