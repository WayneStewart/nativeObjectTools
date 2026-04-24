//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetNewBLOB (inObject; inTag) --> Blob

// Retrieves a BLOB value from the specified tag path as a function result.
// Returns an empty BLOB on any error or missing tag.

// **WARNING: Changed Behaviour**

// This is the function-result form to use when migrating code that
// previously relied on the legacy OT GetBLOB output-parameter command.
// Assign the returned BLOB directly to the target variable or field.

// **ORIGINAL DOCUMENTATION**

// *OT GetNewBLOB* gets a value in *inObject* from the item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and an empty BLOB is returned.

// If no item in the object has the given tag, an empty BLOB is returned. If the
// *FailOnNoItem* option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Is BLOB*, the value of the
// requested item is returned.

// If an item with the given tag exists and has any other type, *OK* is set to zero and
// an empty BLOB is returned.

// Warning: Because of the problems related to *OT GetBLOB*, it is recommended that
// you use this command instead.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_blob : Blob : Stored BLOB, or empty BLOB on failure

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Branches on Storage.OTr.nativeBlobInObject;
//     native OB Get used when True, else base64 decode.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Actually honours
//   Storage.OTr.nativeBlobInObject (previously only claimed to in
//   the changelog; the body always decoded base64 text).
// Wayne Stewart, 2026-04-11 - Added type-mismatch guard via OTr_z_MapType: if the tag
//   exists but its stored OT type is not 30 (BLOB), an error is generated and OK is
//   set to zero, matching the documented original behaviour.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_blob : Blob

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			If (OTr_z_MapType($parent_o; $leafKey_t)=30)
				If (Storage:C1525.OTr.nativeBlobInObject)
					$result_blob:=OB Get:C1224($parent_o; $leafKey_t; Is BLOB:K8:12)
				Else 
					$result_blob:=OTr_u_TextToBlob(OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3))
				End if 
			Else 
				OTr_z_Error("Type mismatch"; Current method name:C684)
			End if 
		End if 
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
	OTr_z_SetOK(0)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
