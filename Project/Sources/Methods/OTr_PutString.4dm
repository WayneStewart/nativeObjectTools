//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutString (inObject; inTag; inValue)

// Stores a String/Text inValue at the specified inTag path.

// **ORIGINAL DOCUMENTATION**
// 
// *OT PutString* puts *inValue* into *inObject*.
// 
// If *inObject* is not a valid object handle, an error is generated and OK is set to zero.
// 
// If no item in the object has the given inTag, a new item is created.
// 
// If an item with the given inTag exists and has the the matching type, its value is replaced.
// 
// If an item with the given inTag exists and has any other type, 
//    an error is generated and OK is set to zero if the _OT VariantItems_ option is not set,
//    otherwise the existing item is deleted and a new item is created.
// 
// See “The Character Item Type” on page 13 for more information on storing and retrieving strings.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path
//   $inValue_t  : Text    : Value to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_t : Text)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; \
		->$parent_o; ->$leafKey_t))
		OB SET:C1220($parent_o; $leafKey_t; $inValue_t)
	End if 
Else 
	OTr_zError("Invalid inObject"; Current method name:C684)
End if 

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
