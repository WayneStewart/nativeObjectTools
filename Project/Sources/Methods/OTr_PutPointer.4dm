//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutPointer (inObject; inTag; inValue)

// Stores a Pointer value at the specified tag path.
// The pointer is serialised to text via OTr_uPointerToText
// and stored as the object property value.

// **VERY IMPORTANT NOTE**
// This command must *NOT* be used with pointeers to local variables.

// **ORIGINAL DOCUMENTATION**
// 
// *OT PutPointer* puts *inValue* into *inObject*.
// 
// If *inObject* is not a valid object handle, an error
// is generated and OK is set to zero.
// 
// If no item in the object has the given inTag, a new
// item is created.
// 
// If an item with the given inTag exists and has the
// type *Is Pointer*, its value is replaced.
// 
// If an item with the given inTag exists and has any
// other type, an error is generated and OK is set to
// zero if the _OT VariantItems_ option is not set,
// otherwise the existing item is deleted and a new
// item is created.
// 
// Warning: Under no circumstances should you attempt to
// store a pointer to a local or process variable in a
// compiled database and then try to retrieve that pointer
// in another process. Variable addresses differ between
// processes in compiled mode.

// Access: Shared

// Parameters:
//   $inObject_i  : Integer : OTr inObject
//   $inTag_t     : Text    : Tag path (inTag)
//   $inValue_ptr : Pointer : Pointer to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_ptr : Pointer)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True; ->$parent_o; ->$leafKey_t))
		OB SET($parent_o; $leafKey_t; OTr_uPointerToText($inValue_ptr))
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
	OTr_zSetOK(0)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
