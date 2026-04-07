//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToGZIP (inObject {; inPrettyPrint}) --> Blob

// Serialises the stored object to a UTF-8 JSON string and
// compresses it with GZIP, returning the result in a blob.
// Suitable for compact network transmission or file storage
// where portability outside 4D is required.

// Access: Shared

// Parameters:
//   $inObject_i      : Integer : OTr inObject
//   $inPrettyPrint_b : Boolean : True for indented output; \
//                                default False (optional)

// Returns:
//   $outBlob_blob : Blob : GZIPed JSON blob, \
//                          or empty blob if the handle is invalid

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inPrettyPrint_b : Boolean)->$outBlob_blob : Blob

OTr_zAddToCallStack(Current method name)

var $snapshot_o : Object
var $json_t : Text
var $valid_b : Boolean

If (Count parameters < 2)
	$inPrettyPrint_b:=False
End if

$valid_b:=False

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	$snapshot_o:=OB Copy(<>OTR_Objects_ao{$inObject_i})
	$valid_b:=True
End if

OTr_zUnlock

If ($valid_b)
	If ($inPrettyPrint_b)
		$json_t:=JSON Stringify($snapshot_o; *)
	Else
		$json_t:=JSON Stringify($snapshot_o)
	End if

	CONVERT FROM TEXT($json_t; UTF8 text without length; $outBlob_blob)
	COMPRESS BLOB($outBlob_blob; GZIP best compression mode)
End if

OTr_zRemoveFromCallStack(Current method name)
