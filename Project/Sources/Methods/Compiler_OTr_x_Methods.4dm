//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Compiler_OTr_x_Methods

// Compiler declarations for OTr_x_ methods (legacy OT Blob compatibility).

// Access: Private
// Parameters: None
// Returns: Nothing

// Created by Wayne Stewart, 2026-04-21
// ----------------------------------------------------

If (False:C215)

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

End if
