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
	var OTr_DummyVariableForTests_t : Text
	
	ARRAY LONGINT:C221(OTr_LongArrayForTests_ai; 0)
	ARRAY TEXT:C222(OTr_TextArrayForTests_at; 0)
	
	Compiler_OTrSortProcess  // These are the arrays used in the sorting routines
	
	
End if 



If (False:C215)
	
	C_BOOLEAN:C305(OTr_z_PluginShouldWork; $0)
	
	C_BOOLEAN:C305(OTr_z_Comment_Uncomment_OT_Code; $1)
	C_TEXT:C284(OTr_SetErrorHandler; $0)
	C_TEXT:C284(OTr_SetErrorHandler; $1)
	
	C_BOOLEAN:C305(OTr_z_ResolvePath; $0; $3)
	C_OBJECT:C1216(OTr_z_ResolvePath; $1)
	C_TEXT:C284(OTr_z_ResolvePath; $2)
	C_POINTER:C301(OTr_z_ResolvePath; $4; $5)
	
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
	
	C_TEXT:C284(OTr_z_XMLWriteObject; $1)
	C_OBJECT:C1216(OTr_z_XMLWriteObject; $2)
	C_BOOLEAN:C305(OTr_z_XMLWriteObject; $3)
	
	C_OBJECT:C1216(OTr_z_XMLReadObject; $0)
	C_TEXT:C284(OTr_z_XMLReadObject; $1)
	
	C_TEXT:C284(OTr_SaveToXMLSAX; $0)
	C_LONGINT:C283(OTr_SaveToXMLSAX; $1)
	C_BOOLEAN:C305(OTr_SaveToXMLSAX; $2)
	
	C_LONGINT:C283(OTr_SaveToXMLFileSAX; $1)
	C_TEXT:C284(OTr_SaveToXMLFileSAX; $2)
	C_BOOLEAN:C305(OTr_SaveToXMLFileSAX; $3)
	
	C_TIME:C306(OTr_z_XMLWriteObjectSAX; $1)
	C_OBJECT:C1216(OTr_z_XMLWriteObjectSAX; $2)
	C_BOOLEAN:C305(OTr_z_XMLWriteObjectSAX; $3)
	
	C_LONGINT:C283(OTr_SetOptions; $1)
	
	C_LONGINT:C283(OTr_Copy; $0)
	C_LONGINT:C283(OTr_Copy; $1)
	
	C_LONGINT:C283(OTr_CompiledApplication; $0)
	
	C_LONGINT:C283(OTr_GetOptions; $0)
	
	C_BOOLEAN:C305(OTr_z_IsValidHandle; $0)
	C_LONGINT:C283(OTr_z_IsValidHandle; $1)
	
	C_LONGINT:C283(OTr_New; $0)
	
	C_LONGINT:C283(OTr_Clear; $1)
	
	C_BOOLEAN:C305(OTr_z_Error; $0)
	C_TEXT:C284(OTr_z_Error; $1; $2)
	
	C_TEXT:C284(OTr_Info; $0)
	
	C_LONGINT:C283(OTr_IsObject; $0)
	C_LONGINT:C283(OTr_IsObject; $1)
	
	C_LONGINT:C283(OTr_ItemCount; $0; $1)
	C_TEXT:C284(OTr_ItemCount; $2)
	
	C_LONGINT:C283(OTr_ObjectSize; $0; $1)
	
	C_LONGINT:C283(OTr_ItemExists; $0; $1)
	C_TEXT:C284(OTr_ItemExists; $2)
	
	C_LONGINT:C283(OTr_ItemType; $0; $1)
	C_TEXT:C284(OTr_ItemType; $2)
	C_BOOLEAN:C305(OTr_ItemType; $3)
	
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
	
	C_LONGINT:C283(OTr_z_MapType; $0)
	C_OBJECT:C1216(OTr_z_MapType; $1)
	C_TEXT:C284(OTr_z_MapType; $2)
	
	
	C_LONGINT:C283(OTr_Register; $0)
	C_TEXT:C284(OTr_Register; $1)
	
	C_TEXT:C284(OTr_LogLevel; $0; $1)
	C_BOOLEAN:C305(OTr_LogLevel; $2)
	
	C_LONGINT:C283(OTr; $0)
	
	C_POINTER:C301(OTr_GetHandleList; $1)
	C_LONGINT:C283(OTr_GetActiveHandleCount; $0)
	
	C_BOOLEAN:C305(OTr_u_EqualBLOBs; $0)
	C_BLOB:C604(OTr_u_EqualBLOBs; $1; $2)
	
	C_BOOLEAN:C305(OTr_u_EqualStrings; $0)
	C_TEXT:C284(OTr_u_EqualStrings; $1; $2)
	
	C_BOOLEAN:C305(OTr_u_EqualPictures; $0)
	C_PICTURE:C286(OTr_u_EqualPictures; $1; $2)
	
	C_OBJECT:C1216(OTr_u_EqualObjects; $1; $2)
	C_BOOLEAN:C305(OTr_u_EqualObjects; $0)
	
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
	C_TEXT:C284(OTr_SortArrays; ${2})
	
	C_BOOLEAN:C305(OTr_z_SortValidatePair; $0)
	C_OBJECT:C1216(OTr_z_SortValidatePair; $1)
	
	C_POINTER:C301(OTr_z_SortSlotPointer; $0)
	C_LONGINT:C283(OTr_z_SortSlotPointer; $1; $2)
	
	C_LONGINT:C283(OTr_z_SortFillSlot; $1; $3)
	C_OBJECT:C1216(OTr_z_SortFillSlot; $2)
	
	
	C_TIME:C306(OTr_u_TimeToText; $1)
	C_TEXT:C284(OTr_u_TimeToText; $0)
	
	C_TEXT:C284(OTr_u_TextToTime; $1)
	C_TIME:C306(OTr_u_TextToTime; $0)
	
	C_DATE:C307(OTr_u_DateToText; $1)
	C_TEXT:C284(OTr_u_DateToText; $0)
	
	C_TEXT:C284(OTr_u_TextToDate; $1)
	C_DATE:C307(OTr_u_TextToDate; $0)
	
	C_BOOLEAN:C305(OTr_u_NativeDateInObject; $0)
	
	C_TEXT:C284(OTr_SetDateMode; $1; $0)
	
	C_POINTER:C301(OTr_u_PointerToText; $1)
	C_TEXT:C284(OTr_u_PointerToText; $0)
	
	C_TEXT:C284(OTr_u_TextToPointer; $1)
	C_POINTER:C301(OTr_u_TextToPointer; $0)
	
	C_LONGINT:C283(OTr_SizeOfArray; $0; $1)
	C_TEXT:C284(OTr_SizeOfArray; $2)
	
	C_LONGINT:C283(OTr_ResizeArray; $1; $3)
	C_TEXT:C284(OTr_ResizeArray; $2)
	
	C_LONGINT:C283(OTr_DeleteElement; $1; $3; $4)
	C_TEXT:C284(OTr_DeleteElement; $2)
	
	C_LONGINT:C283(OTr_InsertElement; $1; $3; $4)
	C_TEXT:C284(OTr_InsertElement; $2)
	
	C_OBJECT:C1216(OTr_z_ArrayFromObject; $1)
	C_POINTER:C301(OTr_z_ArrayFromObject; $2)
	
	C_LONGINT:C283(OTr_z_ArrayType; $0)
	C_OBJECT:C1216(OTr_z_ArrayType; $1)
	
	C_TEXT:C284(OTr_z_ShadowKey; $0; $1)
	
	C_BOOLEAN:C305(OTr_z_IsShadowKey; $0)
	C_TEXT:C284(OTr_z_IsShadowKey; $1)
	
	C_LONGINT:C283(OTr_ArrayType; $0; $1)
	C_TEXT:C284(OTr_ArrayType; $2)
	
	C_LONGINT:C283(OTr_GetArray; $1)
	C_TEXT:C284(OTr_GetArray; $2)
	C_POINTER:C301(OTr_GetArray; $3)
	
	C_BLOB:C604(OTr_u_BlobToText; $1)
	C_TEXT:C284(OTr_u_BlobToText; $0)
	
	C_TEXT:C284(OTr_u_TextToBlob; $1)
	C_BLOB:C604(OTr_u_TextToBlob; $0)
	
	C_TEXT:C284(OTr_FindInArray; $2; $3)
	C_LONGINT:C283(OTr_FindInArray; $1; $0; $4)
	
	C_LONGINT:C283(OTr_u_NewValueForEmbeddedType; $1)
	C_VARIANT:C1683(OTr_u_NewValueForEmbeddedType; $0)
	
	C_LONGINT:C283(OTr_z_SetOK; $1; $0)
	
	C_TEXT:C284(OTr_z_LogDirectory; $0)
	C_LONGINT:C283(OTr_z_LogLevelToInt; $0)
	C_TEXT:C284(OTr_z_LogLevelToInt; $1)
	C_TEXT:C284(OTr_z_LogFileName; $0)
	OTr_z_LogShutdown
	C_TEXT:C284(OTr_z_LogWrite; $1; $2; $3)
	C_TEXT:C284(OTr_z_LogGetCallStack; $0; $1)
	C_TEXT:C284(OTr_z_AddToCallStack; $1)
	C_TEXT:C284(OTr_z_RemoveFromCallStack; $1)
	
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
	
	C_LONGINT:C283(OTr_u_MapType; $1; $2; $0)
	
	C_LONGINT:C283(OTr_ObjectToBLOB; $1; $3)
	C_POINTER:C301(OTr_ObjectToBLOB; $2)
	
	C_LONGINT:C283(OTr_ObjectToNewBLOB; $1)
	C_BLOB:C604(OTr_ObjectToNewBLOB; $0)
	
	C_BLOB:C604(OTr_BLOBToObject; $1)
	C_LONGINT:C283(OTr_BLOBToObject; $0)
	
	C_BLOB:C604(OTr_ImportLegacyBlob; $1)
	C_LONGINT:C283(OTr_ImportLegacyBlob; $0)
	
	C_BLOB:C604(OTr_x_OTBlobIsObject; $1)
	C_BOOLEAN:C305(OTr_x_OTBlobIsObject; $0)
	
	C_BLOB:C604(OTr_x_OTBlobToObject; $1)
	C_OBJECT:C1216(OTr_x_OTBlobToObject; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadObjectItems; $1)
	C_POINTER:C301(OTr_x_OTBlobReadObjectItems; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadObjectItems; $3)
	C_OBJECT:C1216(OTr_x_OTBlobReadObjectItems; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadArray; $1)
	C_POINTER:C301(OTr_x_OTBlobReadArray; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadArray; $3)
	C_OBJECT:C1216(OTr_x_OTBlobReadArray; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadUInt16BE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadUInt16BE; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadUInt16BE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadInt16BE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadInt16BE; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadInt16BE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadUTF16BE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadUTF16BE; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadUTF16BE; $3)
	C_BOOLEAN:C305(OTr_x_OTBlobReadUTF16BE; $4)
	C_TEXT:C284(OTr_x_OTBlobReadUTF16BE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadSerializedText; $1)
	C_POINTER:C301(OTr_x_OTBlobReadSerializedText; $2)
	C_BOOLEAN:C305(OTr_x_OTBlobReadSerializedText; $3)
	C_TEXT:C284(OTr_x_OTBlobReadSerializedText; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadUInt16LE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadUInt16LE; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadUInt16LE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadUInt32BE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadUInt32BE; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadUInt32BE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadUInt32LE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadUInt32LE; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadUInt32LE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadInt32BE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadInt32BE; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadInt32BE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadBlobPayload; $1)
	C_POINTER:C301(OTr_x_OTBlobReadBlobPayload; $2; $3)
	C_BOOLEAN:C305(OTr_x_OTBlobReadBlobPayload; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadRealBE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadRealBE; $2)
	C_REAL:C285(OTr_x_OTBlobReadRealBE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadRealLE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadRealLE; $2)
	C_REAL:C285(OTr_x_OTBlobReadRealLE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadInt32LE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadInt32LE; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadInt32LE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadWrappedPicture; $1)
	C_LONGINT:C283(OTr_x_OTBlobReadWrappedPicture; $2)
	C_POINTER:C301(OTr_x_OTBlobReadWrappedPicture; $3; $4)
	C_BOOLEAN:C305(OTr_x_OTBlobReadWrappedPicture; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadUTF16LE; $1)
	C_POINTER:C301(OTr_x_OTBlobReadUTF16LE; $2)
	C_LONGINT:C283(OTr_x_OTBlobReadUTF16LE; $3)
	C_BOOLEAN:C305(OTr_x_OTBlobReadUTF16LE; $4)
	C_TEXT:C284(OTr_x_OTBlobReadUTF16LE; $0)
	
	C_BLOB:C604(OTr_x_OTBlobReadRecord; $1)
	C_POINTER:C301(OTr_x_OTBlobReadRecord; $2)
	C_OBJECT:C1216(OTr_x_OTBlobReadRecord; $0)
	
	C_PICTURE:C286(OTr_z_Wombat; $0)
	C_PICTURE:C286(OTr_z_Koala; $0)
	C_PICTURE:C286(OTr_z_Echidna; $0)
	
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
	
	// Phase 16 OT BLOB compatibility tests
	C_BOOLEAN:C305(____Make_Phase16_OTBlobFixtures; $1)
	C_BOOLEAN:C305(____Test_Phase_16_OTBlob; $1)
	C_BOOLEAN:C305(____Test_Phase_16a_OTBlobValues; $1)
	C_BOOLEAN:C305(____Test_Phase_16b_OTBlobDeep; $1)
	C_BLOB:C604(____Test_Phase_16_OTBlob_Probe; $1)
	C_TEXT:C284(____Test_Phase_16_OTBlob_Probe; $2)
	C_TEXT:C284(____Test_Phase_16_OTBlob_Probe; $0)
	
	C_BOOLEAN:C305(____Test_OTr_Master; $1)
	C_OBJECT:C1216(____Test_OTr_Master; $0)
	
	C_TEXT:C284(OTr_z_timestampLocal; $1; $0)
	
	C_TEXT:C284(OTr_Info; $1; $0)
	
	C_TEXT:C284(OTr_z_Get4DVersion; $0)
	
	C_TEXT:C284(Is a method; $1)
	C_BOOLEAN:C305(Is a method; $0)

	// Codex live testing bridge
	C_TEXT:C284(OTr_w_Run; $1; $2)
	C_OBJECT:C1216(OTr_w_Run; $0)
	C_OBJECT:C1216(util_compileProject; $0)
	C_OBJECT:C1216(OTr_w_CompileResultForJSON; $0; $1)
	C_TEXT:C284(OTr_w_IsLocalRequest; $1)
	C_BOOLEAN:C305(OTr_w_IsLocalRequest; $0)
	C_OBJECT:C1216(OTr_w_RunCompileOnMain; $1)
	C_OBJECT:C1216(OTr_w_RunUnitTestWorker; $1)
	C_OBJECT:C1216(OTr_w_Phase16Diag; $1)
	C_OBJECT:C1216(OTr_w_GuyBlobExport; $1)
End if 
