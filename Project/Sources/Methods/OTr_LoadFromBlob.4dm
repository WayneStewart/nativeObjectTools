//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_LoadFromBlob (inBlob) --> Longint

// Loads an object from a 4D-native blob (written by
// OTr_SaveToBlob) into a new OTr handle. The blob is
// expanded automatically if it is compressed before
// reading via BLOB TO VARIABLE.
// Returns 0 if the blob is empty or cannot be decoded.

// **NOTE:** there is no equivalent Object Tools command

// Access: Shared

// Parameters:
//   $inBlob_blob : Blob : Compressed 4D-native blob \
//                         (from OTr_SaveToBlob)

// Returns:
//   $handle_i : Integer : New OTr handle, \
//                         or 0 if loading failed

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob)->$handle_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $loaded_o : Object
var $slot_i : Integer
var $compressed_i : Integer

$handle_i:=0

If (BLOB size:C605($inBlob_blob)>0)
	
	BLOB PROPERTIES:C536($inBlob_blob; $compressed_i)
	If ($compressed_i#Is not compressed:K22:11)
		EXPAND BLOB:C535($inBlob_blob)
	End if 
	
	BLOB TO VARIABLE:C533($inBlob_blob; $loaded_o)
	
	If ($loaded_o#Null:C1517)
		
		OTr_z_Lock
		
		$slot_i:=Find in array:C230(<>OTR_InUse_ab; False:C215)
		If ($slot_i=-1)
			$slot_i:=Size of array:C274(<>OTR_InUse_ab)+1
			INSERT IN ARRAY:C227(<>OTR_InUse_ab; $slot_i)
			INSERT IN ARRAY:C227(<>OTR_Objects_ao; $slot_i)
		End if 
		
		<>OTR_Objects_ao{$slot_i}:=OB Copy:C1225($loaded_o)
		<>OTR_InUse_ab{$slot_i}:=True:C214
		
		OTr_z_Unlock
		
		$handle_i:=$slot_i
		
	End if 
	
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
