//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutString (inObject; inTag; inValue)

// Stores a String/Text inValue at the specified inTag path.

// **ORIGINAL DOCUMENTATION**
//
// *OTr_PutString* puts *inValue* into *inObject*.
//
// If *inObject* is not a valid object handle, an error is generated and OK is set to zero.
//
// If no item in the object has the given inTag, a new item is created.
//
// If an item with the given inTag exists and has the the matching type, its value is replaced.
//
// If an item with the given inTag exists and has any other type,
//    an error is generated and OK is set to zero if the _OT VariantItems_ option is not set,
//    otherwise the existing item is deleted and a new item is created.
//
// See "The Character Item Type" on page 13 for more information on storing and retrieving strings.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path
//   $inValue_t  : Text    : Value to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-11 - Added type-consistency guard implementing the documented
//   OT behaviour: refuses to overwrite an existing item whose stored type differs from
//   Text/String (OK=0, value unchanged). Applies when OT VariantItems option is not set.
// Wayne Stewart, 2026-04-12 - Type guard updated to use OTr_zMapType (shadow-key-first)
//   instead of OB Get type = Is text. The old guard was dangerously broad: Pointer
//   (Is pointer = 23), BLOB fallback (Is BLOB = 30), Date text path (Is date = 4), and
//   Time text path (Is time = 11) are all stored as Is text with shadow keys; the old
//   guard would have passed them all incorrectly.
//   OTr_zMapType = 112 (OT Character) correctly admits only genuine user strings.
//   Write shadow-type key (leafKey$type := OT Character = 112) so that OTr_ItemType
//   and OTr_GetString can reliably identify the stored type, and so that the type guard
//   on next write can correctly distinguish a string from a Pointer/BLOB/Date/Time
//   stored as text.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_t : Text)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $existingType_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$existingType_i:=OTr_zMapType($parent_o; $leafKey_t)
			If ($existingType_i#0) & ($existingType_i#OT Is Character)
				OTr_zError("Type mismatch"; Current method name:C684)
			Else
				OB SET:C1220($parent_o; $leafKey_t; $inValue_t)
				OB SET:C1220($parent_o; OTr_zShadowKey($leafKey_t); OT Is Character)
			End if
		Else
			OB SET:C1220($parent_o; $leafKey_t; $inValue_t)
			OB SET:C1220($parent_o; OTr_zShadowKey($leafKey_t); OT Is Character)
		End if
	End if
Else
	OTr_zError("Invalid inObject"; Current method name:C684)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
