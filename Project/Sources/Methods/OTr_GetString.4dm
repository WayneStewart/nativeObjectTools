//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetString (inObject; inTag) --> Text

// Retrieves a String/Text value from the specified tag path.

// **ORIGINAL DOCUMENTATION**

// OT GetString gets a value in *inObject* from the item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and an empty string is returned.

// If no item in the object has the given tag, an empty string is returned. If the
// *FailOnNoItem*

// option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *OT Is Character (112)*, the
// value of the requested element is returned.

// If an item with the given tag exists and has any other type, *OK* is set to zero, and
// an empty string is returned.

// See “The Character Item Type” on page 13 for more information on storing and
// retrieving strings.

// Warning: If your database is running in compatibility mode and the result of this
// method is assigned to a fixed width string variable, the item’s contents will be
// truncated to the width of the variable. To retrieve more than 255 characters from a
// character item, use *OT GetText* and assign to a text variable or field.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_t : Text : Stored value, or empty text on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-04 - Added OTr_zSetOK(1) on success.
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_zSetOK(1) on
//   success path (see OTr-OK0-Conditions specification).
// Wayne Stewart, 2026-04-11 - OB Get now uses Is text type argument
//     to prevent crash when stored value is a non-Text type.
// Wayne Stewart, 2026-04-12 - Added OTr_zError on invalid handle to match
//     the error-logging pattern of all other scalar Get methods.
// Wayne Stewart, 2026-04-12 - Added OTr_zMapType type guard (shadow-key-first).
//   Pointer (Is pointer:K8:14), BLOB fallback (Is BLOB:K8:12), Date text path (Is date:K8:7),
//   and Time text path (Is time:K8:8) are all stored as Is text but carry shadow keys
//   distinguishing them from genuine user strings. OTr_zMapType = OT Is Character
//   admits only genuine strings. Returns error and OK=0 for any other shadow key.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_t : Text

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

$result_t:=""

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			If (OTr_zMapType($parent_o; $leafKey_t)=OT Is Character)
				$result_t:=OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3)
			Else
				OTr_zError("Type mismatch"; Current method name)
				OTr_zSetOK(0)
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
