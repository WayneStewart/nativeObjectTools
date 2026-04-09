//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT LoadFromBlob (inBlob) --> Longint

// Loads an object from a 4D-native blob (written by
// OT SaveToBlob) into a new OTr handle. The blob is
// expanded automatically if it is compressed before
// reading via BLOB TO VARIABLE.
// Returns 0 if the blob is empty or cannot be decoded.

// Access: Shared

// Parameters:
//   $inBlob_blob : Blob : Compressed 4D-native blob \
//                         (from OT SaveToBlob)

// Returns:
//   $handle_i : Integer : New OTr handle, \
//                         or 0 if loading failed

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob)->$handle_i : Integer

OTr_zAddToCallStack(Current method name)

var $loaded_o : Object
var $slot_i : Integer
var $compressed_i : Integer

$handle_i:=0

If (BLOB size($inBlob_blob)>0)

	BLOB PROPERTIES($inBlob_blob; $compressed_i)
	If ($compressed_i#Is not compressed)
		EXPAND BLOB($inBlob_blob)
	End if

	BLOB TO VARIABLE($inBlob_blob; $loaded_o)

	If ($loaded_o#Null)

		OTr_zLock

		$slot_i:=Find in array(<>OTR_InUse_ab; False)
		If ($slot_i=-1)
			$slot_i:=Size of array(<>OTR_InUse_ab)+1
			INSERT IN ARRAY(<>OTR_InUse_ab; $slot_i)
			INSERT IN ARRAY(<>OTR_Objects_ao; $slot_i)
		End if

		<>OTR_Objects_ao{$slot_i}:=OB Copy($loaded_o)
		<>OTR_InUse_ab{$slot_i}:=True

		OTr_zUnlock

		$handle_i:=$slot_i

	End if

End if

OTr_zRemoveFromCallStack(Current method name)
