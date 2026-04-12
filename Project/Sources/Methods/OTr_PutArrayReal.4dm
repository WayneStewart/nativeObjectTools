//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayReal (inObject; inTag; inIndex; inValue)

// Sets a single element of a Real array item.
// OK is unchanged on success; set to 0 on any failure.

// **ORIGINAL DOCUMENTATION**

// OT PutArrayReal sets an element of an array in *inObject*.

// If the object is not a valid object handle or if no item in the object has the given
// tag, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Real array*, and *inIndex* is
// in the range (0.. *OT SizeOfArray* ( *inObject; inTag* )), the value of the requested
// element is set to *inValue*.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated and *OK* is set to zero.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_r  : Real    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_r : Real)

OTr_zAddToCallStack(Current method name:C684)

OTr_zLock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Real array:K8:17; $inValue_r)
OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name:C684)
