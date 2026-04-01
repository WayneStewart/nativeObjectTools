//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uBlobToText ($theBlob_x : Blob) --> Text

// Stores a BLOB in the OTr parallel blob array and
// returns a reference string "blob:N" for storage
// in an OTr object. Reuses released slots in
// <>OTR_Blobs_ablob before appending a new one.

// Access: Private

// Parameters:
//   $theBlob_x : Blob : The BLOB to store

// Returns:
//   $blobRef_t : Text : Reference string "blob:N"

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($theBlob_x : Blob)->$blobRef_t : Text

var $slot_i : Integer

$slot_i:=Find in array:C230(<>OTR_BlobInUse_ab; False:C215)
If ($slot_i=-1)
	$slot_i:=Size of array:C274(<>OTR_Blobs_ablob)+1
	INSERT IN ARRAY:C227(<>OTR_Blobs_ablob; $slot_i; 1)
	INSERT IN ARRAY:C227(<>OTR_BlobInUse_ab; $slot_i; 1)
End if

<>OTR_Blobs_ablob{$slot_i}:=$theBlob_x
<>OTR_BlobInUse_ab{$slot_i}:=True:C214

$blobRef_t:="blob:"+String:C10($slot_i)
