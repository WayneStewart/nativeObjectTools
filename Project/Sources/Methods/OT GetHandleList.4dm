//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetHandleList (outHandles)

// Fills a Longint array with currently allocated OTr handles.

// **ORIGINAL DOCUMENTATION**

// Any time an object is created, whether through *OT New*, *OT Copy*,
// *OT GetObject*, or *OT BLOBToObject*, ObjectTools adds the new object
// handle to an internal list. When an object is cleared with *OT Clear*,
// the object's handle is removed from the list.

// *OT GetHandleList* retrieves this internal list into an array. This is
// mainly of use in debugging. Normally you would have no need to use this
// method.

// Access: Shared

// Parameters:
//   $outHandles_ptr : Pointer : Pointer to Longint array to receive active handles (outHandles)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($outHandles_ptr : Pointer)

OTr_z_AddToCallStack(Current method name:C684)

var $index_i : Integer

ARRAY LONGINT:C221($handleList_ai; 0)

OTr_z_Lock

For ($index_i; 1; Size of array:C274(<>OTR_InUse_ab))
	If (<>OTR_InUse_ab{$index_i})
		APPEND TO ARRAY:C911($handleList_ai; $index_i)
	End if 
End for 

OTr_z_Unlock

COPY ARRAY:C226($handleList_ai; $outHandles_ptr->)

OTr_z_RemoveFromCallStack(Current method name:C684)
