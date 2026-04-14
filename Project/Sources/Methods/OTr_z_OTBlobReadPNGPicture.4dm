//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadPNGPicture (inBlob; inOffset; outEndOffset; outPicture) --> Boolean

// Compatibility wrapper retained for older Phase 16 parser revisions.
// New code should call OTr_z_OTBlobReadWrappedPicture.

#DECLARE($inBlob_blob : Blob; $inOffset_i : Integer; $outEndOffset_ptr : Pointer; $outPicture_ptr : Pointer)->$result_b : Boolean

$result_b:=OTr_z_OTBlobReadWrappedPicture($inBlob_blob; $inOffset_i; $outEndOffset_ptr; $outPicture_ptr)
