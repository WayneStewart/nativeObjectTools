//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadPNGPicture (inBlob; inOffset; outEndOffset; outPicture) --> Boolean

// Compatibility wrapper retained for older Phase 16 parser revisions.
// New code should call OTr_z_OTBlobReadWrappedPicture.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob      : Blob    : Legacy ObjectTools object BLOB
//   $inOffset_i       : Integer : Offset after picture marker 138
//   $outEndOffset_ptr : Pointer : Receives offset immediately after image payload
//   $outPicture_ptr   : Pointer : Receives decoded 4D Picture
//
// Returns:
//   $result_b : Boolean : True when a PNG or JPEG picture was extracted
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Retained compatibility wrapper for renamed picture reader.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $inOffset_i : Integer; $outEndOffset_ptr : Pointer; $outPicture_ptr : Pointer)->$result_b : Boolean

OTr_z_AddToCallStack(Current method name:C684)

$result_b:=OTr_z_OTBlobReadWrappedPicture($inBlob_blob; $inOffset_i; $outEndOffset_ptr; $outPicture_ptr)

OTr_z_RemoveFromCallStack(Current method name:C684)
