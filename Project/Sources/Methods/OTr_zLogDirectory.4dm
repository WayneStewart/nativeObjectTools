//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zLogDirectory () --> Text

// Returns the absolute path to the ObjectTools log folder.

// Access: Private

// Returns:
//   $outPath_t : Text : Absolute log folder path with trailing separator

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE()->$outPath_t : Text

$outPath_t:=Get 4D folder:C485(Logs folder:K5:19; *)+"ObjectTools"+Folder separator:K24:12

If (Test path name:C476($outPath_t)#Is a folder:K24:2)
	CREATE FOLDER:C475($outPath_t; *)
End if 
