//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetDate (inObject; inTag) --> Date

// Retrieves a Date value from the specified tag path.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_d : Date : Stored value, or empty date on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Added If/Else native/text retrieval guard.
//   The stored type is inspected directly: if the property is Is text,
//   it is parsed via OTr_uTextToDate ("YYYY-MM-DD"); if it is Is date,
//   it is retrieved natively. Handles both storage paths and any legacy
//   text-stored dates correctly.
// Wayne Stewart, 2026-04-12 - Added OTr_zMapType outer type guard (shadow-key-first).
//   OTr_zMapType = Is date:K8:7 is the admission test; only then does the inner branch
//   inspect OB Get type to decide whether to retrieve natively (Is date) or parse text
//   ("YYYY-MM-DD"). This separation is necessary because both storage paths now write
//   shadow key Is date:K8:7, so the shadow key alone cannot distinguish native from text
//   storage — the raw OB Get type (Is date vs Is text) correctly identifies the representation.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_d : Date

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $rawText_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			If (OTr_zMapType($parent_o; $leafKey_t)=Is date:K8:7)
				// Inner branch on raw storage representation:
				// both paths now write shadow key 4, so use OB Get type
				// to distinguish native date from text-encoded date.
				If (OB Get type($parent_o; $leafKey_t)=Is text)
					// Text path: stored as "YYYY-MM-DD"
					$rawText_t:=OB Get($parent_o; $leafKey_t; Is text)
					$result_d:=OTr_uTextToDate($rawText_t)
				Else
					// Native path: stored as native Date
					$result_d:=OB Get($parent_o; $leafKey_t; Is date)
				End if
			Else
				OTr_zError("Type mismatch"; Current method name)
				OTr_zSetOK(0)
			End if
		End if
	End if
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
