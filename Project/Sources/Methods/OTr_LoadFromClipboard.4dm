//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_LoadFromClipboard () --> Longint

// Reads a JSON string from the system clipboard and loads
// it into a new OTr handle. Delegates all parsing to
// OTr_LoadFromText, including BOM stripping and top-level
// array wrapping.
// Returns 0 if the clipboard contains no text or invalid JSON.

// Access: Shared

// Returns:
//   $handle_i : Integer : New OTr handle, 
//                         or 0 if loading failed

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE()->$handle_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $json_t : Text

$json_t:=Get text from pasteboard:C524
$handle_i:=OTr_LoadFromText($json_t)

OTr_z_RemoveFromCallStack(Current method name:C684)
