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

OTr_zAddToCallStack(Current method name)

var $snapshot_o : Object
var $valid_b : Boolean

$valid_b:=False

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	$snapshot_o:=OB Copy(<>OTR_Objects_ao{$inObject_i})
	$valid_b:=True
End if

OTr_zUnlock

If ($valid_b)
	VARIABLE TO BLOB($snapshot_o; $outBlob_blob)
	COMPRESS BLOB($outBlob_blob; GZIP best compression mode)
End if

OTr_zRemoveFromCallStack(Current method name)
