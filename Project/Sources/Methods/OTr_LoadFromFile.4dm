//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_LoadFromFile (inFilePath) --> Longint

// Reads a UTF-8 JSON file from disk and loads it into a
// new OTr handle. The file must have been written as a
// plain UTF-8 JSON text file (e.g. by OTr_SaveToFile).
// Delegates all parsing to OTr_LoadFromText, including
// BOM stripping and top-level array wrapping.
// Returns 0 if the file does not exist or contains
// invalid JSON.

// Access: Shared

// Parameters:
//   $inFilePath_t : Text : Full path of the source file

// Returns:
//   $handle_i : Integer : New OTr handle, \
//                         or 0 if loading failed

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inFilePath_t : Text)->$handle_i : Integer

OTr_zAddToCallStack(Current method name)

var $json_t : Text

$handle_i:=0

If (Test path name($inFilePath_t)=Is a document)
	$json_t:=Document to text($inFilePath_t; "UTF-8")
	$handle_i:=OTr_LoadFromText($json_t)
End if

OTr_zRemoveFromCallStack(Current method name)
