//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ObjectSize (inObject) --> Longint

// Returns an approximation of the size of an OTr object as the character
// length of its JSON representation. All scalar, text, date, boolean,
// and nested object properties are included in the JSON output. Native
// BLOB and Picture properties are not emitted by JSON Stringify and are
// therefore not counted; this is consistent with the legacy plugin's
// approximation contract. No loop over individual keys is required
// because all content — including embedded objects at any depth — is
// fully serialised by a single JSON Stringify call.
// Byte counts will not match the legacy plugin.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject

// Returns:
//   $size_i : Integer : Approximate size in characters, or 0 on error

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-05 - Removed erroneous per-key BLOB/Picture
//   size loop. BLOBs and Pictures are embedded in the Object; no
//   external accumulation is required or correct.
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_zSetOK(1) on
//   success path (see OTr-OK0-Conditions specification).
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)->$size_i : Integer

OTr_zAddToCallStack(Current method name)

$size_i:=0

// OTr_zLock // Unnecessary to lock for Read Only access

OTr_zInit

If (OTr_zIsValidHandle($inObject_i))
	$size_i:=Length:C16(JSON Stringify:C1217(<>OTR_Objects_ao{$inObject_i}))

Else
	OTr_zError("Invalid handle"; Current method name:C684)
End if

// OTr_zUnlock // Unnecessary to lock for Read Only access

OTr_zRemoveFromCallStack(Current method name)
