//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_New () --> Longint

// Allocates and returns a new OTr object handle.

// Access: Shared

// Returns:
//   $handle_i : Integer : New OTr object handle

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE()->$handle_i : Integer

var $slot_i : Integer

OTr_zLock

$slot_i:=Find in array(<>OTR_InUse_ab; False)
If ($slot_i=-1)
	$slot_i:=Size of array(<>OTR_InUse_ab)+1
	INSERT IN ARRAY(<>OTR_InUse_ab; $slot_i)
	INSERT IN ARRAY(<>OTR_Objects_ao; $slot_i)

	<>OTR_InUse_ab{$slot_i}:=True
	<>OTR_Objects_ao{$slot_i}:=New object
Else
	<>OTR_InUse_ab{$slot_i}:=True
	<>OTR_Objects_ao{$slot_i}:=New object
End if

OTr_zUnlock

$handle_i:=$slot_i
