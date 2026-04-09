//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT LoadFromClipboard () --> Longint

// Reads a JSON string from the system clipboard and loads
// it into a new OTr handle. Delegates all parsing to
// OT LoadFromText, including BOM stripping and top-level
// array wrapping.
// Returns 0 if the clipboard contains no text or invalid JSON.

// Access: Shared

// Returns:
//   $handle_i : Integer : New OTr handle, \
//                         or 0 if loading failed

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE()->$handle_i : Integer

OTr_zAddToCallStack(Current method name)

var $json_t : Text

$json_t:=Get text from pasteboard
$handle_i:=OT LoadFromText($json_t)

OTr_zRemoveFromCallStack(Current method name)
