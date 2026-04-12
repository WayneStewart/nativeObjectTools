//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetRecordTable (inObject; inTag) --> Integer

// Returns the table number recorded in the __tableNum
// property of the record snapshot sub-object at the tag
// path. Use this to verify which table a snapshot belongs
// to before calling OTr_GetRecord.

// **ORIGINAL DOCUMENTATION**

// *OT GetRecordTable* retrieves the table number from the packed record data in the
// item referenced by tag. The contents of the item must have been set with OT
// *PutRecord*. The table used to store the packed record is the table whose number will
// be returned.

// If the object is not a valid object handle, or no item in object has the given tag,
// zero is returned, an error is generated and OK is set to zero.

// If an item with the given tag exists and has the type *OT Is Record*, the number of
// the item’s original table is returned.

// If an item with the given tag exists and has any other type, zero is returned, an
// error is generated and OK is set to zero.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)

// Returns:
//   $result_i : Integer : Table number from snapshot, or 0 on error

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_i : Integer

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $snapshot_o : Object

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))

	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; ->$parent_o; ->$leafKey_t))

		If (OB Is defined($parent_o; $leafKey_t))

			$snapshot_o:=OB Get($parent_o; $leafKey_t; Is object)

			If (OB Is defined($snapshot_o; "__tableNum"))
				$result_i:=OB Get($snapshot_o; "__tableNum"; Is longint)
			Else
				OTr_zError("Tag is not a record snapshot"; Current method name)
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
