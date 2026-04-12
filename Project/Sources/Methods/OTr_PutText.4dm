//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutText (inObject; inTag; inValue)

// Stores a Text value at the specified tag path.

// **ORIGINAL DOCUMENTATION**

// *OT PutText* puts *inValue* into *inObject*.

// If *inObject* is not a valid object handle, an error is generated and
// *OK* is set to zero. If no item in the object has the given tag, a new
// item is created.

// If an item with the given tag exists and has the type *OT Is
// Character* (112), its value is replaced.

// If an item with the given tag exists and has any other type, an error
// is generated and *OK* is set to zero if the *OT VariantItems* option
// is not set, otherwise the existing item is deleted and a new item is
// created.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_t  : Text    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_t : Text)

OTr_z_AddToCallStack(Current method name:C684)

OTr_PutString($inObject_i; $inTag_t; $inValue_t)

OTr_z_RemoveFromCallStack(Current method name:C684)
