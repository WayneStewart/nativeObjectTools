//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayTime (inObject; inTag; inIndex) --> Time

// Retrieves a single element from a Time array item.
// Returns ?00:00:00? on any error or out-of-range index.
// OK is unchanged on success; set to 0 on any failure.

// Retrieval is transparent to storage path: the stored variant
// type is inspected directly.
//   Is text → parsed via OTr_uTextToTime ("HH:MM:SS")
//   Is time → retrieved as native Time
// This handles both the text-storage path (nativeDateInObject=False)
// and the native-storage path (nativeDateInObject=True), and correctly
// reads any legacy data stored as text before this guard was added.

// **ORIGINAL DOCUMENTATION**

// OT GetArrayTime gets a value in *inObject* from the array item referenced by *inTag*.

// the object is not a valid object handle or if the 4D version is not v14 or later, an
// error is generated, *OK* is set to zero, and the time ?00:00:00? is returned.

// If no item in the object has the given tag, zero is returned. If the *FailOnNoItem*
// option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Time array*, and *inIndex* is
// in the range (0.. *OT SizeOfArray* ( *inObject; inTag* )), the value of the requested
// element is returned.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated, *OK* is set to zero, and the time ?00:00:00? is
// returned.


// OT GetBLOB(inObject; inTag; outBLOB)

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_h : Time : Element value, or ?00:00:00? on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-11 - Added If/Else native/text retrieval guard
//   via stored-type inspection. See OTr_GetTime for strategy details.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_h : Time

OTr_zAddToCallStack(Current method name:C684)

var $raw_v : Variant

$raw_v:=OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Time array:K8:29)
If (Value type:C1509($raw_v)#Is undefined:K8:13)
	If (Value type:C1509($raw_v)=Is text:K8:3)
		$result_h:=OTr_uTextToTime($raw_v)
	Else
		$result_h:=$raw_v
	End if
End if

OTr_zRemoveFromCallStack(Current method name:C684)
