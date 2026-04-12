//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayBoolean (inObject; inTag; inIndex) --> Longint

// Retrieves a single element from a Boolean array item.
// Returns 1 (True) or 0 (False) for legacy ObjectTools compatibility.
// Returns 0 on any error or out-of-range index.
// OK is unchanged on success; set to 0 on any failure.

// **ORIGINAL DOCUMENTATION**

// *OT GetArrayBoolean* gets a value in *inObject* from the array item referenced by
// *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and zero is returned.

// If no item in the object has the given tag, zero is returned. If the *FailOnNoItem*
// option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Boolean array*, and *inIndex*
// is in the range (0.. *OT SizeOfArray* ( *inObject; inTag* )), the value of the
// requested element is returned as a number (0=false, 1=true).

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated, *OK* is set to zero, and zero is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_i : Integer : 1 when True, 0 when False or on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $raw_v : Variant

$raw_v:=OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Boolean array:K8:21)
If (Value type:C1509($raw_v)#Is undefined:K8:13)
	$result_i:=Choose:C955($raw_v; 1; 0)
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
