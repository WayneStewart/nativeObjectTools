//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetObject (inObject; inTag) --> Longint

// Retrieves an embedded object by tag path, copies it to a new OTr
// handle, and returns that handle.

// **WARNING: Changed Behaviour**

// The returned handle contains a deep copy of the embedded object.
// Changes made to the returned object are not written back to the
// parent item unless OT PutObject is called explicitly.

// **ORIGINAL DOCUMENTATION**

// *OT GetObject* gets an object value in object from the item referenced by *inTag*. If
// this routine successfully returns a new object, the new object handle is added to the
// ObjectTools handle list.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and a null object handle (0) is returned.

// If no item in the object has the given tag, a null object handle is returned.

// If an item with the given tag exists and has the type *OT Is Object (114)*, its
// contents are returned as a new object.

// If an item with the given tag exists and has any other type, an error is generated,
// *OK* is set to zero, and a null object handle is returned.

// Warning: This method creates and returns a new object in memory. You are responsible
// for clearing it when you no longer need it by calling *OT IsObject*.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to embedded object (inTag)

// Returns:
//   $newHandle_i : Integer : New handle containing a copy of the embedded object, or 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$newHandle_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $embedded_o : Object

$newHandle_i:=0

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$embedded_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
			If ($embedded_o#Null:C1517)
				$newHandle_i:=Find in array:C230(<>OTR_InUse_ab; False:C215)
				If ($newHandle_i=-1)
					$newHandle_i:=Size of array:C274(<>OTR_InUse_ab)+1
					INSERT IN ARRAY:C227(<>OTR_InUse_ab; $newHandle_i)
					INSERT IN ARRAY:C227(<>OTR_Objects_ao; $newHandle_i)
				End if 
				
				<>OTR_InUse_ab{$newHandle_i}:=True:C214
				<>OTR_Objects_ao{$newHandle_i}:=OB Copy:C1225($embedded_o)
			End if 
		End if 
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
