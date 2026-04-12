//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToBlob (inObject) --> Blob

// Serialises the stored object to a compressed 4D-native blob
// using VARIABLE TO BLOB and GZIP compression. The format is
// 4D-internal and is not portable outside 4D. Use
// OTr_SaveToGZIP when portability across systems is required.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject

// Returns:
//   $outBlob_blob : Blob : Compressed 4D-native blob, \
//                          or empty blob if the handle is invalid

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)->$outBlob_blob : Blob

OTr_z_AddToCallStack(Current method name:C684)

var $snapshot_o : Object
var $valid_b : Boolean

$valid_b:=False:C215

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	$snapshot_o:=OB Copy:C1225(<>OTR_Objects_ao{$inObject_i})
	$valid_b:=True:C214
End if 

OTr_z_Unlock

If ($valid_b)
	VARIABLE TO BLOB:C532($snapshot_o; $outBlob_blob)
	COMPRESS BLOB:C534($outBlob_blob; GZIP best compression mode:K22:18)
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
