//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetArrayPicture (inObject; inTag; inIndex) --> Picture

// Retrieves a single element from a Picture array item.
// Returns an empty Picture on any error or out-of-range index.

// **WARNING: Changed Behaviour**

// The legacy OT GetArrayPicture command returned the Picture through
// an output parameter. OT GetArrayPicture returns the requested array
// element as the function result.

// **ORIGINAL DOCUMENTATION**

// *OT GetArrayPicture* gets a value in *inObject* from the array item referenced by
// *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and an empty picture is returned.

// If no item in the object has the given tag, an empty picture is returned. If the
// *FailOnNoItem* option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Picture array*, and *inIndex*
// is in the range (0..*OT SizeOfArray*(*inObject*; *inTag*)), the value of the requested
// element is returned.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated, *OK* is set to zero, and an empty picture is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_pic : Picture : Element value, or empty Picture on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_pic : Picture

OTr_z_AddToCallStack(Current method name:C684)

$result_pic:=OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Picture array:K8:22)

OTr_z_RemoveFromCallStack(Current method name:C684)
