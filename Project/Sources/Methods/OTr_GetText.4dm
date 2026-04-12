//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetText (inObject; inTag) --> Text

// Retrieves a Text value from the specified tag path.

// **ORIGINAL DOCUMENTATION**

// *OT GetText* gets a value in *inObject* from the item referenced by
// *inTag*.

// If the object is not a valid object handle, an error is generated, *OK*
// is set to zero, and an empty string is returned.

// If no item in the object has the given tag, an empty string is
// returned. If the *FailOnNoItem* option is set, an error is generated
// and *OK* is set to zero.

// If an item with the given tag exists and has the type *OT Is
// Character* (112), the value of the requested element is returned.

// If an item with the given tag exists and has any other type, *OK* is
// set to zero, and an empty string is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_t : Text : Stored value, or empty text on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_t : Text

OTr_zAddToCallStack(Current method name)

$result_t:=OTr_GetString($inObject_i; $inTag_t)

OTr_zRemoveFromCallStack(Current method name)
