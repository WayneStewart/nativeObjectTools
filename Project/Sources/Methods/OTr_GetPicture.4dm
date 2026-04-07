//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetPicture (inObject; inTag) --> Picture

// Retrieves a Picture value from the specified tag path.
// The stored "pic:N" reference is resolved via
// OTr_uTextToPicture. Returns an empty Picture on any
// error or missing tag.

// **ORIGINAL DOCUMENTATION**
// 
// *OT GetPicture* retrieves a Picture value from *inObject*.
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
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_pic : Picture

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; ->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$result_pic:=OB Get($parent_o; $leafKey_t; Is picture)
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
	OTr_zSetOK(0)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
