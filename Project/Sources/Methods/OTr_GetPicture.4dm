//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetPicture (inObject; inTag) --> Picture

// Retrieves a Picture value from the specified tag path.
// Returns an empty Picture on any error or missing tag.

// **ORIGINAL DOCUMENTATION**
//
// *OTr_GetPicture* retrieves a Picture value from *inObject*.
//
// If *inObject* is not a valid object handle, an error
// is generated, OK is set to zero, and an empty Picture
// is returned.
//
// If no item in the object has the given inTag, an empty
// Picture is returned. If the FailOnItemNotFound option
// is set, an error is generated and OK is set to zero.
//
// If an item with the given inTag exists and has the type
// *Is Picture*, the value of the requested item is returned.
//
// If an item with the given inTag exists and has any other
// type, an error is generated, OK is set to zero, and an
// empty Picture is returned.

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
//     routes to OTr_zError instead.
// Wayne Stewart, 2026-04-12 - Replaced broad (Is picture | Is object)
//     type check with OTr_zMapType shadow-key discriminator. OB Get type
//     misreports stored Pictures as Is object (38) in 4D v19-v21; the
//     previous workaround accepted any Is object property as a Picture,
//     which would incorrectly allow a genuine embedded object to pass the
//     type check. OTr_zMapType consults the shadow key written by
//     OTr_PutPicture (Is picture:K8:10) and returns Is picture:K8:10 only for genuine
//     Pictures, regardless of the native type misreport.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_pic : Picture

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; ->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			If (OTr_zMapType($parent_o; $leafKey_t)=Is picture:K8:10)
				$result_pic:=OB Get($parent_o; $leafKey_t; Is picture)
			Else
				OTr_zError("Type mismatch: tag does not reference a Picture"; Current method name)
				OTr_zSetOK(0)
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
	OTr_zSetOK(0)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
