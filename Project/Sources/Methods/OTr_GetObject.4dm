//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetObject (inObject; inTag) --> Longint

// Retrieves an embedded object by tag path, copies it to a new OTr
// handle, and returns that handle.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to embedded object (inTag)

// Returns:
//   $newHandle_i : Integer : New handle containing a copy of the embedded object, or 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$newHandle_i : Integer

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $embedded_o : Object

$newHandle_i:=0

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$embedded_o:=OB Get($parent_o; $leafKey_t; Is object)
			If ($embedded_o#Null)
				$newHandle_i:=Find in array(<>OTR_InUse_ab; False)
				If ($newHandle_i=-1)
					$newHandle_i:=Size of array(<>OTR_InUse_ab)+1
					INSERT IN ARRAY(<>OTR_InUse_ab; $newHandle_i)
					INSERT IN ARRAY(<>OTR_Objects_ao; $newHandle_i)
				End if

				<>OTR_InUse_ab{$newHandle_i}:=True
				<>OTR_Objects_ao{$newHandle_i}:=OB Copy($embedded_o)
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
