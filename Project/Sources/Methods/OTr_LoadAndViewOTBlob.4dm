//%attributes = {"shared":true}
// ----------------------------------------------------
// Project Method: OTr_LoadAndViewOTBlob

// Opens a system document picker so you can select a legacy blob saved to disk.
// It then opens (or brings to the front) the Object JSON viewer

// Access: Shared

// Parameters: None

// Created by Wayne Stewart (2026-04-22)
// ----------------------------------------------------


var $Options_i; $newHandle_i : Integer
var $FolderPath_t; $DocumentName_t; $DocumentPath_t : Text
var $import_blob : Blob

ARRAY TEXT:C222($paths_at; 0)

// look up file
$Options_i:=Allow alias files:K24:10+Package open:K24:8+Use sheet window:K24:11
$FolderPath_t:=System folder:C487(Desktop:K41:16)

$DocumentName_t:=Select document:C905(23; ""; "Select a Blob"; $Options_i; $paths_at)


// Import the blob
If ($DocumentName_t#"")
	// Get the path
	$DocumentPath_t:=String:C10($paths_at{1})
	
	DOCUMENT TO BLOB:C525($DocumentPath_t; $import_blob)
	
	$newHandle_i:=OTr_BLOBToObject($import_blob)
	
	If ($newHandle_i=0)
		ALERT:C41("Something went wrong")
		
	Else 
		OTr_ObjectViewer
		
	End if 
	
	
End if 
