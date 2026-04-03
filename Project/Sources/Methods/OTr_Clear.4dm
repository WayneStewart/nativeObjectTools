//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_Clear (ioObject)

// Releases an OTr handle and clears its stored object.

// Access: Shared

// Parameters:
//   $ioObject_i : Integer : OTr handle to clear (ioObject)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($ioObject_i : Integer)

var $size_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($ioObject_i))
	<>OTR_Objects_ao{$ioObject_i}:=Null
	<>OTR_InUse_ab{$ioObject_i}:=False

	$size_i:=Size of array(<>OTR_InUse_ab)
	While (($size_i>0) & (<>OTR_InUse_ab{$size_i}=False))
		DELETE FROM ARRAY(<>OTR_InUse_ab; $size_i)
		DELETE FROM ARRAY(<>OTR_Objects_ao; $size_i)
		$size_i:=$size_i-1
	End while
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock
