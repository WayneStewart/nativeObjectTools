//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_IsObject (inObject) --> Longint

// Returns 1 when a handle is valid and in use, otherwise 0.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject

// Returns:
//   $isObject_i : Integer : 1 when handle is valid, otherwise 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-05 - Inlined handle check rather than calling
//   OTr_zIsValidHandle, because OT IsObject does not set OK and
//   OTr_zIsValidHandle now sets OK to 0 on failure. The inlined check
//   preserves the pre-call value of OK in all cases.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)->$isObject_i : Integer

OTr_zAddToCallStack(Current method name)

OTr_zLock

$isObject_i:=0

If ($inObject_i>0)
	If ($inObject_i<=Size of array:C274(<>OTR_InUse_ab))
		If (<>OTR_InUse_ab{$inObject_i})
			$isObject_i:=1
		End if
	End if
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
