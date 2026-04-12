//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayDate (inObject; inTag; inIndex; inValue)

// Sets a single element of a Date array item.
// OK is unchanged on success; set to 0 on any failure.

// Storage strategy mirrors OTr_PutDate:
//   Storage.OTr.nativeDateInObject = True  → element stored as native Date
//   Storage.OTr.nativeDateInObject = False → element stored as "YYYY-MM-DD" text
//                                            via OTr_uDateToText (default)

// **ORIGINAL DOCUMENTATION**

// OT PutArrayDate sets an element of an array in *inObject*.

// If the object is not a valid object handle or if no item in the object has the given
// tag, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Date array*, and *inIndex* is
// in the range (0.. *OT SizeOfArray* ( *inObject; inTag* )), the value of the requested
// element is set to *inValue*.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated and *OK* is set to zero.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)
//   $inValue_d  : Date    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-11 - Added If/Else native/text storage guard to
//   match OTr_PutDate strategy. See OTr_uNativeDateInObject for probe details.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inValue_d : Date)

OTr_zAddToCallStack(Current method name:C684)

var $encoded_v : Variant

If (OTr_uNativeDateInObject)
	$encoded_v:=$inValue_d
Else
	$encoded_v:=OTr_uDateToText($inValue_d)
End if

OTr_zLock
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Date array:K8:20; $encoded_v)
OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name:C684)
