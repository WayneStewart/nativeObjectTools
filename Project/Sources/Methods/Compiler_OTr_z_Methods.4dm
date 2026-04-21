//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Compiler_OTr_z_Methods

// Compiler declarations for OTr_z_ methods (internal utilities).

// Access: Private
// Parameters: None
// Returns: Nothing

// Created by Wayne Stewart, 2026-04-21
// ----------------------------------------------------

If (False:C215)

	C_BOOLEAN:C305(OTr_z_PluginShouldWork; $0)

	C_BOOLEAN:C305(OTr_z_Comment_Uncomment_OT_Code; $1; $2)

	C_BOOLEAN:C305(OTr_z_ResolvePath; $0; $3)
	C_OBJECT:C1216(OTr_z_ResolvePath; $1)
	C_TEXT:C284(OTr_z_ResolvePath; $2)
	C_POINTER:C301(OTr_z_ResolvePath; $4; $5)

	C_BOOLEAN:C305(OTr_z_IsValidHandle; $0)
	C_LONGINT:C283(OTr_z_IsValidHandle; $1)

	C_BOOLEAN:C305(OTr_z_Error; $0)
	C_TEXT:C284(OTr_z_Error; $1; $2)

	C_LONGINT:C283(OTr_z_MapType; $0)
	C_OBJECT:C1216(OTr_z_MapType; $1)
	C_TEXT:C284(OTr_z_MapType; $2)

	C_BOOLEAN:C305(OTr_z_SortValidatePair; $0)
	C_OBJECT:C1216(OTr_z_SortValidatePair; $1)

	C_POINTER:C301(OTr_z_SortSlotPointer; $0)
	C_LONGINT:C283(OTr_z_SortSlotPointer; $1; $2)

	C_LONGINT:C283(OTr_z_SortFillSlot; $1; $3)
	C_OBJECT:C1216(OTr_z_SortFillSlot; $2)

	C_OBJECT:C1216(OTr_z_ArrayFromObject; $1)
	C_POINTER:C301(OTr_z_ArrayFromObject; $2)

	C_LONGINT:C283(OTr_z_ArrayType; $0)
	C_OBJECT:C1216(OTr_z_ArrayType; $1)

	C_TEXT:C284(OTr_z_ShadowKey; $0; $1)

	C_BOOLEAN:C305(OTr_z_IsShadowKey; $0)
	C_TEXT:C284(OTr_z_IsShadowKey; $1)

	C_TEXT:C284(OTr_z_XMLWriteObject; $1)
	C_OBJECT:C1216(OTr_z_XMLWriteObject; $2)
	C_BOOLEAN:C305(OTr_z_XMLWriteObject; $3)

	C_OBJECT:C1216(OTr_z_XMLReadObject; $0)
	C_TEXT:C284(OTr_z_XMLReadObject; $1)

	C_TIME:C306(OTr_z_XMLWriteObjectSAX; $1)
	C_OBJECT:C1216(OTr_z_XMLWriteObjectSAX; $2)
	C_BOOLEAN:C305(OTr_z_XMLWriteObjectSAX; $3)

	C_TEXT:C284(OTr_z_LogDirectory; $0)
	C_LONGINT:C283(OTr_z_LogLevelToInt; $0)
	C_TEXT:C284(OTr_z_LogLevelToInt; $1)
	C_TEXT:C284(OTr_z_LogFileName; $0)
	OTr_z_LogShutdown
	C_TEXT:C284(OTr_z_LogWrite; $1; $2; $3)
	C_TEXT:C284(OTr_z_LogGetCallStack; $0; $1)
	C_TEXT:C284(OTr_z_AddToCallStack; $1)
	C_TEXT:C284(OTr_z_RemoveFromCallStack; $1)

	C_LONGINT:C283(OTr_z_SetOK; $1; $0)

	C_TEXT:C284(OTr_z_timestampLocal; $1; $0)

	C_TEXT:C284(OTr_z_Get4DVersion; $0)

	C_PICTURE:C286(OTr_z_Wombat; $0)
	C_PICTURE:C286(OTr_z_Koala; $0)
	C_PICTURE:C286(OTr_z_Echidna; $0)

End if
