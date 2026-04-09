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
	
End if 



If (False:C215)
	C_TEXT:C284(OT SetErrorHandler; $0)
	C_TEXT:C284(OT SetErrorHandler; $1)
	
	C_BOOLEAN:C305(OTr_zResolvePath; $0; $3)
	C_OBJECT:C1216(OTr_zResolvePath; $1)
	C_TEXT:C284(OTr_zResolvePath; $2)
	C_POINTER:C301(OTr_zResolvePath; $4; $5)
	
	C_LONGINT:C283(OT PutLong; $1; $3)
	C_TEXT:C284(OT PutLong; $2)
	
	C_LONGINT:C283(OT GetLong; $0; $1)
	C_TEXT:C284(OT GetLong; $2)
	
	C_LONGINT:C283(OT PutReal; $1)
	C_TEXT:C284(OT PutReal; $2)
	C_REAL:C285(OT PutReal; $3)
	C_REAL:C285(OT GetReal; $0)
	
	C_LONGINT:C283(OT GetReal; $1)
	C_TEXT:C284(OT GetReal; $2)
	
	C_LONGINT:C283(OT PutString; $1)
	C_TEXT:C284(OT PutString; $2; $3)
	
	C_TEXT:C284(OT GetString; $0; $2)
	C_LONGINT:C283(OT GetString; $1)
	
	C_LONGINT:C283(OT PutText; $1)
	C_TEXT:C284(OT PutText; $2; $3)
	
	C_TEXT:C284(OT GetText; $0; $2)
	C_LONGINT:C283(OT GetText; $1)
	
	C_LONGINT:C283(OT PutDate; $1)
	C_TEXT:C284(OT PutDate; $2)
	C_DATE:C307(OT PutDate; $3)
	
	C_DATE:C307(OT GetDate; $0)
	C_LONGINT:C283(OT GetDate; $1)
	C_TEXT:C284(OT GetDate; $2)
	
	C_LONGINT:C283(OT PutTime; $1)
	C_TEXT:C284(OT PutTime; $2)
	C_TIME:C306(OT PutTime; $3)
	
	C_TIME:C306(OT GetTime; $0)
	C_LONGINT:C283(OT GetTime; $1)
	C_TEXT:C284(OT GetTime; $2)
	
	C_LONGINT:C283(OT PutBoolean; $1)
	C_TEXT:C284(OT PutBoolean; $2)
	C_BOOLEAN:C305(OT PutBoolean; $3)
	
	C_LONGINT:C283(OT GetBoolean; $0; $1)
	C_TEXT:C284(OT GetBoolean; $2)
	
	C_LONGINT:C283(OT PutObject; $1; $3)
	C_TEXT:C284(OT PutObject; $2)
	
	C_LONGINT:C283(OT GetObject; $0; $1)
	C_TEXT:C284(OT GetObject; $2)
	
	C_TEXT:C284(OT SaveToText; $0)
	C_LONGINT:C283(OT SaveToText; $1)
	C_BOOLEAN:C305(OT SaveToText; $2)
	
	C_LONGINT:C283(OT SaveToFile; $1)
	C_TEXT:C284(OT SaveToFile; $2)
	C_BOOLEAN:C305(OT SaveToFile; $3)
	
	C_LONGINT:C283(OT SaveToClipboard; $1)
	C_BOOLEAN:C305(OT SaveToClipboard; $2)
	
	C_LONGINT:C283(OT SaveToBlob; $1)
	C_BLOB:C604(OT SaveToBlob; $0)
	
	C_LONGINT:C283(OT SaveToGZIP; $1)
	C_BOOLEAN:C305(OT SaveToGZIP; $2)
	C_BLOB:C604(OT SaveToGZIP; $0)
	
	C_TEXT:C284(OT LoadFromText; $1)
	C_LONGINT:C283(OT LoadFromText; $0)
	
	C_LONGINT:C283(OT LoadFromClipboard; $0)
	
	C_TEXT:C284(OT LoadFromFile; $1)
	C_LONGINT:C283(OT LoadFromFile; $0)
	
	C_BLOB:C604(OT LoadFromBlob; $1)
	C_LONGINT:C283(OT LoadFromBlob; $0)
	
	C_BLOB:C604(OT LoadFromGZIP; $1)
	C_LONGINT:C283(OT LoadFromGZIP; $0)
	
	C_LONGINT:C283(OT SetOptions; $1)
	
	C_LONGINT:C283(OT Copy; $0)
	C_LONGINT:C283(OT Copy; $1)
	
	C_LONGINT:C283(OT CompiledApplication; $0)
	
	C_LONGINT:C283(OT GetOptions; $0)
	
	C_BOOLEAN:C305(OTr_zIsValidHandle; $0)
	C_LONGINT:C283(OTr_zIsValidHandle; $1)
	
	C_LONGINT:C283(OT New; $0)
	
	C_LONGINT:C283(OT Clear; $1)
	
	C_BOOLEAN:C305(OTr_zError; $0)
	C_TEXT:C284(OTr_zError; $1; $2)
	
	C_TEXT:C284(OT GetVersion; $0)
	
	C_LONGINT:C283(OT IsObject; $0)
	C_LONGINT:C283(OT IsObject; $1)
	
	C_LONGINT:C283(OT ItemCount; $0; $1)
	C_TEXT:C284(OT ItemCount; $2)
	
	C_LONGINT:C283(OT ObjectSize; $0; $1)
	
	C_LONGINT:C283(OT ItemExists; $0; $1)
	C_TEXT:C284(OT ItemExists; $2)
	
	C_LONGINT:C283(OT ItemType; $0; $1)
	C_TEXT:C284(OT ItemType; $2)
	
	C_LONGINT:C283(OT IsEmbedded; $0; $1)
	C_TEXT:C284(OT IsEmbedded; $2)
	
	C_TEXT:C284(OT GetAllNamedProperties; $2)
	C_LONGINT:C283(OT GetAllNamedProperties; $1)
	C_POINTER:C301(OT GetAllNamedProperties; $3; $4; $5; $6)
	
	C_LONGINT:C283(OT GetAllProperties; $1)
	C_POINTER:C301(OT GetAllProperties; $2; $3; $4; $5)
	
	C_LONGINT:C283(OT GetItemProperties; $1; $2)
	C_POINTER:C301(OT GetItemProperties; $3; $4; $5; $6)
	
	C_LONGINT:C283(OT GetNamedProperties; $1)
	C_TEXT:C284(OT GetNamedProperties; $2)
	C_POINTER:C301(OT GetNamedProperties; $3; $4; $5; $6)
	
	C_LONGINT:C283(OT CompareItems; $0; $1; $3)
	C_TEXT:C284(OT CompareItems; $2; $4)
	
	C_LONGINT:C283(OT CopyItem; $1; $3)
	C_TEXT:C284(OT CopyItem; $2; $4)
	
	C_LONGINT:C283(OT RenameItem; $1)
	C_TEXT:C284(OT RenameItem; $2; $3)
	
	C_LONGINT:C283(OT DeleteItem; $1)
	C_TEXT:C284(OT DeleteItem; $2)
	
	C_LONGINT:C283(OTr_zMapType; $0)
	C_OBJECT:C1216(OTr_zMapType; $1)
	C_TEXT:C284(OTr_zMapType; $2)
	
	
	C_LONGINT:C283(OT Register; $0)
	C_TEXT:C284(OT Register; $1)
	
	C_TEXT:C284(OT LogLevel; $0; $1)
	C_BOOLEAN:C305(OT LogLevel; $2)
	
	C_LONGINT:C283(OTr; $0)
	
	C_POINTER:C301(OT GetHandleList; $1)
	
	C_BOOLEAN:C305(OTr_uEqualBLOBs; $0)
	C_BLOB:C604(OTr_uEqualBLOBs; $1; $2)
	
	C_BOOLEAN:C305(OTr_uEqualStrings; $0)
	C_TEXT:C284(OTr_uEqualStrings; $1; $2)
	
	C_BOOLEAN:C305(OTr_uEqualPictures; $0)
	C_PICTURE:C286(OTr_uEqualPictures; $1; $2)
	
	C_OBJECT:C1216(OTr_uEqualObjects; $1; $2)
	C_BOOLEAN:C305(OTr_uEqualObjects; $0)
	
	C_LONGINT:C283(OT PutArray; $1)
	C_TEXT:C284(OT PutArray; $2)
	C_POINTER:C301(OT PutArray; $3)
	
	C_LONGINT:C283(OT PutArrayLong; $1; $3; $4)
	C_TEXT:C284(OT PutArrayLong; $2)
	
	C_LONGINT:C283(OT GetArrayLong; $0; $1; $3)
	C_TEXT:C284(OT GetArrayLong; $2)
	
	C_LONGINT:C283(OT PutArrayReal; $1; $3)
	C_TEXT:C284(OT PutArrayReal; $2)
	C_REAL:C285(OT PutArrayReal; $4)
	
	C_REAL:C285(OT GetArrayReal; $0)
	C_LONGINT:C283(OT GetArrayReal; $1; $3)
	C_TEXT:C284(OT GetArrayReal; $2)
	
	C_LONGINT:C283(OT PutArrayString; $1; $3)
	C_TEXT:C284(OT PutArrayString; $2; $4)
	
	C_TEXT:C284(OT GetArrayString; $0; $2)
	C_LONGINT:C283(OT GetArrayString; $1; $3)
	
	C_LONGINT:C283(OT PutArrayText; $1; $3)
	C_TEXT:C284(OT PutArrayText; $2; $4)
	
	C_TEXT:C284(OT GetArrayText; $0; $2)
	C_LONGINT:C283(OT GetArrayText; $1; $3)
	
	C_LONGINT:C283(OT PutArrayDate; $1; $3)
	C_TEXT:C284(OT PutArrayDate; $2)
	C_DATE:C307(OT PutArrayDate; $4)
	
	C_DATE:C307(OT GetArrayDate; $0)
	C_LONGINT:C283(OT GetArrayDate; $1; $3)
	C_TEXT:C284(OT GetArrayDate; $2)
	
	C_LONGINT:C283(OT PutArrayTime; $1; $3)
	C_TEXT:C284(OT PutArrayTime; $2)
	C_TIME:C306(OT PutArrayTime; $4)
	
	C_TIME:C306(OT GetArrayTime; $0)
	C_LONGINT:C283(OT GetArrayTime; $1; $3)
	C_TEXT:C284(OT GetArrayTime; $2)
	
	C_LONGINT:C283(OT PutArrayBoolean; $1; $3)
	C_TEXT:C284(OT PutArrayBoolean; $2)
	C_BOOLEAN:C305(OT PutArrayBoolean; $4)
	
	C_LONGINT:C283(OT GetArrayBoolean; $0; $1; $3)
	C_TEXT:C284(OT GetArrayBoolean; $2)
	
	C_LONGINT:C283(OT PutArrayBLOB; $1; $3)
	C_TEXT:C284(OT PutArrayBLOB; $2)
	C_BLOB:C604(OT PutArrayBLOB; $4)
	
	C_BLOB:C604(OT GetArrayBLOB; $0)
	C_LONGINT:C283(OT GetArrayBLOB; $1; $3)
	C_TEXT:C284(OT GetArrayBLOB; $2)
	
	C_LONGINT:C283(OT PutBLOB; $1)
	C_TEXT:C284(OT PutBLOB; $2)
	C_BLOB:C604(OT PutBLOB; $3)
	
	C_LONGINT:C283(OT GetBLOB; $1)
	C_TEXT:C284(OT GetBLOB; $2)
	C_BLOB:C604(OT GetBLOB; $3)
	
	C_BLOB:C604(OT GetNewBLOB; $0)
	C_LONGINT:C283(OT GetNewBLOB; $1)
	C_TEXT:C284(OT GetNewBLOB; $2)
	
	C_LONGINT:C283(OT PutArrayPicture; $1; $3)
	C_TEXT:C284(OT PutArrayPicture; $2)
	C_PICTURE:C286(OT PutArrayPicture; $4)
	
	C_PICTURE:C286(OT GetArrayPicture; $0)
	C_LONGINT:C283(OT GetArrayPicture; $1; $3)
	C_TEXT:C284(OT GetArrayPicture; $2)
	
	C_LONGINT:C283(OT PutPicture; $1)
	C_TEXT:C284(OT PutPicture; $2)
	C_PICTURE:C286(OT PutPicture; $3)  // $inValue_pic
	
	C_PICTURE:C286(OT GetPicture; $0)  // $result_pic
	C_LONGINT:C283(OT GetPicture; $1)
	C_TEXT:C284(OT GetPicture; $2)
	
	C_LONGINT:C283(OT PutArrayPointer; $1; $3)
	C_TEXT:C284(OT PutArrayPointer; $2)
	C_POINTER:C301(OT PutArrayPointer; $4)
	
	C_POINTER:C301(OT GetArrayPointer; $0)
	C_LONGINT:C283(OT GetArrayPointer; $1; $3)
	C_TEXT:C284(OT GetArrayPointer; $2)
	
	C_VARIANT:C1683(OTr_u_AccessArrayElement; $0; $5)
	C_LONGINT:C283(OTr_u_AccessArrayElement; $1; $3; $4)
	C_TEXT:C284(OTr_u_AccessArrayElement; $2)
	
	C_LONGINT:C283(OT GetArrayLong; $0; $1; $3)
	C_TEXT:C284(OT GetArrayLong; $2)
	
	C_LONGINT:C283(OT PutArrayLong; $1; $3; $4)
	C_TEXT:C284(OT PutArrayLong; $2)
	
	C_REAL:C285(OT GetArrayReal; $0)
	C_LONGINT:C283(OT GetArrayReal; $1; $3)
	C_TEXT:C284(OT GetArrayReal; $2)
	
	C_LONGINT:C283(OT PutArrayReal; $1; $3)
	C_TEXT:C284(OT PutArrayReal; $2)
	C_REAL:C285(OT PutArrayReal; $4)
	
	C_TEXT:C284(OT GetArrayString; $0; $2)
	C_LONGINT:C283(OT GetArrayString; $1; $3)
	
	C_LONGINT:C283(OT PutArrayString; $1; $3)
	C_TEXT:C284(OT PutArrayString; $2; $4)
	
	C_TEXT:C284(OT GetArrayText; $0; $2)
	C_LONGINT:C283(OT GetArrayText; $1; $3)
	
	C_LONGINT:C283(OT PutArrayText; $1; $3)
	C_TEXT:C284(OT PutArrayText; $2; $4)
	
	C_DATE:C307(OT GetArrayDate; $0)
	C_LONGINT:C283(OT GetArrayDate; $1; $3)
	C_TEXT:C284(OT GetArrayDate; $2)
	
	C_LONGINT:C283(OT PutArrayDate; $1; $3)
	C_TEXT:C284(OT PutArrayDate; $2)
	C_DATE:C307(OT PutArrayDate; $4)
	
	C_TIME:C306(OT GetArrayTime; $0)
	C_LONGINT:C283(OT GetArrayTime; $1; $3)
	C_TEXT:C284(OT GetArrayTime; $2)
	
	C_LONGINT:C283(OT PutArrayTime; $1; $3)
	C_TEXT:C284(OT PutArrayTime; $2)
	C_TIME:C306(OT PutArrayTime; $4)
	
	C_LONGINT:C283(OT GetArrayBoolean; $0; $1; $3)
	C_TEXT:C284(OT GetArrayBoolean; $2)
	
	C_LONGINT:C283(OT PutArrayBoolean; $1; $3)
	C_TEXT:C284(OT PutArrayBoolean; $2)
	C_BOOLEAN:C305(OT PutArrayBoolean; $4)
	
	C_BLOB:C604(OT GetArrayBLOB; $0)
	C_LONGINT:C283(OT GetArrayBLOB; $1; $3)
	C_TEXT:C284(OT GetArrayBLOB; $2)
	
	C_LONGINT:C283(OT PutArrayBLOB; $1; $3)
	C_TEXT:C284(OT PutArrayBLOB; $2)
	C_BLOB:C604(OT PutArrayBLOB; $4)
	
	C_PICTURE:C286(OT GetArrayPicture; $0)
	C_LONGINT:C283(OT GetArrayPicture; $1; $3)
	C_TEXT:C284(OT GetArrayPicture; $2)
	
	C_LONGINT:C283(OT PutArrayPicture; $1; $3)
	C_TEXT:C284(OT PutArrayPicture; $2)
	C_PICTURE:C286(OT PutArrayPicture; $4)
	
	C_POINTER:C301(OT GetArrayPointer; $0)
	C_LONGINT:C283(OT GetArrayPointer; $1; $3)
	C_TEXT:C284(OT GetArrayPointer; $2)
	
	C_LONGINT:C283(OT PutArrayPointer; $1; $3)
	C_TEXT:C284(OT PutArrayPointer; $2)
	C_POINTER:C301(OT PutArrayPointer; $4)
	
	C_LONGINT:C283(OT PutPointer; $1)
	C_TEXT:C284(OT PutPointer; $2)
	C_POINTER:C301(OT PutPointer; $3)
	
	C_LONGINT:C283(OT GetPointer; $1)
	C_TEXT:C284(OT GetPointer; $2)
	C_POINTER:C301(OT GetPointer; $3)
	
	C_LONGINT:C283(OT SortArrays; $1)
	C_TEXT:C284(OT SortArrays; $2; $3; $4; $5; $6; $7; $8; $9; $10; $11; $12; $13; $14; $15)
	
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
	
	C_POINTER:C301(OTr_uPointerToText; $1)
	C_TEXT:C284(OTr_uPointerToText; $0)
	
	C_TEXT:C284(OTr_uTextToPointer; $1)
	C_POINTER:C301(OTr_uTextToPointer; $0)
	
	C_LONGINT:C283(OT SizeOfArray; $0; $1)
	C_TEXT:C284(OT SizeOfArray; $2)
	
	C_LONGINT:C283(OT ResizeArray; $1; $3)
	C_TEXT:C284(OT ResizeArray; $2)
	
	C_LONGINT:C283(OT DeleteElement; $1; $3; $4)
	C_TEXT:C284(OT DeleteElement; $2)
	
	C_LONGINT:C283(OT InsertElement; $1; $3; $4)
	C_TEXT:C284(OT InsertElement; $2)
	
	C_OBJECT:C1216(OTr_zArrayFromObject; $1)
	C_POINTER:C301(OTr_zArrayFromObject; $2)
	
	C_LONGINT:C283(OTr_zArrayType; $0)
	C_OBJECT:C1216(OTr_zArrayType; $1)
	
	C_LONGINT:C283(OT ArrayType; $0; $1)
	C_TEXT:C284(OT ArrayType; $2)
	
	C_LONGINT:C283(OT GetArray; $1)
	C_TEXT:C284(OT GetArray; $2)
	C_POINTER:C301(OT GetArray; $3)
	
	C_BLOB:C604(OTr_uBlobToText; $1)
	C_TEXT:C284(OTr_uBlobToText; $0)
	
	C_TEXT:C284(OTr_uTextToBlob; $1)
	C_BLOB:C604(OTr_uTextToBlob; $0)
	
	C_TEXT:C284(OT FindInArray; $2; $3)
	C_LONGINT:C283(OT FindInArray; $1; $0; $4)
	
	C_LONGINT:C283(OTr_uNewValueForEmbeddedType; $1)
	C_VARIANT:C1683(OTr_uNewValueForEmbeddedType; $0)
	
	C_LONGINT:C283(OTr_zSetOK; $1; $0)
	
	C_TEXT:C284(OTr_z_LogDirectory; $0)
	C_LONGINT:C283(OTr_zLogLevelToInt; $0)
	C_TEXT:C284(OTr_zLogLevelToInt; $1)
	C_TEXT:C284(OTr_zLogFileName; $0)
	OTr_zLogShutdown
	C_TEXT:C284(OTr_zLogWrite; $1; $2; $3)
	C_TEXT:C284(OTr_zAddToCallStack; $1)
	C_TEXT:C284(OTr_zRemoveFromCallStack; $1)
	
	C_LONGINT:C283(OT PutRecord; $1; $3)
	C_TEXT:C284(OT PutRecord; $2)
	
	C_LONGINT:C283(OT GetRecord; $1; $3)
	C_TEXT:C284(OT GetRecord; $2)
	
	C_LONGINT:C283(OT GetRecordTable; $0; $1)
	C_TEXT:C284(OT GetRecordTable; $2)
	
	C_LONGINT:C283(OT PutVariable; $1)
	C_TEXT:C284(OT PutVariable; $2)
	C_POINTER:C301(OT PutVariable; $3)
	
	C_LONGINT:C283(OT GetVariable; $1)
	C_TEXT:C284(OT GetVariable; $2)
	C_POINTER:C301(OT GetVariable; $3)
	
	C_LONGINT:C283(OTr_uMapType; $1; $2; $0)
	
	C_LONGINT:C283(OT ObjectToBLOB; $1; $3)
	C_POINTER:C301(OT ObjectToBLOB; $2)
	
	C_LONGINT:C283(OT ObjectToNewBLOB; $1)
	C_BLOB:C604(OT ObjectToNewBLOB; $0)
	
	C_BLOB:C604(OT BLOBToObject; $1)
	C_LONGINT:C283(OT BLOBToObject; $0)
	
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
	
	// Phase 15 sub-methods
	C_BOOLEAN:C305(____Test_Phase_15; $1)
	C_LONGINT:C283(____Test_Phase_15_OTr; $1)
	C_LONGINT:C283(____Test_Phase_15_OT; $1)
	
	
	C_TEXT:C284(OTr_z_timestampLocal; $1; $0)
	
	C_TEXT:C284(OT Info; $1; $0)
End if 
