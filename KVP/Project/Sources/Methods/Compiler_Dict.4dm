//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Compiler_Dict

// Compiler directives for the dictionary module.

// Access: Private

// Created by Rob Laveaux
// ----------------------------------------------------

C_BOOLEAN:C305(<>Dict_Initialised_b)
If (Not:C34(<>Dict_Initialised_b))
	
	ARRAY TEXT:C222(<>Dict_Names_at; 0)  //            Array containing list of dictionary names
	ARRAY LONGINT:C221(<>Dict_RetainCounts_ai; 0)  //  for tracking when to release a dictionary
	
	//                                         Two dimension arrays: each array is one dictionary
	ARRAY TEXT:C222(<>Dict_Keys_at; 0; 0)  //           These are the actual keys
	ARRAY LONGINT:C221(<>Dict_DataTypes_ai; 0; 0)  //   The data types
	ARRAY TEXT:C222(<>Dict_Values_at; 0; 0)  //         The key values (converted to text)
	
	ARRAY PICTURE:C279(<>Dict_PictValues_apic; 0)  //  Pictures will be rarely used so I will not bother with two dimensional array
	ARRAY TEXT:C222(<>Dict_PictIndexSlots_at; 0)  //   To track which slots in the picture array are free
	
	C_LONGINT:C283(<>Dict_LockCount_ai; <>Dict_SequentialCounter_i)
	C_BOOLEAN:C305(<>Dict_CloseDialog_b; <>Dict_FoundationPresent_b; <>Dict_APD_Cleanup_b)
	C_TEXT:C284(<>Dict_StructureName_t; <>Dict_ErrorDetails_t; <>Dict_SemaphoreName_t)
End if 

C_BOOLEAN:C305(Dict_Initialised_b)
If (Not:C34(Dict_Initialised_b))
	C_LONGINT:C283(Dict_APD_ID_i)
	
	
End if 




If (False:C215)
	C_LONGINT:C283(Dict_New; $0)
	C_TEXT:C284(Dict_New; $1)
	
	C_LONGINT:C283(Dict_Release; $1)
	
	C_LONGINT:C283(Dict_SetText; $1)
	C_TEXT:C284(Dict_SetText; $2; $3)
	
	C_TEXT:C284(Dict_GetText; $0; $2)
	C_LONGINT:C283(Dict_GetText; $1)
	
	C_LONGINT:C283(Dict_ID; $0)
	C_TEXT:C284(Dict_ID; $1)
	
	C_BOOLEAN:C305(Dict_IsValid; $0)
	C_LONGINT:C283(Dict_IsValid; $1)
	
	C_BOOLEAN:C305(Dict_HasKey; $0)
	C_LONGINT:C283(Dict_HasKey; $1)
	C_TEXT:C284(Dict_HasKey; $2)
	
	C_LONGINT:C283(Dict_SetLongint; $1; $3)
	C_TEXT:C284(Dict_SetLongint; $2)
	
	C_LONGINT:C283(Dict_SetReal; $1)
	C_TEXT:C284(Dict_SetReal; $2)
	C_REAL:C285(Dict_SetReal; $3)
	
	C_LONGINT:C283(Dict_SetDate; $1)
	C_TEXT:C284(Dict_SetDate; $2)
	C_DATE:C307(Dict_SetDate; $3)
	
	C_LONGINT:C283(Dict_SetTime; $1)
	C_TEXT:C284(Dict_SetTime; $2)
	C_TIME:C306(Dict_SetTime; $3)
	
	C_LONGINT:C283(Dict_SetBoolean; $1)
	C_TEXT:C284(Dict_SetBoolean; $2)
	C_BOOLEAN:C305(Dict_SetBoolean; $3)
	
	C_LONGINT:C283(Dict_SetPointer; $1)
	C_TEXT:C284(Dict_SetPointer; $2)
	C_POINTER:C301(Dict_SetPointer; $3)
	
	C_LONGINT:C283(Dict_GetLongint; $0; $1)
	C_TEXT:C284(Dict_GetLongint; $2)
	
	C_REAL:C285(Dict_GetReal; $0)
	C_LONGINT:C283(Dict_GetReal; $1)
	C_TEXT:C284(Dict_GetReal; $2)
	
	C_DATE:C307(Dict_GetDate; $0)
	C_LONGINT:C283(Dict_GetDate; $1)
	C_TEXT:C284(Dict_GetDate; $2)
	
	C_TIME:C306(Dict_GetTime; $0)
	C_LONGINT:C283(Dict_GetTime; $1)
	C_TEXT:C284(Dict_GetTime; $2)
	
	C_BOOLEAN:C305(Dict_GetBoolean; $0)
	C_LONGINT:C283(Dict_GetBoolean; $1)
	C_TEXT:C284(Dict_GetBoolean; $2)
	
	C_POINTER:C301(Dict_GetPointer; $0)
	C_LONGINT:C283(Dict_GetPointer; $1)
	C_TEXT:C284(Dict_GetPointer; $2)
	
	C_LONGINT:C283(Dict_Keys; $1)
	C_POINTER:C301(Dict_Keys; $2)
	
	C_LONGINT:C283(Dict_Values; $1)
	C_POINTER:C301(Dict_Values; $2)
	
	C_LONGINT:C283(Dict_DataTypes; $1)
	C_POINTER:C301(Dict_DataTypes; $2)
	
	C_TEXT:C284(Dict_Info; $0; $1)
	
	C_LONGINT:C283(Dict_ItemCount; $0; $1)
	
	C_TEXT:C284(Dict_Key; $0)
	C_LONGINT:C283(Dict_Key; $1; $2)
	
	C_LONGINT:C283(Dict_Remove; $1)
	C_TEXT:C284(Dict_Remove; $2)
	
	C_LONGINT:C283(Dict_SetValue; $1; $4)
	C_TEXT:C284(Dict_SetValue; $2; $3)
	
	C_TEXT:C284(Dict_GetValue; $0; $2)
	C_LONGINT:C283(Dict_GetValue; $1)
	
	C_LONGINT:C283(Dict_Retain; $1)
	
	C_LONGINT:C283(Dict_RetainCount; $0; $1)
	
	C_TEXT:C284(Dict_Name; $0; $2)
	C_LONGINT:C283(Dict_Name; $1)
	
	C_LONGINT:C283(Dict_DataType; $0; $1)
	C_TEXT:C284(Dict_DataType; $2)
	
	C_LONGINT:C283(Dict_SaveToBlob; $1)
	C_POINTER:C301(Dict_SaveToBlob; $2)
	
	C_LONGINT:C283(Dict_Save; $1)
	C_POINTER:C301(Dict_Save; $2)
	C_TEXT:C284(Dict_Save; $0)
	
	C_LONGINT:C283(Dict_SaveToText; $1)
	C_TEXT:C284(Dict_SaveToText; $0)
	
	C_LONGINT:C283(Dict_SaveToFile; $1)
	C_TEXT:C284(Dict_SaveToFile; $2)
	
	C_LONGINT:C283(Dict_LoadFromBlob; $0)
	C_POINTER:C301(Dict_LoadFromBlob; $1)
	
	C_LONGINT:C283(Dict_LoadFromFile; $0)
	C_TEXT:C284(Dict_LoadFromFile; $1)
	
	C_LONGINT:C283(Dict_LoadFromText; $0)
	C_TEXT:C284(Dict_LoadFromText; $1)
	
	
	
	C_LONGINT:C283(Dict_Load; $0)
	C_POINTER:C301(Dict_Load; $1)
	C_TEXT:C284(Dict_Load; $2)
	
	C_LONGINT:C283(Dict_SetArray; $1)
	C_TEXT:C284(Dict_SetArray; $2)
	C_POINTER:C301(Dict_SetArray; $3)
	
	C_LONGINT:C283(Dict_GetArray; $1)
	C_TEXT:C284(Dict_GetArray; $2)
	C_POINTER:C301(Dict_GetArray; $3)
	
	C_BOOLEAN:C305(Dict_LockInternalState; $1)
	
	C_LONGINT:C283(Dict_SetArrayText; $1; $3)
	C_TEXT:C284(Dict_SetArrayText; $2)
	C_TEXT:C284(Dict_SetArrayText; $4)
	
	C_LONGINT:C283(Dict_GetArrayText; $1; $3)
	C_TEXT:C284(Dict_GetArrayText; $2)
	C_TEXT:C284(Dict_GetArrayText; $0)
	
	C_LONGINT:C283(Dict_SetArrayDate; $1; $3)
	C_TEXT:C284(Dict_SetArrayDate; $2)
	C_DATE:C307(Dict_SetArrayDate; $4)
	
	C_LONGINT:C283(Dict_GetArrayDate; $1; $3)
	C_TEXT:C284(Dict_GetArrayDate; $2)
	C_DATE:C307(Dict_GetArrayDate; $0)
	
	C_LONGINT:C283(Dict_SetArrayLongint; $1; $3)
	C_TEXT:C284(Dict_SetArrayLongint; $2)
	C_LONGINT:C283(Dict_SetArrayLongint; $4)
	
	C_LONGINT:C283(Dict_GetArrayLongint; $1; $3)
	C_TEXT:C284(Dict_GetArrayLongint; $2)
	C_LONGINT:C283(Dict_GetArrayLongint; $0)
	
	C_LONGINT:C283(Dict_SetArrayReal; $1; $3)
	C_TEXT:C284(Dict_SetArrayReal; $2)
	C_REAL:C285(Dict_SetArrayReal; $4)
	
	C_LONGINT:C283(Dict_GetArrayReal; $1; $3)
	C_TEXT:C284(Dict_GetArrayReal; $2)
	C_REAL:C285(Dict_GetArrayReal; $0)
	
	C_LONGINT:C283(Dict_SetArrayBoolean; $1; $3)
	C_TEXT:C284(Dict_SetArrayBoolean; $2)
	C_BOOLEAN:C305(Dict_SetArrayBoolean; $4)
	
	C_LONGINT:C283(Dict_GetArrayBoolean; $1; $3)
	C_TEXT:C284(Dict_GetArrayBoolean; $2)
	C_BOOLEAN:C305(Dict_GetArrayBoolean; $0)
	
	C_LONGINT:C283(Dict_SetArrayPointer; $1; $3)
	C_TEXT:C284(Dict_SetArrayPointer; $2)
	C_POINTER:C301(Dict_SetArrayPointer; $4)
	
	C_LONGINT:C283(Dict_GetArrayPointer; $1; $3)
	C_TEXT:C284(Dict_GetArrayPointer; $2)
	C_POINTER:C301(Dict_GetArrayPointer; $0)
	
	C_LONGINT:C283(Dict_SetArrayTime; $1; $3)
	C_TEXT:C284(Dict_SetArrayTime; $2)
	C_TIME:C306(Dict_SetArrayTime; $4)
	
	C_LONGINT:C283(Dict_GetArrayTime; $1; $3)
	C_TEXT:C284(Dict_GetArrayTime; $2)
	C_TIME:C306(Dict_GetArrayTime; $0)
	
	C_LONGINT:C283(Dict_DeleteArrayElement; $1; $3; $4)
	C_TEXT:C284(Dict_DeleteArrayElement; $2)
	
	C_LONGINT:C283(Dict_SizeOfArray; $1; $0)
	C_TEXT:C284(Dict_SizeOfArray; $2)
	
	C_LONGINT:C283(Dict_RenameKey; $1)
	C_TEXT:C284(Dict_RenameKey; $2; $3)
	
	C_LONGINT:C283(Dict_ResizeArray; $1; $3)
	C_TEXT:C284(Dict_ResizeArray; $2)
	
	C_LONGINT:C283(Dict_InsertArrayElement; $1; $3)
	C_TEXT:C284(Dict_InsertArrayElement; $2)
	
	C_LONGINT:C283(Dict_Copy; $1; $0)
	C_TEXT:C284(Dict_Copy; $2)
	
	C_TEXT:C284(Dict_BugAlert; $1; $2)
	
	C_TEXT:C284(Dict_Named; $1)
	C_LONGINT:C283(Dict_Named; $0)
	
	C_LONGINT:C283(Dict_DeleteAllPictures; $1)
	
	C_BLOB:C604(Dict_GetBlob; $0)
	C_LONGINT:C283(Dict_GetBlob; $1)
	C_TEXT:C284(Dict_GetBlob; $2)
	
	C_PICTURE:C286(Dict_GetPicture; $0)
	C_LONGINT:C283(Dict_GetPicture; $1)
	C_TEXT:C284(Dict_GetPicture; $2)
	
	C_LONGINT:C283(Dict_SetBlob; $1)
	C_TEXT:C284(Dict_SetBlob; $2)
	C_BLOB:C604(Dict_SetBlob; $3)
	
	C_LONGINT:C283(Dict_SetPicture; $1)
	C_TEXT:C284(Dict_SetPicture; $2)
	C_PICTURE:C286(Dict_SetPicture; $3)
	C_BOOLEAN:C305(Dict_SetPicture; $4)
	
	
	C_LONGINT:C283(Dict_GetAvailablePictureSlot; $0)
	C_TEXT:C284(Dict_GetAvailablePictureSlot; $1)
	
	C_LONGINT:C283(Dict_SetChild; $1; $2)
	C_TEXT:C284(Dict_SetChild; $3; $4)
	
	C_LONGINT:C283(Dict_GetChild; $1; $0)
	C_TEXT:C284(Dict_GetChild; $2; $3; $4)
	
	C_LONGINT:C283(Dict_UpdateDictionaryItemsDispl; $1)
	
	
	C_BOOLEAN:C305(Dict_CloseDialog; $1; $0)
	
	C_LONGINT:C283(Dict_DisplayUsage; $1)
	
	// C_TEXT(Path to File Name ;$1;$0)
	
	C_BOOLEAN:C305(Dict_FoundationPresent; $0)
	
	C_BOOLEAN:C305(Dict_APD_Cleanup; $1; $0)
	
	C_LONGINT:C283(Dict_APD_CleanupProcess; $1)
	
	C_LONGINT:C283(Dict_CompareItems; $1; $3; $0)
	C_TEXT:C284(Dict_CompareItems; $2; $4)
	
	C_TEXT:C284(Dict_ErrorDetails; $1; $0)
	C_TEXT:C284(Dict_ErrorText; $0)
	C_LONGINT:C283(Dict_ErrorText; $1)
	
	C_TEXT:C284(Dict_EnabledProcess; $1)
	C_BOOLEAN:C305(Dict_EnabledProcess; $0)
	
	C_TEXT:C284(KVP_Remove; $1)
	
	C_TEXT:C284(KVP_SetHostVariable; $1; $2; $3; $4)
	C_TEXT:C284(KVP_New; $1; $0)
	C_TEXT:C284(KVP_Text; $1; $2; $0)
	C_TEXT:C284(KVP_Release; $1)
	
	C_TEXT:C284(KVP_SetArray; $1)
	C_POINTER:C301(KVP_SetArray; $2)
	
	C_TEXT:C284(KVP_Copy; $1; $2; $0)
	
	C_TEXT:C284(KVP_Text; $1; $2; $0)
	C_TEXT:C284(KVP_Longint; $1)
	C_LONGINT:C283(KVP_Longint; $2; $0)
	C_TEXT:C284(KVP_Real; $1)
	C_REAL:C285(KVP_Real; $2; $0)
	C_TEXT:C284(KVP_Boolean; $1)
	C_BOOLEAN:C305(KVP_Boolean; $2; $0)
	C_TEXT:C284(KVP_Date; $1)
	C_DATE:C307(KVP_Date; $2; $0)
	C_TEXT:C284(KVP_Time; $1)
	C_TIME:C306(KVP_Time; $2; $0)
	C_TEXT:C284(KVP_Blob; $1)
	C_BLOB:C604(KVP_Blob; $2; $0)
	C_TEXT:C284(KVP_Picture; $1)
	C_PICTURE:C286(KVP_Picture; $2; $0)
	C_TEXT:C284(KVP_Pointer; $1)
	C_POINTER:C301(KVP_Pointer; $2; $0)
	
	C_TEXT:C284(KVP_SetChild; $1; $2; $3; $4)
	C_TEXT:C284(KVP_GetChild; $1; $2; $3; $4; $0)
	
	C_TEXT:C284(KVP_ParseDictionaryAndKey; $1)
	C_POINTER:C301(KVP_ParseDictionaryAndKey; $2; $3)
	
	C_POINTER:C301(Dict_ActiveDictionaries; $1)
	
End if 
