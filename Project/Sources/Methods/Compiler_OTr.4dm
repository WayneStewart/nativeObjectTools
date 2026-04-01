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
	
	// The objects
	ARRAY BOOLEAN:C223(<>OTR_InUse_ab; 0)
	ARRAY OBJECT:C1221(<>OTR_Objects_ao; 0)
	
	// Storage of BLOBS
	ARRAY BOOLEAN:C223(<>OTR_BlobInUse_ab; 0)
	ARRAY BLOB:C1222(<>OTR_Blobs_ablob; 0)
	
	// Storage of Pictures
	ARRAY BOOLEAN:C223(<>OTR_PicInUse_ab; 0)
	ARRAY PICTURE:C279(<>OTR_Pictures_apic; 0)
	
End if 


If (False:C215)
	C_TEXT:C284(OTr_SetErrorHandler; $0)
	C_TEXT:C284(OTr_SetErrorHandler; $1)
	
	C_BOOLEAN:C305(OTr__ResolvePath; $0; $3)
	C_OBJECT:C1216(OTr__ResolvePath; $1)
	C_TEXT:C284(OTr__ResolvePath; $2)
	C_POINTER:C301(OTr__ResolvePath; $4; $5)
	
	C_LONGINT:C283(OTr_PutLong; $1; $3)
	C_TEXT:C284(OTr_PutLong; $2)
	
	C_LONGINT:C283(OTr_GetLong; $0; $1)
	C_TEXT:C284(OTr_GetLong; $2)
	
	C_LONGINT:C283(OTr_PutReal; $1)
	C_TEXT:C284(OTr_PutReal; $2)
	C_REAL:C285(OTr_PutReal; $3)
	C_REAL:C285(OTr_GetReal; $0)
	
	C_LONGINT:C283(OTr_GetReal; $1)
	C_TEXT:C284(OTr_GetReal; $2)
	
	C_LONGINT:C283(OTr_PutString; $1)
	C_TEXT:C284(OTr_PutString; $2; $3)
	
	C_TEXT:C284(OTr_GetString; $0; $2)
	C_LONGINT:C283(OTr_GetString; $1)
	
	C_LONGINT:C283(OTr_PutText; $1)
	C_TEXT:C284(OTr_PutText; $2; $3)
	
	C_TEXT:C284(OTr_GetText; $0; $2)
	C_LONGINT:C283(OTr_GetText; $1)
	
	C_LONGINT:C283(OTr_PutDate; $1)
	C_TEXT:C284(OTr_PutDate; $2)
	C_DATE:C307(OTr_PutDate; $3)
	
	C_DATE:C307(OTr_GetDate; $0)
	C_LONGINT:C283(OTr_GetDate; $1)
	C_TEXT:C284(OTr_GetDate; $2)
	
	C_LONGINT:C283(OTr_PutTime; $1)
	C_TEXT:C284(OTr_PutTime; $2)
	C_TIME:C306(OTr_PutTime; $3)
	
	C_TIME:C306(OTr_GetTime; $0)
	C_LONGINT:C283(OTr_GetTime; $1)
	C_TEXT:C284(OTr_GetTime; $2)
	
	C_LONGINT:C283(OTr_PutBoolean; $1)
	C_TEXT:C284(OTr_PutBoolean; $2)
	C_BOOLEAN:C305(OTr_PutBoolean; $3)
	
	C_LONGINT:C283(OTr_GetBoolean; $0; $1)
	C_TEXT:C284(OTr_GetBoolean; $2)
	
	C_LONGINT:C283(OTr_PutObject; $1; $3)
	C_TEXT:C284(OTr_PutObject; $2)
	
	C_LONGINT:C283(OTr_GetObject; $0; $1)
	C_TEXT:C284(OTr_GetObject; $2)
	
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
	C_TEXT:C284(OTr__Error; $1; $2)
	
	C_TEXT:C284(OTr_GetVersion; $0)
	
	C_LONGINT:C283(OTr_IsObject; $0)
	C_LONGINT:C283(OTr_IsObject; $1)
	
	C_LONGINT:C283(OTr_ItemCount; $0; $1)
	C_TEXT:C284(OTr_ItemCount; $2)
	
	C_LONGINT:C283(OTr_ObjectSize; $0; $1)
	
	C_LONGINT:C283(OTr_ItemExists; $0; $1)
	C_TEXT:C284(OTr_ItemExists; $2)
	
	C_LONGINT:C283(OTr_ItemType; $0; $1)
	C_TEXT:C284(OTr_ItemType; $2)
	
	C_LONGINT:C283(OTr_IsEmbedded; $0; $1)
	C_TEXT:C284(OTr_IsEmbedded; $2)
	
	C_TEXT:C284(OTr_GetAllNamedProperties; $2)
	C_LONGINT:C283(OTr_GetAllNamedProperties; $1)
	C_POINTER:C301(OTr_GetAllNamedProperties; $3; $4; $5; $6)
	
	C_LONGINT:C283(OTr_GetAllProperties; $1)
	C_POINTER:C301(OTr_GetAllProperties; $2; $3; $4; $5)
	
	C_LONGINT:C283(OTr_GetItemProperties; $1; $2)
	C_POINTER:C301(OTr_GetItemProperties; $3; $4; $5; $6)
	
	C_LONGINT:C283(OTr_GetNamedProperties; $1)
	C_TEXT:C284(OTr_GetNamedProperties; $2)
	C_POINTER:C301(OTr_GetNamedProperties; $3; $4; $5; $6)
	
	C_LONGINT:C283(OTr_CompareItems; $0; $1; $3)
	C_TEXT:C284(OTr_CompareItems; $2; $4)
	
	C_LONGINT:C283(OTr_CopyItem; $1; $3)
	C_TEXT:C284(OTr_CopyItem; $2; $4)
	
	C_LONGINT:C283(OTr_RenameItem; $1)
	C_TEXT:C284(OTr_RenameItem; $2; $3)
	
	C_LONGINT:C283(OTr_DeleteItem; $1)
	C_TEXT:C284(OTr_DeleteItem; $2)
	
	C_LONGINT:C283(OTr__MapType; $0)
	C_OBJECT:C1216(OTr__MapType; $1)
	C_TEXT:C284(OTr__MapType; $2)
	
	C_OBJECT:C1216(OTr__ReleaseObjBinaries; $1)
	
	C_TEXT:C284(OTr__ReleaseBinaryRef; $1)
	
	C_LONGINT:C283(OTr_Register; $0)
	C_TEXT:C284(OTr_Register; $1)
	
	C_LONGINT:C283(OTr_New; $0)
	
	C_POINTER:C301(OTr_GetHandleList; $1)
	
	C_BOOLEAN:C305(OTr__EqualBLOBs; $0)
	C_BLOB:C604(OTr__EqualBLOBs; $1; $2)
	
	C_BOOLEAN:C305(Otr__EqualStrings; $0)
	C_TEXT:C284(Otr__EqualStrings; $1; $2)
	
	C_BOOLEAN:C305(OTr__EqualPictures; $0)
	C_PICTURE:C286(OTr__EqualPictures; $1; $2)
	
	C_OBJECT:C1216(OTr__EqualObjects; $1; $2)
	C_BOOLEAN:C305(OTr__EqualObjects; $0)
	
	C_LONGINT:C283(OTr_PutArray; $1)
	C_TEXT:C284(OTr_PutArray; $2)
	C_POINTER:C301(OTr_PutArray; $3)
	
	
	C_TIME:C306(OTr_uTimeToText; $1)
	C_TEXT:C284(OTr_uTimeToText; $0)
	
	C_TEXT:C284(OTr_uTextToTime; $1)
	C_TIME:C306(OTr_uTextToTime; $0)
	
	C_DATE:C307(OTr_uDateToText; $1)
	C_TEXT:C284(OTr_uDateToText; $0)
	
	C_TEXT:C284(OTr_uTextToDate; $1)
	C_DATE:C307(OTr_uTextToDate; $0)
	
	C_POINTER:C301(OTr_uPointerToText; $1)
	C_TEXT:C284(OTr_uPointerToText; $0)
	
	C_TEXT:C284(OTr_uTextToPointer; $1)
	C_POINTER:C301(OTr_uTextToPointer; $0)
	
	C_LONGINT:C283(OTr_SizeOfArray; $0; $1)
	C_TEXT:C284(OTr_SizeOfArray; $2)
	
	C_LONGINT:C283(OTr_ResizeArray; $1; $3)
	C_TEXT:C284(OTr_ResizeArray; $2)
	
	C_OBJECT:C1216(OTr__ArrayFromObject; $1)
	C_POINTER:C301(OTr__ArrayFromObject; $2)
	
	C_LONGINT:C283(OTr__ArrayType; $0)
	C_OBJECT:C1216(OTr__ArrayType; $1)
	
	C_LONGINT:C283(OTr_ArrayType; $0; $1)
	C_TEXT:C284(OTr_ArrayType; $2)
	
	C_LONGINT:C283(OTr_GetArray; $1)
	C_TEXT:C284(OTr_GetArray; $2)
	C_POINTER:C301(OTr_GetArray; $3)
	
	C_BLOB:C604(OTr_uBlobToText; $1)
	C_TEXT:C284(OTr_uBlobToText; $0)
	
	C_TEXT:C284(OTr_uTextToBlob; $1)
	C_BLOB:C604(OTr_uTextToBlob; $0)
	
	C_PICTURE:C286(OTr_uPictureToText; $1)
	C_TEXT:C284(OTr_uPictureToText; $0)
	
	C_TEXT:C284(OTr_uTextToPicture; $1)
	C_PICTURE:C286(OTr_uTextToPicture; $0)
	
	C_TEXT:C284(OTr_FindInArray; $2; $3)
	C_LONGINT:C283(OTr_FindInArray; $1; $0; $4)
	
	
End if 
