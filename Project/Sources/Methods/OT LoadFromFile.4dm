//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT LoadFromFile (inFilePath) --> Longint

// Reads a UTF-8 JSON file from disk and loads it into a
// new OTr handle. The file must have been written as a
// plain UTF-8 JSON text file (e.g. by OT SaveToFile).

// **NOTE:** there is no equivalent Object Tools command

// Access: Shared

// Parameters:
//   $inFilePath_t : Text : Full path of the source file

// Returns:
//   $handle_i : Integer : New OTr handle, 
//                         or 0 if loading failed

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-12 - Added OTr_z_Error on file-not-found so that
//     callers can detect the error via OK=0.
// ----------------------------------------------------

#DECLARE($inFilePath_t : Text)->$handle_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $json_t : Text

$handle_i:=0

If (Test path name:C476($inFilePath_t)=Is a document:K24:1)
	$json_t:=Document to text:C1236($inFilePath_t; "UTF-8")
	$handle_i:=OT LoadFromText($json_t)
Else 
	OTr_z_Error("File not found: "+$inFilePath_t; Current method name:C684)
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
