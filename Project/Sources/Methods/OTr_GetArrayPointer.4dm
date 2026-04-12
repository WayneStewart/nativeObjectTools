//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayPointer (inObject; inTag; inIndex) --> Pointer

// Retrieves a single element from a Pointer array item.
// The stored text is deserialised via OTr_u_TextToPointer.
// Returns a Null pointer on any error or out-of-range index.
// Note: Pointer values are process-local. A pointer stored
// from one process may not resolve correctly in another.
// OK is unchanged on success; set to 0 on any failure.

// **ORIGINAL DOCUMENTATION**

// *OT GetArrayPointer* gets a value in *inObject* from the array item referenced by
// *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and a nil pointer is returned.

// If no item in the object has the given tag, a nil pointer is returned. If the
// *FailOnNoItem*

// option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Pointer array*, and *inIndex*
// is in the range (0.. *OT SizeOfArray* ( *inObject; inTag* )), the value of the
// requested element is returned.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated, *OK* is set to zero, and a nil pointer is returned.

// Warning: Under no circumstances should you attempt to store a pointer to a local or
// process variable in a compiled database and then try to retrieve that pointer in
// another process.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_ptr : Pointer : Element value, or Null on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_ptr : Pointer

OTr_z_AddToCallStack(Current method name:C684)

var $raw_v : Variant

$result_ptr:=Null:C1517
$raw_v:=OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Pointer array:K8:23)
If (Value type:C1509($raw_v)#Is undefined:K8:13)
	$result_ptr:=OTr_u_TextToPointer($raw_v)
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
