//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_Copy (inObject) --> Longint

// Deep-copies a stored object into a new handle.

// **ORIGINAL DOCUMENTATION**

// *OT Copy* makes a complete copy of object and returns the copy. The copy is added
// to the ObjectTools handle list, and must be cleared with OT *IsObject* when it is no
// longer needed.

// If memory cannot be allocated for the copy, an error is generated and *OK* is set to
// zero.


// Put Value Routines

// The following routines are used to store data in any ObjectTools object. After you
// have successfully created an object (see “Creation and Destruction Routines”), you can
// begin storing data into the object.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject

// Returns:
//   $copyHandle_i : Integer : New handle containing copied object, or 0 on failure

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)->$copyHandle_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $slot_i : Integer
var $source_o : Object

$copyHandle_i:=0

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	$slot_i:=Find in array:C230(<>OTR_InUse_ab; False:C215)
	If ($slot_i=-1)
		$slot_i:=Size of array:C274(<>OTR_InUse_ab)+1
		INSERT IN ARRAY:C227(<>OTR_InUse_ab; $slot_i)
		INSERT IN ARRAY:C227(<>OTR_Objects_ao; $slot_i)
	End if 
	
	$source_o:=<>OTR_Objects_ao{$inObject_i}
	<>OTR_Objects_ao{$slot_i}:=OB Copy:C1225($source_o)
	<>OTR_InUse_ab{$slot_i}:=True:C214
	
	$copyHandle_i:=$slot_i
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
