//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Compiler_OTr_u_Methods

// Compiler declarations for OTr_u_ methods (utility/conversion).

// Access: Private
// Parameters: None
// Returns: Nothing

// Created by Wayne Stewart, 2026-04-21
// ----------------------------------------------------

If (False:C215)

	C_BOOLEAN:C305(OTr_u_EqualBLOBs; $0)
	C_BLOB:C604(OTr_u_EqualBLOBs; $1; $2)

	C_BOOLEAN:C305(OTr_u_EqualStrings; $0)
	C_TEXT:C284(OTr_u_EqualStrings; $1; $2)

	C_BOOLEAN:C305(OTr_u_EqualPictures; $0)
	C_PICTURE:C286(OTr_u_EqualPictures; $1; $2)

	C_OBJECT:C1216(OTr_u_EqualObjects; $1; $2)
	C_BOOLEAN:C305(OTr_u_EqualObjects; $0)

	C_TIME:C306(OTr_u_TimeToText; $1)
	C_TEXT:C284(OTr_u_TimeToText; $0)

	C_TEXT:C284(OTr_u_TextToTime; $1)
	C_TIME:C306(OTr_u_TextToTime; $0)

	C_DATE:C307(OTr_u_DateToText; $1)
	C_TEXT:C284(OTr_u_DateToText; $0)

	C_TEXT:C284(OTr_u_TextToDate; $1)
	C_DATE:C307(OTr_u_TextToDate; $0)

	C_BOOLEAN:C305(OTr_u_NativeDateInObject; $0)

	C_POINTER:C301(OTr_u_PointerToText; $1)
	C_TEXT:C284(OTr_u_PointerToText; $0)

	C_TEXT:C284(OTr_u_TextToPointer; $1)
	C_POINTER:C301(OTr_u_TextToPointer; $0)

	C_BLOB:C604(OTr_u_BlobToText; $1)
	C_TEXT:C284(OTr_u_BlobToText; $0)

	C_TEXT:C284(OTr_u_TextToBlob; $1)
	C_BLOB:C604(OTr_u_TextToBlob; $0)

	C_VARIANT:C1683(OTr_u_AccessArrayElement; $0; $5)
	C_LONGINT:C283(OTr_u_AccessArrayElement; $1; $3; $4)
	C_TEXT:C284(OTr_u_AccessArrayElement; $2)

	C_LONGINT:C283(OTr_u_NewValueForEmbeddedType; $1)
	C_VARIANT:C1683(OTr_u_NewValueForEmbeddedType; $0)

	C_LONGINT:C283(OTr_u_MapType; $1; $2; $0)

End if
