//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: ____Make_Phase16_OTBlobFixtures

// Generates transportable legacy ObjectTools BLOB fixture files used by
// the Phase 16 master-suite sample tests.
//
// This method requires the legacy ObjectTools plugin. It should be run
// only on a developer machine that can create OT ObjectToNewBLOB output.
// The generated BLOBs are written to Resources/blobs so they travel with
// the component package and can be imported on systems without the plugin.
//
// Access: Private
//
// Parameters:
//   $suppressAlert_b : Boolean : Optional. True to suppress final ALERT.
//
// Returns: Nothing
//
// Created by Wayne Stewart / Codex, 2026-04-15
// Wayne Stewart / Codex, 2026-04-15 - Added fixture generator for plugin-free master tests.
// ----------------------------------------------------

#DECLARE($suppressAlert_b : Boolean)

OTr_z_AddToCallStack(Current method name:C684)

var $hideAlert_b : Boolean
If (Count parameters:C259<1)
	$hideAlert_b:=False:C215
Else
	$hideAlert_b:=$suppressAlert_b
End if

var $reg_i : Integer
var $rootOT_i; $level1OT_i; $level2OT_i; $level3OT_i; $siblingOT_i : Integer
var $resourcesPath_t; $blobFolderPath_t; $outPath_t; $summary_t : Text
var $docPath_t : Text
var $legacyBlob_blob; $testBlob_blob; $docBlob_blob : Blob
var $testPic_pic : Picture

ARRAY TEXT:C222($textArray_at; 0)
ARRAY LONGINT:C221($longArray_ai; 0)
ARRAY BOOLEAN:C223($booleanArray_ab; 0)

$resourcesPath_t:=Get 4D folder:C485(Current resources folder:K5:16)
$blobFolderPath_t:=$resourcesPath_t+"blobs"+Folder separator:K24:12
CREATE FOLDER:C475($blobFolderPath_t; *)

$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")
$rootOT_i:=OT New
If ($rootOT_i=0)
	$summary_t:="Phase 16 OT BLOB fixture generation skipped: ObjectTools 5.0 is not available or not registered."
Else
	OT Clear($rootOT_i)
	
	// Deep mixed object with DOCX BLOB and JPG picture.
	ARRAY TEXT:C222($textArray_at; 3)
	$textArray_at{1}:="deep-alpha"
	$textArray_at{2}:="deep-bravo"
	$textArray_at{3}:="deep-charlie"
	ARRAY LONGINT:C221($longArray_ai; 3)
	$longArray_ai{1}:=10
	$longArray_ai{2}:=-20
	$longArray_ai{3}:=3000
	ARRAY BOOLEAN:C223($booleanArray_ab; 3)
	$booleanArray_ab{1}:=True:C214
	$booleanArray_ab{2}:=False:C215
	$booleanArray_ab{3}:=True:C214
	SET BLOB SIZE:C606($testBlob_blob; 5)
	$testBlob_blob{0}:=1
	$testBlob_blob{1}:=2
	$testBlob_blob{2}:=0
	$testBlob_blob{3}:=255
	$testBlob_blob{4}:=42
	$docPath_t:=$resourcesPath_t+"1 Corinthians 1.docx"
	DOCUMENT TO BLOB:C525($docPath_t; $docBlob_blob)
	$testPic_pic:=OTr_z_Echidna
	
	$rootOT_i:=OT New
	$level1OT_i:=OT New
	$level2OT_i:=OT New
	$level3OT_i:=OT New
	OT PutText($rootOT_i; "rootText"; "root")
	OT PutText($level1OT_i; "level1Text"; "level1")
	OT PutLong($level2OT_i; "level2Long"; -12345)
	OT PutText($level3OT_i; "Citem"; "deep text")
	OT PutReal($level3OT_i; "amount"; 123.456)
	OT PutBoolean($level3OT_i; "flag"; Num:C11(True:C214))
	OT PutDate($level3OT_i; "when"; !2026-04-14!)
	OT PutTime($level3OT_i; "clock"; ?12:34:56?)
	OT PutBLOB($level3OT_i; "data"; $testBlob_blob)
	OT PutBLOB($level3OT_i; "document"; $docBlob_blob)
	OT PutPicture($level3OT_i; "photo"; $testPic_pic)
	OT PutArray($level3OT_i; "names"; $textArray_at)
	OT PutArray($level3OT_i; "numbers"; $longArray_ai)
	OT PutArray($level3OT_i; "flags"; $booleanArray_ab)
	OT PutObject($level2OT_i; "cObject"; $level3OT_i)
	OT PutObject($level1OT_i; "bObject"; $level2OT_i)
	OT PutObject($rootOT_i; "AnObject"; $level1OT_i)
	$legacyBlob_blob:=OT ObjectToNewBLOB($rootOT_i)
	$outPath_t:=$blobFolderPath_t+"Phase16-master-deep-mixed-docx.blob"
	BLOB TO DOCUMENT:C526($outPath_t; $legacyBlob_blob)
	OT Clear($level3OT_i)
	OT Clear($level2OT_i)
	OT Clear($level1OT_i)
	OT Clear($rootOT_i)
	
	// Sibling deep object fixture for order and dotted-path coverage.
	ARRAY TEXT:C222($textArray_at; 2)
	$textArray_at{1}:="left-one"
	$textArray_at{2}:="left-two"
	ARRAY LONGINT:C221($longArray_ai; 2)
	$longArray_ai{1}:=-1
	$longArray_ai{2}:=-2
	
	$rootOT_i:=OT New
	$level1OT_i:=OT New
	$level2OT_i:=OT New
	$level3OT_i:=OT New
	$siblingOT_i:=OT New
	OT PutText($rootOT_i; "before"; "before-value")
	OT PutArray($level1OT_i; "leftNames"; $textArray_at)
	OT PutText($level2OT_i; "middle"; "middle-value")
	OT PutArray($level3OT_i; "negativeNumbers"; $longArray_ai)
	OT PutText($level3OT_i; "leaf"; "leaf-value")
	OT PutObject($level2OT_i; "third"; $level3OT_i)
	OT PutObject($level1OT_i; "second"; $level2OT_i)
	OT PutObject($rootOT_i; "first"; $level1OT_i)
	OT PutText($siblingOT_i; "siblingText"; "sibling-value")
	OT PutLong($siblingOT_i; "siblingLong"; 777)
	OT PutObject($rootOT_i; "sibling"; $siblingOT_i)
	OT PutText($rootOT_i; "after"; "after-value")
	$legacyBlob_blob:=OT ObjectToNewBLOB($rootOT_i)
	$outPath_t:=$blobFolderPath_t+"Phase16-master-sibling-deep-ordering.blob"
	BLOB TO DOCUMENT:C526($outPath_t; $legacyBlob_blob)
	OT Clear($siblingOT_i)
	OT Clear($level3OT_i)
	OT Clear($level2OT_i)
	OT Clear($level1OT_i)
	OT Clear($rootOT_i)
	
	$summary_t:="Phase 16 OT BLOB fixtures generated in "+$blobFolderPath_t
End if

If (Not($hideAlert_b))
	ALERT:C41($summary_t)
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
