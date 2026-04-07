//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zLogDirectory () --> Text

// Returns the absolute path to the ObjectTools log folder.

// Access: Private

// Returns:
//   $outPath_t : Text : Absolute log folder path with trailing separator

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 logging directory helper.
// ----------------------------------------------------

#DECLARE()->$outPath_t : Text

$outPath_t:=Get 4D folder(Logs folder; *)+"ObjectTools"+Folder separator

If (Test path name($outPath_t)#Is a folder)
	CREATE FOLDER($outPath_t; *)
End if
