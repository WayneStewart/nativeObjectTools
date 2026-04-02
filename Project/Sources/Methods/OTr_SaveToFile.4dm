//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToFile \
//   ($handle_i : Integer; $filePath_t : Text \
//   {; $prettyPrint_b : Boolean})

// Serialises the stored object to a UTF-8 JSON file on disk.
// Existing files are overwritten without warning.

// Note: TEXT TO DOCUMENT with "UTF-8" writes a BOM at the start
//   of the file. This is harmless for inspection purposes; if
//   you later parse the file with JSON Parse, 4D handles the
//   BOM correctly for locally written files.

// Access: Shared

// Parameters:
//   $handle_i      : Integer : OTr handle
//   $filePath_t    : Text    : Full path of the target file
//   $prettyPrint_b : Boolean : True for indented output; \
//                              default True (optional)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $filePath_t : Text; \
	$prettyPrint_b : Boolean)

var $snapshot_o : Object
var $json_t : Text
var $valid_b : Boolean

If (Count parameters < 3)
	$prettyPrint_b:=True
End if

$valid_b:=False

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	$snapshot_o:=OB Copy(<>OTR_Objects_ao{$handle_i})
	$valid_b:=True
End if

OTr_zUnlock

If ($valid_b)
	If ($prettyPrint_b)
		$json_t:=JSON Stringify($snapshot_o; *)
	Else
		$json_t:=JSON Stringify($snapshot_o)
	End if

	TEXT TO DOCUMENT($filePath_t; $json_t; "UTF-8")
End if
