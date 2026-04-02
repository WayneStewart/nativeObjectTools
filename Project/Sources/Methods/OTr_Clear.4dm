//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_Clear ($handle_i : Integer)

// Releases an OTr handle and clears its stored object.

// Access: Shared

// Parameters:
//   $handle_i : Integer : Handle to release

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer)

var $size_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	<>OTR_Objects_ao{$handle_i}:=Null
	<>OTR_InUse_ab{$handle_i}:=False

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
