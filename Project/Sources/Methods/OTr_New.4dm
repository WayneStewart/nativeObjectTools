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

OTr_z_AddToCallStack(Current method name:C684)

var $slot_i : Integer

OTr_z_Lock

$slot_i:=Find in array:C230(<>OTR_InUse_ab; False:C215)
If ($slot_i=-1)
	$slot_i:=Size of array:C274(<>OTR_InUse_ab)+1
	INSERT IN ARRAY:C227(<>OTR_InUse_ab; $slot_i)
	INSERT IN ARRAY:C227(<>OTR_Objects_ao; $slot_i)
	
	<>OTR_InUse_ab{$slot_i}:=True:C214
	<>OTR_Objects_ao{$slot_i}:=New object:C1471
Else 
	<>OTR_InUse_ab{$slot_i}:=True:C214
	<>OTR_Objects_ao{$slot_i}:=New object:C1471
End if 

OTr_z_Unlock

$handle_i:=$slot_i

OTr_z_RemoveFromCallStack(Current method name:C684)
