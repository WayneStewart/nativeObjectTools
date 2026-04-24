//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT PutArrayBLOB (inObject; inTag; inIndex; inValue)

// Sets a single element of a Blob array item at the given index.

// **ORIGINAL DOCUMENTATION**

// OT PutArrayBLOB sets an element of an array in *inObject*.

// If the object is not a valid object handle, if no item in the object has the given
// tag, or if the 4D version is not v14 or later, an error is generated and *OK* is set
// to zero.

// If an item with the given tag exists and has the type *Blob array*, and *inIndex* is
// in the range (0.. *OT SizeOfArray* ( *inObject; inTag* )), the value of the requested
// element is set to *inValue*.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated and *OK* is set to zero.

// Access: Shared

// Parameters:
//   $inObject_i   : Integer : OTr inObject
//   $inTag_t      : Text    : Tag path to the array item (inTag)
//   $inIndex_i    : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_blob : Blob    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_blob : Blob)

OTr_z_AddToCallStack(Current method name:C684)

var $encoded_t : Text

$encoded_t:=OTr_u_BlobToText($inValue_blob)
OTr_z_Lock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Blob array:K8:30; $encoded_t)
OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
