//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobIsObject (inBlob) --> Boolean

// Detects the ObjectTools object BLOB envelope used by OT ObjectToBLOB
// and OT ObjectToNewBLOB.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob : Blob : BLOB to inspect
//
// Returns:
//   $isLegacy_b : Boolean : True when the BLOB has a legacy OT object envelope
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added legacy ObjectTools object envelope detector.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob)->$isLegacy_b : Boolean

OTr_z_AddToCallStack(Current method name:C684)

$isLegacy_b:=False

If (BLOB size($inBlob_blob)>=24)
	$isLegacy_b:=($inBlob_blob{0}=255) \
		& ($inBlob_blob{1}=255) \
		& ($inBlob_blob{4}=79) \
		& ($inBlob_blob{5}=98) \
		& ($inBlob_blob{6}=106) \
		& ($inBlob_blob{7}=101) \
		& ($inBlob_blob{8}=99) \
		& ($inBlob_blob{9}=116) \
		& ($inBlob_blob{10}=115) \
		& ($inBlob_blob{11}=33)
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
