//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetBLOB (inObject; inTag; outBLOB)

// Retrieves a BLOB value from the specified tag path and
// writes it back to the caller's variable via the outBLOB
// pointer parameter. When Storage.OTr.nativeBlobInObject is
// True (4D v19 R2 and later), the property is read as a
// native BLOB via OB Get; otherwise it is read as plain
// base64 text and decoded via OTr_u_TextToBlob. Writes an
// empty BLOB on any error or missing tag.

// **WARNING: Changed Behaviour**

// In native 4D, BLOB parameters are passed by value, so a
// plain Blob parameter cannot be written back to the caller.
// The outBLOB parameter is therefore a Pointer, and callers
// must pass ->myBlobVar (pointer-to-BLOB syntax). 

// The method writes the result back via $outBLOB_ptr->
//
// This matches the idiom used by OT GetPointer.
// The legacy plugin command accepted a plain BLOB variable
// because it operated at C level; native 4D callers must
// use the -> syntax instead.
//
// Correct usage:
// ```
//   var myBlob : Blob
//   var myPointer_ptr : Pointer
//   myPointer_ptr :=-> myBlob
//   OT GetBLOB(handle; "tag"; myPointer_ptr)
// ```
//
// Alternatively, use OT GetNewBLOB which returns the BLOB
// as a function result and requires no pointer syntax.

// **ORIGINAL DOCUMENTATION**

// OT GetBLOB gets a value in *inObject* from the item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and an empty BLOB is returned.

// If no item in the object has the given tag, an empty BLOB is returned. If the
// *FailOnNoItem*

// option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Is BLOB*, out *BLOB* ’s
// contents are replaced.

// If an item with the given tag exists and has any other type, *OK* is set to zero, and
// an empty BLOB is returned.

// Warning: Do not attempt to pass a BLOB field or a dereferenced pointer to a BLOB field
// in the blob paremeter, as this will result in a crash. If you want to retrieve a BLOB
// item into a field, either use an intermediate local variable or assign the result of *
// *OT GetNewBLOB to the field. The same applies to passing a dereferenced pointer to a
// BLOB variable. This command is being kept for backward compatibility. Because of the
// problems related to this command, it is recommended that you use OT GetNewBLOB* *
// instead, as this command may be removed in future versions.

// Access: Shared

// Parameters:
//   $inObject_i  : Integer : OTr inObject
//   $inTag_t     : Text    : Tag path (inTag)
//   $outBLOB_ptr : Pointer : Pointer to caller's Blob variable (->outBLOB)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Implemented using Pointer parameter
//     (replaces stub). Mirrors OT GetNewBLOB logic; writes result
//     back via $outBLOB_ptr->:= dereference.
// Wayne Stewart, 2026-04-10 - Honours Storage.OTr.nativeBlobInObject.
// Wayne Stewart, 2026-04-11 - Added type-mismatch guard via OTr_z_MapType: if the tag
//   exists but its stored OT type is not 30 (BLOB), an error is generated and OK is
//   set to zero, matching the documented original behaviour.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $outBLOB_ptr : Pointer)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $result_blob : Blob

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
End if 

$outBLOB_ptr->:=$result_blob

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
