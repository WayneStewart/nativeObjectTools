//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayTime (inObject; inTag; inIndex; inValue)

// Sets a single element of a Time array item at the given index.

// **ORIGINAL DOCUMENTATION**

// OT PutArrayTime sets an element of an array in *inObject*.

// If the object is not a valid object handle, if no item in the object has the given
// tag, or if the 4D version is not v14 or later, an error is generated and *OK* is set
// to zero.

// If an item with the given tag exists and has the type *Time array*, and *inIndex* is
// in the range (0.. *OT SizeOfArray* ( *inObject; inTag* )), the value of the requested
// element is set to *inValue*.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated and *OK* is set to zero.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_h  : Time    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-11 - Added If/Else native/text storage guard to
//   match OTr_PutTime strategy. See OTr_uNativeDateInObject for probe details.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_h : Time)

OTr_zAddToCallStack(Current method name:C684)

var $encoded_v : Variant

If (OTr_uNativeDateInObject)
	$encoded_v:=$inValue_h
Else
	$encoded_v:=OTr_uTimeToText($inValue_h)
End if

OTr_zLock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Time array:K8:29; $encoded_v)
OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name:C684)
