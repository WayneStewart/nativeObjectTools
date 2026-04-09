//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_Copy (inObject) --> Longint

// Deep-copies a stored object into a new handle.

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

OTr_zAddToCallStack(Current method name)

var $slot_i : Integer
var $source_o : Object

$copyHandle_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	$slot_i:=Find in array(<>OTR_InUse_ab; False)
	If ($slot_i=-1)
		$slot_i:=Size of array(<>OTR_InUse_ab)+1
		INSERT IN ARRAY(<>OTR_InUse_ab; $slot_i)
		INSERT IN ARRAY(<>OTR_Objects_ao; $slot_i)
	End if

	$source_o:=<>OTR_Objects_ao{$inObject_i}
	<>OTR_Objects_ao{$slot_i}:=OB Copy($source_o)
	<>OTR_InUse_ab{$slot_i}:=True

	$copyHandle_i:=$slot_i
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
