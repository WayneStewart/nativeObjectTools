//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetTime (inObject; inTag) --> Time

// Retrieves a Time value from the specified tag path.

// **ORIGINAL DOCUMENTATION**

// *OT GetTime* gets a value in *inObject* from the item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and ?00:00:00? is returned.

// If no item in the object has the given tag, ?00:00:00? is returned. If the
// *FailOnNoItem* option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Is Time*, the value of the
// requested item is returned.

// If an item with the given tag exists and has any other type, *OK* is set to zero
// and ?00:00:00? is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_h : Time : Stored value, or 00:00:00 on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Added If/Else native/text retrieval guard.
//   The stored type is inspected directly: if the property is Is text,
//   it is parsed via OTr_u_TextToTime ("HH:MM:SS"); if it is Is time,
//   it is retrieved natively. Handles both storage paths and any legacy
//   text-stored times correctly.
// Wayne Stewart, 2026-04-12 - Added OTr_z_MapType outer type guard (shadow-key-first).
//   OTr_z_MapType = Is time:K8:8 is the admission test; only then does the inner branch
//   inspect OB Get type to decide whether to retrieve natively (Is time) or parse text
//   ("HH:MM:SS"). This separation is necessary because both storage paths now write
//   shadow key Is time:K8:8, so the shadow key alone cannot distinguish native from text
//   storage — the raw OB Get type (Is time vs Is text) correctly identifies the representation.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_h : Time

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $rawText_t : Text

$result_h:=?00:00:00?

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			If (OTr_z_MapType($parent_o; $leafKey_t)=Is time:K8:8)
				// Inner branch on raw storage representation:
				// both paths now write shadow key Is time:K8:8, so use OB Get type
				// to distinguish native time from text-encoded time.
				If (OB Get type:C1230($parent_o; $leafKey_t)=Is text:K8:3)
					// Text path: stored as "HH:MM:SS"
					$rawText_t:=OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3)
					$result_h:=OTr_u_TextToTime($rawText_t)
				Else 
					// Native path: stored as native Time
					$result_h:=OB Get:C1224($parent_o; $leafKey_t; Is time:K8:8)
				End if 
			Else 
				OTr_z_Error("Type mismatch"; Current method name:C684)
				OTr_z_SetOK(0)
			End if 
		End if 
	End if 
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
