//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT ArrayType (inObject; inTag) --> Longint

// Returns the stored arrayType value from an OTr
// array object. Used to verify type compatibility
// before performing array operations.
// Returns -1 if the handle is invalid, the tag does
// not exist, or the tag does not reference an array.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)

// Returns:
//   $arrayType_i : Integer : Stored array type constant, or -1

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is object type argument
//     to prevent crash when tag holds a scalar rather than an array.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$arrayType_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text

$arrayType_i:=-1

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
			$arrayType_i:=OTr_z_ArrayType($arrayObj_o)
		End if 
	End if 
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
