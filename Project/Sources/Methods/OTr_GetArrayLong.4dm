//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayLong (inObject; inTag; inIndex) --> Longint

// Retrieves a single Integer element from a LongInt or
// Integer array item at the specified 1-based index.
// Returns 0 if the handle is invalid, the tag does not
// exist, the item is not a LongInt/Integer array, or the
// index is out of range.
// OK is unchanged on success; set to 0 on any failure.

// **ORIGINAL DOCUMENTATION**

// OT GetArrayLong gets a value in *inObject* from the array item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and zero is returned.

// If no item in the object has the given tag, zero is returned. If the *FailOnNoItem*
// option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Longint array*, and *inIndex*
// is in the range (0.. *OT SizeOfArray* ( *inObject; inTag* )), the value of the
// requested element is returned.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated, *OK* is set to zero, and zero is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_i : Integer : Element value, or 0 on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

$result_i:=OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; LongInt array:K8:19)

OTr_z_RemoveFromCallStack(Current method name:C684)
