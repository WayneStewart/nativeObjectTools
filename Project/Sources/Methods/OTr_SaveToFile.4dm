//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToFile (inObject; inFilePath {; inPrettyPrint})

// Serialises the stored object to a UTF-8 JSON file on disk.
// Existing files are overwritten without warning.

// Note: TEXT TO DOCUMENT with "UTF-8" writes a BOM at the start
//   of the file. This is harmless for inspection purposes; if
//   you later parse the file with JSON Parse, 4D handles the
//   BOM correctly for locally written files.

// Access: Shared

// Parameters:
//   $inObject_i      : Integer : OTr inObject
//   $inFilePath_t    : Text    : Full path of the target file (inFilePath)
//   $inPrettyPrint_b : Boolean : True for indented output; default True (optional)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inFilePath_t : Text; $inPrettyPrint_b : Boolean)

OTr_zAddToCallStack(Current method name:C684)


var $snapshot_o : Object
var $json_t : Text
var $valid_b : Boolean
var $prettyPrint_b : Boolean

If (Count parameters:C259<3)
	$prettyPrint_b:=True:C214
Else
	$prettyPrint_b:=$inPrettyPrint_b
End if

$valid_b:=False:C215

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	$snapshot_o:=OB Copy:C1225(<>OTR_Objects_ao{$inObject_i})
	$valid_b:=True:C214
End if

OTr_zUnlock

If ($valid_b)
	If ($prettyPrint_b)
		$json_t:=JSON Stringify:C1217($snapshot_o; *)
	Else 
		$json_t:=JSON Stringify:C1217($snapshot_o)
	End if 
	
	TEXT TO DOCUMENT:C1237($inFilePath_t; $json_t; "UTF-8")
End if 

OTr_zRemoveFromCallStack(Current method name:C684)
