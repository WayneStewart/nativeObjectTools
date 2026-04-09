//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetHandleList (outHandles)

// Fills a Longint array with currently allocated OTr handles.

// Access: Shared

// Parameters:
//   $outHandles_ptr : Pointer : Pointer to Longint array to receive active handles (outHandles)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($outHandles_ptr : Pointer)

OTr_zAddToCallStack(Current method name)

var $index_i : Integer

ARRAY LONGINT:C221($handleList_ai; 0)

OTr_zLock

For ($index_i; 1; Size of array:C274(<>OTR_InUse_ab))
	If (<>OTR_InUse_ab{$index_i})
		APPEND TO ARRAY:C911($handleList_ai; $index_i)
	End if 
End for 

OTr_zUnlock

COPY ARRAY:C226($handleList_ai; $outHandles_ptr->)

OTr_zRemoveFromCallStack(Current method name)
