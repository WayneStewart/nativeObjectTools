//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetBoolean (inObject; inTag) --> Longint

// Retrieves a Boolean value from the specified tag path as 1/0 for
// legacy ObjectTools compatibility.

// **ORIGINAL DOCUMENTATION**

// OT GetBoolean gets a value in *inObject* from the item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and zero is returned.

// If no item in the object has the given tag, zero is returned. If the *FailOnNoItem*
// option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Is Boolean*, the value of the
// requested item is returned.

// If an item with the given tag exists and has any other type, *OK* is set to zero, and
// zero is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_i : Integer : 1 when True, otherwise 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is boolean type argument
//     to prevent crash when stored value is a non-Boolean type.
// Wayne Stewart, 2026-04-11 - Added type pre-check: if stored type is not
//     Is boolean, generates an error, sets OK=0, and returns 0 (False).
//     Matches OT behaviour — coercion from other types is not performed.
// Wayne Stewart, 2026-04-12 - Type check replaced with OTr_z_MapType (shadow-key-first)
//   instead of OB Get type = Is boolean. OTr_z_MapType consults the shadow key written by
//   OTr_PutBoolean (Is Boolean:K8:9) and is therefore version-independent.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $value_b : Boolean

$result_i:=0

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			If (OTr_z_MapType($parent_o; $leafKey_t)=Is boolean:K8:9)
				$value_b:=OB Get:C1224($parent_o; $leafKey_t; Is boolean:K8:9)
				If ($value_b)
					$result_i:=1
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
