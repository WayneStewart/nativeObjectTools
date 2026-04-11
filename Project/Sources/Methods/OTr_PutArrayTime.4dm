//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayTime (inObject; inTag; inIndex; inValue)

// Sets a single element of a Time array item.
// OK is unchanged on success; set to 0 on any failure.

// Storage strategy mirrors OTr_PutTime:
//   Storage.OTr.nativeDateInObject = True  → element stored as native Time
//   Storage.OTr.nativeDateInObject = False → element stored as "HH:MM:SS" text
//                                            via OTr_uTimeToText (default)

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
