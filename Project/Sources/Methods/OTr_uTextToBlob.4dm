//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uTextToBlob ($blobRef_t : Text) --> Blob

// Retrieves a BLOB from the OTr parallel blob array
// using a reference string in "blob:N" format.
// Returns an empty BLOB if the reference is invalid
// or the slot is not in use.

// Access: Private

// Parameters:
//   $blobRef_t : Text : Reference string "blob:N"

// Returns:
//   $theBlob_x : Blob : The stored BLOB, or empty

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($blobRef_t : Text)->$theBlob_x : Blob

var $slot_i : Integer

If (Substring:C12($blobRef_t; 1; 5)="blob:")
	$slot_i:=Num:C11(Substring:C12($blobRef_t; 6))
	If (($slot_i>0) & ($slot_i<=Size of array:C274(<>OTR_Blobs_ablob)))
		If (<>OTR_BlobInUse_ab{$slot_i})
			$theBlob_x:=<>OTR_Blobs_ablob{$slot_i}
		End if
	End if
End if
