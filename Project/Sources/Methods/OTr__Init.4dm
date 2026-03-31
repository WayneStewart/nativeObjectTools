//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr__Init

// Initialises the OTr registry arrays and default module state.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// ----------------------------------------------------

If (Undefined(<>OTR_Initialized_b))
	<>OTR_Initialized_b:=False
End if

If (Not(<>OTR_Initialized_b))
	ARRAY OBJECT(<>OTR_Objects_ao; 0)
	ARRAY BOOLEAN(<>OTR_InUse_ab; 0)

	ARRAY BLOB(<>OTR_Blobs_ax; 0)
	ARRAY BOOLEAN(<>OTR_BlobInUse_ab; 0)

	ARRAY PICTURE(<>OTR_Pictures_ap; 0)
	ARRAY BOOLEAN(<>OTR_PicInUse_ab; 0)

	<>OTR_Options_i:=4  // AutoCreateObjects on by default.
	<>OTR_ErrorHandler_t:=""

	<>OTR_Initialized_b:=True
End if
