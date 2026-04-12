//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_Clear (ioObject)

// Releases an OTr handle and clears its stored object.

// **ORIGINAL DOCUMENTATION**

// When you are finished with an object, you should always call *OT Clear* to release the
// memory occupied by the object. If you create an object and then lose track of its
// handle, you will no longer be able to release its memory. This is known as a *leak*,
// and it is considered a Bad Thing.

// ObjectTools maintains an internal list of all objects that have been created but not
// cleared. When an object is disposed of with *OT Clear*, it is removed from the list.
// The current list of created objects is available with the *OT GetHandleList* method.

// You can actually release the memory used by leaked objects with *OT GetHandleList* or
// *OT ClearAll*. However, using these as a means of object memory management is not
// recommended.

// If you pass a variable directly to *OT Clear* (as opposed to an extremely lucky guess
// at a number constant), the variable will be set to zero.

// Note: It is legal to pass a null handle (0) to *OT Clear*.

// Access: Shared

// Parameters:
//   $ioObject_i : Integer : OTr handle to clear (ioObject)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-12 - On clear, slot is re-initialised to an empty object rather than null,
//   ensuring the registry slot is always in a defined, traversable state.
// ----------------------------------------------------

#DECLARE($ioObject_i : Integer)

OTr_zAddToCallStack(Current method name:C684)

var $size_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($ioObject_i))
	<>OTR_Objects_ao{$ioObject_i}:=New object:C1471()
	<>OTR_InUse_ab{$ioObject_i}:=False:C215
	
	$size_i:=Size of array:C274(<>OTR_InUse_ab)
	While (($size_i>0) & (<>OTR_InUse_ab{$size_i}=False:C215))
		DELETE FROM ARRAY:C228(<>OTR_InUse_ab; $size_i)
		DELETE FROM ARRAY:C228(<>OTR_Objects_ao; $size_i)
		$size_i:=$size_i-1
	End while 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name:C684)
