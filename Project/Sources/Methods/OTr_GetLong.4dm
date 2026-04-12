//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetLong (inObject; inTag) --> Longint

// Retrieves an Integer value from the specified tag path.

// **ORIGINAL DOCUMENTATION**

// OT GetLong gets a value in *inObject* from the item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and zero is returned.

// If no item in the object has the given tag, zero is returned. If the *FailOnNoItem*
// option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Is Longint*, the value of the
// requested item is returned.

// If an item with the given tag exists and has any other type, *OK* is set to zero, and
// zero is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_i : Integer : Stored value, or 0 on missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is longint type argument
//     to prevent crash when stored value is a non-Integer type.
// Wayne Stewart, 2026-04-12 - Added OTr_z_MapType type guard (shadow-key-first).
//   4D stores both Longint and Real as Is real at the JSON level; without this
//   guard, OTr_GetLong would silently succeed on a Real property. Guard returns
//   an error, sets OK=0, and returns 0 when the shadow key is not Is longint:K8:6.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text

$result_i:=0

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			If (OTr_z_MapType($parent_o; $leafKey_t)=Is longint:K8:6)
				$result_i:=OB Get:C1224($parent_o; $leafKey_t; Is longint:K8:6)
			Else 
				OTr_z_Error("Type mismatch"; Current method name:C684)
				OTr_z_SetOK(0)
			End if 
		End if 
	End if 
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
