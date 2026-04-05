//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Compiler OTX

// Compiler variables related to the OTX routines.

// Method Type: Private

// Parameters: None

// Returns: Nothing

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

// Interprocess Variables
C_BOOLEAN:C305(<>OTX_Initialized_b; OTX_Initialized_b)
If (Not:C34(<>OTX_Initialized_b))  // So we only do this once.
	ARRAY LONGINT:C221(<>OTX_ListOfObjects_ai; 0)
	ARRAY POINTER:C280(<>OTX_Objects_aptr; 0)
	C_LONGINT:C283(<>OTX_ItemNames_i; <>OTX_ItemVariables_i; <>OTX_ItemTypes_i)
	
End if 

// Process Variables
If (Not:C34(OTX_Initialized_b))  // So we only do this once.
	
End if 

// Parameters
If (False:C215)
	C_TEXT:C284(OTX Info; $1; $0)
	
	C_LONGINT:C283(OTX New; $0)
	
	C_LONGINT:C283(OTX Get Object Pointer; $1)
	C_POINTER:C301(OTX Get Object Pointer; $0)
	
	C_LONGINT:C283(OTX ItemType; $1; $0)
	C_TEXT:C284(OTX ItemType; $2)
	C_POINTER:C301(OTX ItemType; $3)
	
	C_LONGINT:C283(OTX PutText; $1)
	C_TEXT:C284(OTX PutText; $2)
	C_TEXT:C284(OTX PutText; $3)
	C_LONGINT:C283(OTX GetText; $1)
	C_TEXT:C284(OTX GetText; $2)
	C_TEXT:C284(OTX GetText; $0)
	
	C_LONGINT:C283(OTX PutLong; $1)
	C_TEXT:C284(OTX PutLong; $2)
	C_LONGINT:C283(OTX PutLong; $3)
	C_LONGINT:C283(OTX GetLong; $1)
	C_TEXT:C284(OTX GetLong; $2)
	C_LONGINT:C283(OTX GetLong; $0)
	
	C_POINTER:C301(OTX Get Item Position; $1)
	C_TEXT:C284(OTX Get Item Position; $2)
	C_LONGINT:C283(OTX Get Item Position; $0)
	
	C_LONGINT:C283(OTX IsObject; $1)
	C_LONGINT:C283(OTX IsObject; $0)
	
	C_LONGINT:C283(OTX Clear; $1)
	
	C_LONGINT:C283(OTX PutPicture; $1)
	C_TEXT:C284(OTX PutPicture; $2)
	C_PICTURE:C286(OTX PutPicture; $3)
	C_LONGINT:C283(OTX GetPicture; $1)
	C_TEXT:C284(OTX GetPicture; $2)
	C_PICTURE:C286(OTX GetPicture; $0)
	
	C_LONGINT:C283(OTX PutReal; $1)
	C_TEXT:C284(OTX PutReal; $2)
	C_REAL:C285(OTX PutReal; $3)
	C_LONGINT:C283(OTX GetReal; $1)
	C_TEXT:C284(OTX GetReal; $2)
	C_REAL:C285(OTX GetReal; $0)
	
	C_LONGINT:C283(OTX PutDate; $1)
	C_TEXT:C284(OTX PutDate; $2)
	C_DATE:C307(OTX PutDate; $3)
	C_LONGINT:C283(OTX GetDate; $1)
	C_TEXT:C284(OTX GetDate; $2)
	C_DATE:C307(OTX GetDate; $0)
	
	C_LONGINT:C283(OTX ObjectToBLOB; $1)
	C_POINTER:C301(OTX ObjectToBLOB; $2)
	
	C_LONGINT:C283(OTX ItemCount; $1; $0)
	
	C_POINTER:C301(OTX BlobToObject; $1)
	C_LONGINT:C283(OTX BlobToObject; $2; $0)
	
	C_LONGINT:C283(OTX DeleteItem; $1)
	C_TEXT:C284(OTX DeleteItem; $2)
	
	C_LONGINT:C283(OTX RenameItem; $1)
	C_TEXT:C284(OTX RenameItem; $2; $3)
	
	C_LONGINT:C283(OTX PutArrayLong; $1; $3; $4)
	C_TEXT:C284(OTX PutArrayLong; $2)
	
	C_LONGINT:C283(OTX GetArrayLong; $1; $3; $0)
	C_TEXT:C284(OTX GetArrayLong; $2)
	
	C_LONGINT:C283(OTX PutArray; $1)
	C_TEXT:C284(OTX PutArray; $2)
	C_POINTER:C301(OTX PutArray; $3)
	
	C_LONGINT:C283(OTX GetArray; $1)
	C_TEXT:C284(OTX GetArray; $2)
	C_POINTER:C301(OTX GetArray; $3)
	
	C_LONGINT:C283(OTX ResizeArray; $1; $3)
	C_TEXT:C284(OTX ResizeArray; $2)
	
	C_LONGINT:C283(OTX SizeOfArray; $1; $0)
	C_TEXT:C284(OTX SizeOfArray; $2)
	
	C_LONGINT:C283(OTX DeleteElement; $1; $3; $4)
	C_TEXT:C284(OTX DeleteElement; $2)
	
	C_LONGINT:C283(OTX FindInArray; $1; $4; $0)
	C_TEXT:C284(OTX FindInArray; $2; $3)
	
	C_LONGINT:C283(OTX InsertElement; $1; $3; $4)
	C_TEXT:C284(OTX InsertElement; $2)
	
	C_LONGINT:C283(OTX GetArrayElement; $1; $3; $4)
	C_TEXT:C284(OTX GetArrayElement; $2)
	C_POINTER:C301(OTX GetArrayElement; $5)
	
	C_LONGINT:C283(OTX GetArrayBoolean; $1; $3)
	C_TEXT:C284(OTX GetArrayBoolean; $2)
	C_BOOLEAN:C305(OTX GetArrayBoolean; $0)
	
	C_LONGINT:C283(OTX GetArrayText; $1; $3)
	C_TEXT:C284(OTX GetArrayText; $2)
	C_TEXT:C284(OTX GetArrayText; $0)
	
	C_LONGINT:C283(OTX GetArrayReal; $1; $3)
	C_TEXT:C284(OTX GetArrayReal; $2)
	C_REAL:C285(OTX GetArrayReal; $0)
	
	C_LONGINT:C283(OTX GetArrayPicture; $1; $3)
	C_TEXT:C284(OTX GetArrayPicture; $2)
	C_PICTURE:C286(OTX GetArrayPicture; $0)
	
	C_LONGINT:C283(OTX GetArrayDate; $1; $3)
	C_TEXT:C284(OTX GetArrayDate; $2)
	C_DATE:C307(OTX GetArrayDate; $0)
	
	C_LONGINT:C283(OTX GetArrayPointer; $1; $3)
	C_TEXT:C284(OTX GetArrayPointer; $2)
	C_POINTER:C301(OTX GetArrayPointer; $0)
	
	C_LONGINT:C283(OTX PutArrayBoolean; $1; $3)
	C_TEXT:C284(OTX PutArrayBoolean; $2)
	C_BOOLEAN:C305(OTX PutArrayBoolean; $4)
	
	C_LONGINT:C283(OTX PutArrayPicture; $1; $3)
	C_TEXT:C284(OTX PutArrayPicture; $2)
	C_PICTURE:C286(OTX PutArrayPicture; $4)
	
	C_LONGINT:C283(OTX PutArrayReal; $1; $3)
	C_TEXT:C284(OTX PutArrayReal; $2)
	C_REAL:C285(OTX PutArrayReal; $4)
	
	C_LONGINT:C283(OTX PutArrayPointer; $1; $3)
	C_TEXT:C284(OTX PutArrayPointer; $2)
	C_POINTER:C301(OTX PutArrayPointer; $4)
	
	C_LONGINT:C283(OTX PutArrayText; $1; $3)
	C_TEXT:C284(OTX PutArrayText; $2)
	C_TEXT:C284(OTX PutArrayText; $4)
	
	C_LONGINT:C283(OTX PutArrayDate; $1; $3)
	C_TEXT:C284(OTX PutArrayDate; $2)
	C_DATE:C307(OTX PutArrayDate; $4)
	
	C_LONGINT:C283(OTX PutArrayElement; $1; $3; $4)
	C_TEXT:C284(OTX PutArrayElement; $2)
	C_POINTER:C301(OTX PutArrayElement; $5)
	
	C_LONGINT:C283(OTX ItemExists; $0; $1)
	C_TEXT:C284(OTX ItemExists; $2)
	
	
	
	
End if 




