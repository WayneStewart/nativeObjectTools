//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Compiler_ObjectToolsReplacement

// Declares all variables and parameters for the
// Object Tools Replacement component

// Access: Private

// Parameters: None

// Returns: Nothing

// Created by Wayne Stewart (2026-03-31)
//     waynestewart@mac.com
// ----------------------------------------------------

C_BOOLEAN:C305(<>OTR_Initialised_b; OTR_Initialised_b)


If (Not:C34(<>OTR_Initialised_b))
	C_TEXT:C284(<>OTR_ErrorHandler_t; <>OTR_Semaphore_t)
	C_BOOLEAN:C305(<>OTR_Initialised_b)
	C_LONGINT:C283(<>OTR_Options_i)
	
	// The objects
	ARRAY BOOLEAN:C223(<>OTR_InUse_ab; 0)
	ARRAY OBJECT:C1221(<>OTR_Objects_ao; 0)
	
	Compiler_OTrSortInterprocess  // These are the arrays used in the sorting routines
	
End if 


If (Not:C34(OTR_Initialised_b))
	ARRAY TEXT:C222(OTR_callStack_at; 0)
	var OTR_LockCount_i : Integer
	
	Compiler_OTrSortProcess  // These are the arrays used in the sorting routines
	
	
End if 



If (False:C215)
	C_TEXT:C284(OTr_SetErrorHandler; $0)
	C_TEXT:C284(OTr_SetErrorHandler; $1)
	
	C_BOOLEAN:C305(OTr_zResolvePath; $0; $3)
	C_OBJECT:C1216(OTr_zResolvePath; $1)
	C_TEXT:C284(OTr_zResolvePath; $2)
	C_POINTER:C301(OTr_zResolvePath; $4; $5)
	
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
	
	C_LONGINT:C283(OTr_SaveToBlob; $1)
	C_BLOB:C604(OTr_SaveToBlob; $0)
	
	C_LONGINT:C283(OTr_SaveToGZIP; $1)
	C_BOOLEAN:C305(OTr_SaveToGZIP; $2)
	C_BLOB:C604(OTr_SaveToGZIP; $0)
	
	C_TEXT:C284(OTr_LoadFromText; $1)
	C_LONGINT:C283(OTr_LoadFromText; $0)
	
	C_LONGINT:C283(OTr_LoadFromClipboard; $0)
	
	C_TEXT:C284(OTr_LoadFromFile; $1)
	C_LONGINT:C283(OTr_LoadFromFile; $0)
	
	C_BLOB:C604(OTr_LoadFromBlob; $1)
	C_LONGINT:C283(OTr_LoadFromBlob; $0)
	
	C_BLOB:C604(OTr_LoadFromGZIP; $1)
	C_LONGINT:C283(OTr_LoadFromGZIP; $0)
	
	C_TEXT:C284(OTr_SaveToXML; $0)
	C_LONGINT:C283(OTr_SaveToXML; $1)
	C_BOOLEAN:C305(OTr_SaveToXML; $2)
	
	C_LONGINT:C283(OTr_SaveToXMLFile; $1)
	C_TEXT:C284(OTr_SaveToXMLFile; $2)
	C_BOOLEAN:C305(OTr_SaveToXMLFile; $3)
	
	C_TEXT:C284(OTr_LoadFromXML; $1)
	C_LONGINT:C283(OTr_LoadFromXML; $0)
	
	C_TEXT:C284(OTr_LoadFromXMLFile; $1)
	C_LONGINT:C283(OTr_LoadFromXMLFile; $0)
	
	C_BOOLEAN:C305(OTr_IncludeShadowKey; $0; $1)
	
	C_TEXT:C284(OTr_zXMLWriteObject; $1)
	C_OBJECT:C1216(OTr_zXMLWriteObject; $2)
	C_BOOLEAN:C305(OTr_zXMLWriteObject; $3)
	
	C_OBJECT:C1216(OTr_zXMLReadObject; $0)
	C_TEXT:C284(OTr_zXMLReadObject; $1)
	
	C_TEXT:C284(OTr_SaveToXMLSAX; $0)
	C_LONGINT:C283(OTr_SaveToXMLSAX; $1)
	C_BOOLEAN:C305(OTr_SaveToXMLSAX; $2)
	
	C_LONGINT:C283(OTr_SaveToXMLFileSAX; $1)
	C_TEXT:C284(OTr_SaveToXMLFileSAX; $2)
	C_BOOLEAN:C305(OTr_SaveToXMLFileSAX; $3)
	
	C_TIME:C306(OTr_zXMLWriteObjectSAX; $1)
	C_OBJECT:C1216(OTr_zXMLWriteObjectSAX; $2)
	C_BOOLEAN:C305(OTr_zXMLWriteObjectSAX; $3)
	
	C_LONGINT:C283(OTr_SetOptions; $1)
	
	C_LONGINT:C283(OTr_Copy; $0)
	C_LONGINT:C283(OTr_Copy; $1)
	
	C_LONGINT:C283(OTr_CompiledApplication; $0)
	
	C_LONGINT:C283(OTr_GetOptions; $0)
	
	C_BOOLEAN:C305(OTr_zIsValidHandle; $0)
	C_LONGINT:C283(OTr_zIsValidHandle; $1)
	
	C_LONGINT:C283(OTr_New; $0)
	
	C_LONGINT:C283(OTr_Clear; $1)
	
	C_BOOLEAN:C305(OTr_zError; $0)
	C_TEXT:C284(OTr_zError; $1; $2)
	
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
	
	C_LONGINT:C283(OTr_zMapType; $0)
	C_OBJECT:C1216(OTr_zMapType; $1)
	C_TEXT:C284(OTr_zMapType; $2)
	
	
	C_LONGINT:C283(OTr_Register; $0)
	C_TEXT:C284(OTr_Register; $1)
	
	C_TEXT:C284(OTr_LogLevel; $0; $1)
	C_BOOLEAN:C305(OTr_LogLevel; $2)
	
	C_LONGINT:C283(OTr; $0)
	
	C_POINTER:C301(OTr_GetHandleList; $1)
	C_LONGINT:C283(OTr_GetActiveHandleCount; $0)
	
	C_BOOLEAN:C305(OTr_uEqualBLOBs; $0)
	C_BLOB:C604(OTr_uEqualBLOBs; $1; $2)
	
	C_BOOLEAN:C305(OTr_uEqualStrings; $0)
	C_TEXT:C284(OTr_uEqualStrings; $1; $2)
	
	C_BOOLEAN:C305(OTr_uEqualPictures; $0)
	C_PICTURE:C286(OTr_uEqualPictures; $1; $2)
	
	C_OBJECT:C1216(OTr_uEqualObjects; $1; $2)
	C_BOOLEAN:C305(OTr_uEqualObjects; $0)
	
	C_LONGINT:C283(OTr_PutArray; $1)
	C_TEXT:C284(OTr_PutArray; $2)
	C_POINTER:C301(OTr_PutArray; $3)
	
	C_LONGINT:C283(OTr_PutArrayLong; $1; $3; $4)
	C_TEXT:C284(OTr_PutArrayLong; $2)
	
	C_LONGINT:C283(OTr_GetArrayLong; $0; $1; $3)
	C_TEXT:C284(OTr_GetArrayLong; $2)
	
	C_LONGINT:C283(OTr_PutArrayReal; $1; $3)
	C_TEXT:C284(OTr_PutArrayReal; $2)
	C_REAL:C285(OTr_PutArrayReal; $4)
	
	C_REAL:C285(OTr_GetArrayReal; $0)
	C_LONGINT:C283(OTr_GetArrayReal; $1; $3)
	C_TEXT:C284(OTr_GetArrayReal; $2)
	
	C_LONGINT:C283(OTr_PutArrayString; $1; $3)
	C_TEXT:C284(OTr_PutArrayString; $2; $4)
	
	C_TEXT:C284(OTr_GetArrayString; $0; $2)
	C_LONGINT:C283(OTr_GetArrayString; $1; $3)
	
	C_LONGINT:C283(OTr_PutArrayText; $1; $3)
	C_TEXT:C284(OTr_PutArrayText; $2; $4)
	
	C_TEXT:C284(OTr_GetArrayText; $0; $2)
	C_LONGINT:C283(OTr_GetArrayText; $1; $3)
	
	C_LONGINT:C283(OTr_PutArrayDate; $1; $3)
	C_TEXT:C284(OTr_PutArrayDate; $2)
	C_DATE:C307(OTr_PutArrayDate; $4)
	
	C_DATE:C307(OTr_GetArrayDate; $0)
	C_LONGINT:C283(OTr_GetArrayDate; $1; $3)
	C_TEXT:C284(OTr_GetArrayDate; $2)
	
	C_LONGINT:C283(OTr_PutArrayTime; $1; $3)
	C_TEXT:C284(OTr_PutArrayTime; $2)
	C_TIME:C306(OTr_PutArrayTime; $4)
	
	C_TIME:C306(OTr_GetArrayTime; $0)
	C_LONGINT:C283(OTr_GetArrayTime; $1; $3)
	C_TEXT:C284(OTr_GetArrayTime; $2)
	
	C_LONGINT:C283(OTr_PutArrayBoolean; $1; $3)
	C_TEXT:C284(OTr_PutArrayBoolean; $2)
	C_BOOLEAN:C305(OTr_PutArrayBoolean; $4)
	
	C_LONGINT:C283(OTr_GetArrayBoolean; $0; $1; $3)
	C_TEXT:C284(OTr_GetArrayBoolean; $2)
	
	C_LONGINT:C283(OTr_PutArrayBLOB; $1; $3)
	C_TEXT:C284(OTr_PutArrayBLOB; $2)
	C_BLOB:C604(OTr_PutArrayBLOB; $4)
	
	C_BLOB:C604(OTr_GetArrayBLOB; $0)
	C_LONGINT:C283(OTr_GetArrayBLOB; $1; $3)
	C_TEXT:C284(OTr_GetArrayBLOB; $2)
	
	C_LONGINT:C283(OTr_PutBLOB; $1)
	C_TEXT:C284(OTr_PutBLOB; $2)
	C_BLOB:C604(OTr_PutBLOB; $3)
	
	C_LONGINT:C283(OTr_GetBLOB; $1)
	C_TEXT:C284(OTr_GetBLOB; $2)
	C_POINTER:C301(OTr_GetBLOB; $3)
	
	C_BLOB:C604(OTr_GetNewBLOB; $0)
	C_LONGINT:C283(OTr_GetNewBLOB; $1)
	C_TEXT:C284(OTr_GetNewBLOB; $2)
	
	C_LONGINT:C283(OTr_PutArrayPicture; $1; $3)
	C_TEXT:C284(OTr_PutArrayPicture; $2)
	C_PICTURE:C286(OTr_PutArrayPicture; $4)
	
	C_PICTURE:C286(OTr_GetArrayPicture; $0)
	C_LONGINT:C283(OTr_GetArrayPicture; $1; $3)
	C_TEXT:C284(OTr_GetArrayPicture; $2)
	
	C_LONGINT:C283(OTr_PutPicture; $1)
	C_TEXT:C284(OTr_PutPicture; $2)
	C_PICTURE:C286(OTr_PutPicture; $3)  // $inValue_pic
	
	C_PICTURE:C286(OTr_GetPicture; $0)  // $result_pic
	C_LONGINT:C283(OTr_GetPicture; $1)
	C_TEXT:C284(OTr_GetPicture; $2)
	
	C_LONGINT:C283(OTr_PutArrayPointer; $1; $3)
	C_TEXT:C284(OTr_PutArrayPointer; $2)
	C_POINTER:C301(OTr_PutArrayPointer; $4)
	
	C_POINTER:C301(OTr_GetArrayPointer; $0)
	C_LONGINT:C283(OTr_GetArrayPointer; $1; $3)
	C_TEXT:C284(OTr_GetArrayPointer; $2)
	
	C_VARIANT:C1683(OTr_u_AccessArrayElement; $0; $5)
	C_LONGINT:C283(OTr_u_AccessArrayElement; $1; $3; $4)
	C_TEXT:C284(OTr_u_AccessArrayElement; $2)
	
	C_LONGINT:C283(OTr_GetArrayLong; $0; $1; $3)
	C_TEXT:C284(OTr_GetArrayLong; $2)
	
	C_LONGINT:C283(OTr_PutArrayLong; $1; $3; $4)
	C_TEXT:C284(OTr_PutArrayLong; $2)
	
	C_REAL:C285(OTr_GetArrayReal; $0)
	C_LONGINT:C283(OTr_GetArrayReal; $1; $3)
	C_TEXT:C284(OTr_GetArrayReal; $2)
	
	C_LONGINT:C283(OTr_PutArrayReal; $1; $3)
	C_TEXT:C284(OTr_PutArrayReal; $2)
	C_REAL:C285(OTr_PutArrayReal; $4)
	
	C_TEXT:C284(OTr_GetArrayString; $0; $2)
	C_LONGINT:C283(OTr_GetArrayString; $1; $3)
	
	C_LONGINT:C283(OTr_PutArrayString; $1; $3)
	C_TEXT:C284(OTr_PutArrayString; $2; $4)
	
	C_TEXT:C284(OTr_GetArrayText; $0; $2)
	C_LONGINT:C283(OTr_GetArrayText; $1; $3)
	
	C_LONGINT:C283(OTr_PutArrayText; $1; $3)
	C_TEXT:C284(OTr_PutArrayText; $2; $4)
	
	C_DATE:C307(OTr_GetArrayDate; $0)
	C_LONGINT:C283(OTr_GetArrayDate; $1; $3)
	C_TEXT:C284(OTr_GetArrayDate; $2)
	
	C_LONGINT:C283(OTr_PutArrayDate; $1; $3)
	C_TEXT:C284(OTr_PutArrayDate; $2)
	C_DATE:C307(OTr_PutArrayDate; $4)
	
	C_TIME:C306(OTr_GetArrayTime; $0)
	C_LONGINT:C283(OTr_GetArrayTime; $1; $3)
	C_TEXT:C284(OTr_GetArrayTime; $2)
	
	C_LONGINT:C283(OTr_PutArrayTime; $1; $3)
	C_TEXT:C284(OTr_PutArrayTime; $2)
	C_TIME:C306(OTr_PutArrayTime; $4)
	
	C_LONGINT:C283(OTr_GetArrayBoolean; $0; $1; $3)
	C_TEXT:C284(OTr_GetArrayBoolean; $2)
	
	C_LONGINT:C283(OTr_PutArrayBoolean; $1; $3)
	C_TEXT:C284(OTr_PutArrayBoolean; $2)
	C_BOOLEAN:C305(OTr_PutArrayBoolean; $4)
	
	C_BLOB:C604(OTr_GetArrayBLOB; $0)
	C_LONGINT:C283(OTr_GetArrayBLOB; $1; $3)
	C_TEXT:C284(OTr_GetArrayBLOB; $2)
	
	C_LONGINT:C283(OTr_PutArrayBLOB; $1; $3)
	C_TEXT:C284(OTr_PutArrayBLOB; $2)
	C_BLOB:C604(OTr_PutArrayBLOB; $4)
	
	C_PICTURE:C286(OTr_GetArrayPicture; $0)
	C_LONGINT:C283(OTr_GetArrayPicture; $1; $3)
	C_TEXT:C284(OTr_GetArrayPicture; $2)
	
	C_LONGINT:C283(OTr_PutArrayPicture; $1; $3)
	C_TEXT:C284(OTr_PutArrayPicture; $2)
	C_PICTURE:C286(OTr_PutArrayPicture; $4)
	
	C_POINTER:C301(OTr_GetArrayPointer; $0)
	C_LONGINT:C283(OTr_GetArrayPointer; $1; $3)
	C_TEXT:C284(OTr_GetArrayPointer; $2)
	
	C_LONGINT:C283(OTr_PutArrayPointer; $1; $3)
	C_TEXT:C284(OTr_PutArrayPointer; $2)
	C_POINTER:C301(OTr_PutArrayPointer; $4)
	
	C_LONGINT:C283(OTr_PutPointer; $1)
	C_TEXT:C284(OTr_PutPointer; $2)
	C_POINTER:C301(OTr_PutPointer; $3)
	
	C_LONGINT:C283(OTr_GetPointer; $1)
	C_TEXT:C284(OTr_GetPointer; $2)
	C_POINTER:C301(OTr_GetPointer; $3)
	
	C_LONGINT:C283(OTr_SortArrays; $1)
	C_TEXT:C284(OTr_SortArrays; $2; $3; $4; $5; $6; $7; $8; $9; $10; $11; $12; $13; $14; $15)
	
	C_BOOLEAN:C305(OTr_zSortValidatePair; $0)
	C_OBJECT:C1216(OTr_zSortValidatePair; $1)
	
	C_POINTER:C301(OTr_zSortSlotPointer; $0)
	C_LONGINT:C283(OTr_zSortSlotPointer; $1; $2)
	
	C_LONGINT:C283(OTr_zSortFillSlot; $1; $3)
	C_OBJECT:C1216(OTr_zSortFillSlot; $2)
	
	
	C_TIME:C306(OTr_uTimeToText; $1)
	C_TEXT:C284(OTr_uTimeToText; $0)
	
	C_TEXT:C284(OTr_uTextToTime; $1)
	C_TIME:C306(OTr_uTextToTime; $0)
	
	C_DATE:C307(OTr_uDateToText; $1)
	C_TEXT:C284(OTr_uDateToText; $0)
	
	C_TEXT:C284(OTr_uTextToDate; $1)
	C_DATE:C307(OTr_uTextToDate; $0)
	
	C_BOOLEAN:C305(OTr_uNativeDateInObject; $0)
	
	C_TEXT:C284(OTr_SetDateMode; $1; $0)
	
	C_POINTER:C301(OTr_uPointerToText; $1)
	C_TEXT:C284(OTr_uPointerToText; $0)
	
	C_TEXT:C284(OTr_uTextToPointer; $1)
	C_POINTER:C301(OTr_uTextToPointer; $0)
	
	C_LONGINT:C283(OTr_SizeOfArray; $0; $1)
	C_TEXT:C284(OTr_SizeOfArray; $2)
	
	C_LONGINT:C283(OTr_ResizeArray; $1; $3)
	C_TEXT:C284(OTr_ResizeArray; $2)
	
	C_LONGINT:C283(OTr_DeleteElement; $1; $3; $4)
	C_TEXT:C284(OTr_DeleteElement; $2)
	
	C_LONGINT:C283(OTr_InsertElement; $1; $3; $4)
	C_TEXT:C284(OTr_InsertElement; $2)
	
	C_OBJECT:C1216(OTr_zArrayFromObject; $1)
	C_POINTER:C301(OTr_zArrayFromObject; $2)
	
	C_LONGINT:C283(OTr_zArrayType; $0)
	C_OBJECT:C1216(OTr_zArrayType; $1)
	
	C_TEXT:C284(OTr_zShadowKey; $0; $1)
	
	C_BOOLEAN:C305(OTr_zIsShadowKey; $0)
	C_TEXT:C284(OTr_zIsShadowKey; $1)
	
	C_LONGINT:C283(OTr_ArrayType; $0; $1)
	C_TEXT:C284(OTr_ArrayType; $2)
	
	C_LONGINT:C283(OTr_GetArray; $1)
	C_TEXT:C284(OTr_GetArray; $2)
	C_POINTER:C301(OTr_GetArray; $3)
	
	C_BLOB:C604(OTr_uBlobToText; $1)
	C_TEXT:C284(OTr_uBlobToText; $0)
	
	C_TEXT:C284(OTr_uTextToBlob; $1)
	C_BLOB:C604(OTr_uTextToBlob; $0)
	
	C_TEXT:C284(OTr_FindInArray; $2; $3)
	C_LONGINT:C283(OTr_FindInArray; $1; $0; $4)
	
	C_LONGINT:C283(OTr_uNewValueForEmbeddedType; $1)
	C_VARIANT:C1683(OTr_uNewValueForEmbeddedType; $0)
	
	C_LONGINT:C283(OTr_zSetOK; $1; $0)
	
	C_TEXT:C284(OTr_z_LogDirectory; $0)
	C_LONGINT:C283(OTr_zLogLevelToInt; $0)
	C_TEXT:C284(OTr_zLogLevelToInt; $1)
	C_TEXT:C284(OTr_zLogFileName; $0)
	OTr_zLogShutdown
	C_TEXT:C284(OTr_zLogWrite; $1; $2; $3)
	C_TEXT:C284(OTr_zLogGetCallStack; $0; $1)
	C_TEXT:C284(OTr_zAddToCallStack; $1)
	C_TEXT:C284(OTr_zRemoveFromCallStack; $1)
	
	C_LONGINT:C283(OTr_PutRecord; $1; $3)
	C_TEXT:C284(OTr_PutRecord; $2)
	
	C_LONGINT:C283(OTr_GetRecord; $1; $3)
	C_TEXT:C284(OTr_GetRecord; $2)
	
	C_LONGINT:C283(OTr_GetRecordTable; $0; $1)
	C_TEXT:C284(OTr_GetRecordTable; $2)
	
	C_LONGINT:C283(OTr_PutVariable; $1)
	C_TEXT:C284(OTr_PutVariable; $2)
	C_POINTER:C301(OTr_PutVariable; $3)
	
	C_LONGINT:C283(OTr_GetVariable; $1)
	C_TEXT:C284(OTr_GetVariable; $2)
	C_POINTER:C301(OTr_GetVariable; $3)
	
	C_LONGINT:C283(OTr_uMapType; $1; $2; $0)
	
	C_LONGINT:C283(OTr_ObjectToBLOB; $1; $3)
	C_POINTER:C301(OTr_ObjectToBLOB; $2)
	
	C_LONGINT:C283(OTr_ObjectToNewBLOB; $1)
	C_BLOB:C604(OTr_ObjectToNewBLOB; $0)
	
	C_BLOB:C604(OTr_BLOBToObject; $1)
	C_LONGINT:C283(OTr_BLOBToObject; $0)
	
	C_PICTURE:C286(OTr_z_Wombat; $0)
	C_PICTURE:C286(OTr_z_Koala; $0)
	
	
	
	// Phase 10 sub-methods
	C_BOOLEAN:C305(____Test_Phase_10; $1)
	C_LONGINT:C283(____Test_Phase_10_OTr; $1)
	C_LONGINT:C283(____Test_Phase_10_OT; $1)
	
	// Phase 10a sub-methods
	C_BOOLEAN:C305(____Test_Phase_10a; $1)
	C_LONGINT:C283(____Test_Phase_10a_OTr; $1)
	C_LONGINT:C283(____Test_Phase_10a_OT; $1)
	
	// Phase 10b sub-methods
	C_BOOLEAN:C305(____Test_Phase_10b; $1)
	C_LONGINT:C283(____Test_Phase_10b_OTr; $1)
	C_LONGINT:C283(____Test_Phase_10b_OT; $1)
	
	// Phase 10c sub-methods
	C_BOOLEAN:C305(____Test_Phase_10c; $1)
	C_LONGINT:C283(____Test_Phase_10c_OTr; $1)
	C_LONGINT:C283(____Test_Phase_10c_OT; $1)
	
	// Phase 15 sub-methods
	C_BOOLEAN:C305(____Test_Phase_15; $1)
	C_LONGINT:C283(____Test_Phase_15_OTr; $1)
	C_LONGINT:C283(____Test_Phase_15_OT; $1)
	
	
	C_TEXT:C284(OTr_z_timestampLocal; $1; $0)
	
	C_TEXT:C284(OTr_Info; $1; $0)
	
	C_TEXT:C284(OTr_z_Get4DVersion; $0)
	
	C_TEXT:C284(Is a method; $1)
	C_BOOLEAN:C305(Is a method; $0)
End if 
