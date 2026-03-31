//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Compiler_OTr

// Declares all variables and parameters for the 
// Object Tools Replacement component

// Access: Private

// Parameters: None

// Returns: Nothing

// Created by Wayne Stewart (2026-03-31)
//     waynestewart@mac.com
// ----------------------------------------------------

C_BOOLEAN:C305(<>OTR_Initialised_b)


If (Not:C34(<>OTR_Initialised_b))
	C_TEXT:C284(<>OTR_ErrorHandler_t; <>OTR_Semaphore_t)
	C_BOOLEAN:C305(<>OTR_Initialised_b)
	C_LONGINT:C283(<>OTR_Options_i)
	
	ARRAY BOOLEAN:C223(<>OTR_BlobInUse_ab; 0)
	ARRAY BLOB:C1222(<>OTR_Blobs_ax; 0)
	ARRAY BOOLEAN:C223(<>OTR_InUse_ab; 0)
	ARRAY OBJECT:C1221(<>OTR_Objects_ao; 0)
	ARRAY BOOLEAN:C223(<>OTR_PicInUse_ab; 0)
	ARRAY PICTURE:C279(<>OTR_Pictures_ap; 0)
	
End if 


If (False:C215)
	C_TEXT:C284(OTr_SetErrorHandler; $0)
	C_TEXT:C284(OTr_SetErrorHandler; $1)
	C_TEXT:C284(OTr_SaveToText; $0)
	C_LONGINT:C283(OTr_SaveToText; $1)
	C_BOOLEAN:C305(OTr_SaveToText; $2)
	C_LONGINT:C283(OTr_SaveToFile; $1)
	C_TEXT:C284(OTr_SaveToFile; $2)
	C_BOOLEAN:C305(OTr_SaveToFile; $3)
	C_LONGINT:C283(OTr_SaveToClipboard; $1)
	C_BOOLEAN:C305(OTr_SaveToClipboard; $2)
	C_LONGINT:C283(OTr_SetOptions; $1)
	C_LONGINT:C283(OTr_Copy; $0)
	C_LONGINT:C283(OTr_Copy; $1)
	C_LONGINT:C283(OTr_CompiledApplication; $0)
	C_LONGINT:C283(OTr_GetOptions; $0)
	C_BOOLEAN:C305(OTr__IsValidHandle; $0)
	C_LONGINT:C283(OTr__IsValidHandle; $1)
	C_LONGINT:C283(OTr_Clear; $1)
	C_BOOLEAN:C305(OTr__Error; $0)
	C_TEXT:C284(OTr__Error; $1)
	C_TEXT:C284(OTr__Error; $2)
	C_TEXT:C284(OTr_GetVersion; $0)
	C_LONGINT:C283(OTr_IsObject; $0)
	C_LONGINT:C283(OTr_IsObject; $1)
	C_LONGINT:C283(OTr_Register; $0)
	C_TEXT:C284(OTr_Register; $1)
	C_LONGINT:C283(OTr_New; $0)
	C_POINTER:C301(OTr_GetHandleList; $1)
	//C_LONGINT(____Test_Phase_1_5; $0)
End if 
