//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetPicture (inObject; inTag) --> Picture

// Retrieves a Picture value from the specified tag path.
// Returns an empty Picture on any error or missing tag.

// **ORIGINAL DOCUMENTATION**

// OT GetPicture gets a value in *inObject* from the item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and an empty picture is returned.

// If no item in the object has the given tag, an empty picture is returned. If the

// *FailOnNoItem* option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Is Picture*, the value of the
// requested item is returned.

// If an item with the given tag exists and has any other type, *OK* is set to zero, and
// an empty picture is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_pic : Picture : Stored Picture, or empty Picture on failure

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-03 - Removed proxy string; Picture now
//     retrieved natively via OB Get with Is picture.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Added OB Get type pre-check before
//     retrieving as picture. OB Get with Is picture on a non-picture
//     property throws error 64; the type check intercepts this and
//     routes to OTr_z_Error instead.
// Wayne Stewart, 2026-04-12 - Replaced broad (Is picture | Is object)
//     type check with OTr_z_MapType shadow-key discriminator. OB Get type
//     misreports stored Pictures as Is object (38) in 4D v19-v21; the
//     previous workaround accepted any Is object property as a Picture,
//     which would incorrectly allow a genuine embedded object to pass the
//     type check. OTr_z_MapType consults the shadow key written by
//     OT PutPicture (Is picture:K8:10) and returns Is picture:K8:10 only for genuine
//     Pictures, regardless of the native type misreport.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_pic : Picture

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			If (OTr_z_MapType($parent_o; $leafKey_t)=Is picture:K8:10)
				$result_pic:=OB Get:C1224($parent_o; $leafKey_t; Is picture:K8:10)
			Else 
				OTr_z_Error("Type mismatch: tag does not reference a Picture"; Current method name:C684)
				OTr_z_SetOK(0)
			End if 
		End if 
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
	OTr_z_SetOK(0)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
