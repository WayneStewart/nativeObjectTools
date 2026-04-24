//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Compiler_OTr_Methods

// Compiler declarations for OTr_ public API methods.

// Access: Private
// Parameters: None
// Returns: Nothing

// Created by Wayne Stewart, 2026-04-21
// ----------------------------------------------------

If (False:C215)
	
	C_TEXT:C284(OT SetErrorHandler; $0)
	C_TEXT:C284(OT SetErrorHandler; $1)
	
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
	
	C_TEXT:C284(OT SaveToXML; $0)
	C_LONGINT:C283(OT SaveToXML; $1)
	C_BOOLEAN:C305(OT SaveToXML; $2)
	
	C_LONGINT:C283(OT SaveToXMLFile; $1)
	C_TEXT:C284(OT SaveToXMLFile; $2)
	C_BOOLEAN:C305(OT SaveToXMLFile; $3)
	
	C_TEXT:C284(OT LoadFromXML; $1)
	C_LONGINT:C283(OT LoadFromXML; $0)
	
	C_TEXT:C284(OT LoadFromXMLFile; $1)
	C_LONGINT:C283(OT LoadFromXMLFile; $0)
	
	C_BOOLEAN:C305(OT IncludeShadowKey; $0; $1)
	
	C_TEXT:C284(OT SaveToXMLSAX; $0)
	C_LONGINT:C283(OT SaveToXMLSAX; $1)
	C_BOOLEAN:C305(OT SaveToXMLSAX; $2)
	
	C_LONGINT:C283(OT SaveToXMLFileSAX; $1)
	C_TEXT:C284(OT SaveToXMLFileSAX; $2)
	C_BOOLEAN:C305(OT SaveToXMLFileSAX; $3)
	
	C_LONGINT:C283(OT SetOptions; $1)
	
	C_LONGINT:C283(OT Copy; $0)
	C_LONGINT:C283(OT Copy; $1)
	
	C_LONGINT:C283(OT CompiledApplication; $0)
	
	C_LONGINT:C283(OT GetOptions; $0)
	
	C_LONGINT:C283(OT New; $0)
	
	C_LONGINT:C283(OT Clear; $1)
	
	C_TEXT:C284(OT Info; $0)
	C_TEXT:C284(OT Info; $1; $0)
	
	C_LONGINT:C283(OT IsObject; $0)
	C_LONGINT:C283(OT IsObject; $1)
	
	C_LONGINT:C283(OT ItemCount; $0; $1)
	C_TEXT:C284(OT ItemCount; $2)
	
	C_LONGINT:C283(OT ObjectSize; $0; $1)
	
	C_LONGINT:C283(OT ItemExists; $0; $1)
	C_TEXT:C284(OT ItemExists; $2)
	
	C_LONGINT:C283(OT ItemType; $0; $1)
	C_TEXT:C284(OT ItemType; $2)
	C_BOOLEAN:C305(OT ItemType; $3)
	
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
	
	C_LONGINT:C283(OT Register; $0)
	C_TEXT:C284(OT Register; $1)
	
	C_TEXT:C284(OT LogLevel; $0; $1)
	C_BOOLEAN:C305(OT LogLevel; $2)
	
	C_LONGINT:C283(OTr; $0)
	
	C_POINTER:C301(OT GetHandleList; $1)
	C_LONGINT:C283(OT GetActiveHandleCount; $0)
	
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
	
	C_LONGINT:C283(OT PutArrayPicture; $1; $3)
	C_TEXT:C284(OT PutArrayPicture; $2)
	C_PICTURE:C286(OT PutArrayPicture; $4)
	
	C_PICTURE:C286(OT GetArrayPicture; $0)
	C_LONGINT:C283(OT GetArrayPicture; $1; $3)
	C_TEXT:C284(OT GetArrayPicture; $2)
	
	C_LONGINT:C283(OT PutArrayPointer; $1; $3)
	C_TEXT:C284(OT PutArrayPointer; $2)
	C_POINTER:C301(OT PutArrayPointer; $4)
	
	C_POINTER:C301(OT GetArrayPointer; $0)
	C_LONGINT:C283(OT GetArrayPointer; $1; $3)
	C_TEXT:C284(OT GetArrayPointer; $2)
	
	C_LONGINT:C283(OT PutBLOB; $1)
	C_TEXT:C284(OT PutBLOB; $2)
	C_BLOB:C604(OT PutBLOB; $3)
	
	C_LONGINT:C283(OT GetBLOB; $1)
	C_TEXT:C284(OT GetBLOB; $2)
	C_POINTER:C301(OT GetBLOB; $3)
	
	C_BLOB:C604(OT GetNewBLOB; $0)
	C_LONGINT:C283(OT GetNewBLOB; $1)
	C_TEXT:C284(OT GetNewBLOB; $2)
	
	C_LONGINT:C283(OT PutPicture; $1)
	C_TEXT:C284(OT PutPicture; $2)
	C_PICTURE:C286(OT PutPicture; $3)
	
	C_PICTURE:C286(OT GetPicture; $0)
	C_LONGINT:C283(OT GetPicture; $1)
	C_TEXT:C284(OT GetPicture; $2)
	
	C_LONGINT:C283(OT PutPointer; $1)
	C_TEXT:C284(OT PutPointer; $2)
	C_POINTER:C301(OT PutPointer; $3)
	
	C_LONGINT:C283(OT GetPointer; $1)
	C_TEXT:C284(OT GetPointer; $2)
	C_POINTER:C301(OT GetPointer; $3)
	
	C_LONGINT:C283(OT SortArrays; $1)
	C_TEXT:C284(OT SortArrays; ${2})
	
	C_LONGINT:C283(OT SizeOfArray; $0; $1)
	C_TEXT:C284(OT SizeOfArray; $2)
	
	C_LONGINT:C283(OT ResizeArray; $1; $3)
	C_TEXT:C284(OT ResizeArray; $2)
	
	C_LONGINT:C283(OT DeleteElement; $1; $3; $4)
	C_TEXT:C284(OT DeleteElement; $2)
	
	C_LONGINT:C283(OT InsertElement; $1; $3; $4)
	C_TEXT:C284(OT InsertElement; $2)
	
	C_LONGINT:C283(OT ArrayType; $0; $1)
	C_TEXT:C284(OT ArrayType; $2)
	
	C_LONGINT:C283(OT GetArray; $1)
	C_TEXT:C284(OT GetArray; $2)
	C_POINTER:C301(OT GetArray; $3)
	
	C_TEXT:C284(OT FindInArray; $2; $3)
	C_LONGINT:C283(OT FindInArray; $1; $0; $4)
	
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
	
	C_LONGINT:C283(OT ObjectToBLOB; $1; $3)
	C_POINTER:C301(OT ObjectToBLOB; $2)
	
	C_LONGINT:C283(OT ObjectToNewBLOB; $1)
	C_BLOB:C604(OT ObjectToNewBLOB; $0)
	
	C_BLOB:C604(OT BLOBToObject; $1)
	C_LONGINT:C283(OT BLOBToObject; $0)
	
	C_BLOB:C604(OT ImportLegacyBlob; $1)
	C_LONGINT:C283(OT ImportLegacyBlob; $0)
	
	C_TEXT:C284(OT SetDateMode; $1; $0)
	
	
	
	C_BOOLEAN:C305(OT ClearAll; $0)
	
End if 
