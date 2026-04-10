//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_LoadFromXMLFile (inFilePath) --> Longint

// Reads a UTF-8 XML file from disk (written by OTr_SaveToXMLFile)
// and loads it into a new OTr handle using DOM parsing.
// Returns 0 if the file does not exist or contains invalid XML.
//
// Delegates all parsing to OTr_LoadFromXML, including BOM stripping.

// Access: Shared

// Parameters:
//   $inFilePath_t : Text : Full path of the source file

// Returns:
//   $handle_i : Integer : New OTr handle, or 0 if loading failed

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inFilePath_t : Text)->$handle_i : Integer

OTr_zAddToCallStack(Current method name)

var $xml_t : Text

$handle_i:=0

If (Test path name($inFilePath_t)=Is a document)
	$xml_t:=Document to text($inFilePath_t; "UTF-8")
	$handle_i:=OTr_LoadFromXML($xml_t)
End if

OTr_zRemoveFromCallStack(Current method name)
