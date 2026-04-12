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

OTr_z_AddToCallStack(Current method name:C684)

var $snapshot_o : Object
var $json_t : Text
var $valid_b : Boolean
var $prettyPrint_b : Boolean

If (Count parameters:C259<2)
	$prettyPrint_b:=False:C215
Else 
	$prettyPrint_b:=$inPrettyPrint_b
End if 

$valid_b:=False:C215

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	$snapshot_o:=OB Copy:C1225(<>OTR_Objects_ao{$inObject_i})
	$valid_b:=True:C214
End if 

OTr_z_Unlock

If ($valid_b)
	If ($prettyPrint_b)
		$json_t:=JSON Stringify:C1217($snapshot_o; *)
	Else 
		$json_t:=JSON Stringify:C1217($snapshot_o)
	End if 
	
	CONVERT FROM TEXT:C1011($json_t; UTF8 text without length:K22:17; $outBlob_blob)
	COMPRESS BLOB:C534($outBlob_blob; GZIP best compression mode:K22:18)
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
