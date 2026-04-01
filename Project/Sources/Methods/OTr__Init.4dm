//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr__Init

// Initialises the OTr registry arrays and default module state.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

C_BOOLEAN:C305(<>OTR_Initialised_b)


If (Not:C34(<>OTR_Initialised_b))
	ARRAY OBJECT:C1221(<>OTR_Objects_ao; 0)
	ARRAY BOOLEAN:C223(<>OTR_InUse_ab; 0)
	
	ARRAY BLOB:C1222(<>OTR_Blobs_ablob; 0)
	ARRAY BOOLEAN:C223(<>OTR_BlobInUse_ab; 0)
	
	ARRAY PICTURE:C279(<>OTR_Pictures_apic; 0)
	ARRAY BOOLEAN:C223(<>OTR_PicInUse_ab; 0)
	
	<>OTR_Options_i:=4  // AutoCreateObjects on by default.
	<>OTR_ErrorHandler_t:=""
	
	<>OTR_Semaphore_t:="$OTr_Registry"
	
	<>OTR_Initialised_b:=True:C214
End if 

