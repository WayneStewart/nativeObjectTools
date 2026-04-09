//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT PutPicture (inObject; inTag; inValue)

// Stores a Picture value at the specified tag path.
// Pictures are stored natively in the object via OB SET.

// **ORIGINAL DOCUMENTATION**
// 
// *OT PutPicture* puts *inValue* into *inObject*.
// 
// If *inObject* is not a valid object handle, an error
// is generated and OK is set to zero.
// 
// If no item in the object has the given inTag, a new
// item is created.
// 
// If an item with the given inTag exists and has the
// type *Is Picture*, its value is replaced.
// 
// If an item with the given inTag exists and has any
// other type, an error is generated and OK is set to
// zero if the _OT VariantItems_ option is not set,
// otherwise the existing item is deleted and a new
// item is created.

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
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_pic : Picture)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True; ->$parent_o; ->$leafKey_t))
		OB SET($parent_o; $leafKey_t; $inValue_pic)
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
	OTr_zSetOK(0)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
