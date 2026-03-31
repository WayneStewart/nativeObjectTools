//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetHandleList ($handles_ptr : Pointer)

// Fills a Longint array with currently allocated OTr handles.

// Access: Shared

// Parameters:
//   $handles_ptr : Pointer : Pointer to Longint array destination

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// ----------------------------------------------------

#DECLARE($handles_ptr : Pointer)

var $index_i : Integer

ARRAY LONGINT($handleList_ai; 0)

OTr__Lock

For ($index_i; 1; Size of array(<>OTR_InUse_ab))
	If (<>OTR_InUse_ab{$index_i})
		APPEND TO ARRAY($handleList_ai; $index_i)
	End if
End for

OTr__Unlock

COPY ARRAY($handleList_ai; $handles_ptr->)
