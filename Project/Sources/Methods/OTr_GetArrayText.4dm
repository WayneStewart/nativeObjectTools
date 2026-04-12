//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayText (inObject; inTag; inIndex) --> Text

// Retrieves a single element from a Text or String array item.
// Alias for OTr_GetArrayString.

// **ORIGINAL DOCUMENTATION**

// OT GetArrayText gets a value in *inObject* from the array item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and an empty string is returned.

// If no item in the object has the given tag, an empty string is returned. If the
// *FailOnNoItem*

// option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *OT Character array*, and
// *inIndex* is in the range (0.. OT *SizeOfArray* ( *inObject; inTag* )), the value of
// the requested element is returned.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated, *OK* is set to zero, and an empty string is returned.

// See “The Character Item Type” on page 13 for more information on storing and
// retrieving text.

// Note: If your database is running in compatibility mode and the result of this method
// is assigned to a fixed width string variable, the item’s contents will be truncated to
// the width of the variable. To retrieve more than 255 characters from a character
// array, assign the result to a text variable or field.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_t : Text : Element value, or "" on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_t : Text

OTr_z_AddToCallStack(Current method name:C684)

$result_t:=OTr_GetArrayString($inObject_i; $inTag_t; $inIndex_i)

OTr_z_RemoveFromCallStack(Current method name:C684)
