//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Release_build ($sentinelDir_t) --> Boolean
//
// Builds a compiled component using BUILD APPLICATION.
// The variant and 4D version are read from the RELEASE_VARIANT and
// RELEASE_4D_VERSION environment variables set by the workflow.
// Expects Release_compile to have already run for this variant/version.
//
// Parameters:
//   $sentinelDir_t : Text : Absolute path to directory for sentinel files
//
// Returns:
//   $ok_b : Boolean : True if stage passed, False if failed
//
// Sentinel file: <sentinelDir>/build-<version>-<variant>.txt
//   e.g. build-20-OTr.txt
// ----------------------------------------------------

#DECLARE($sentinelDir_t : Text)->$ok_b : Boolean

var $sentinelPath_t : Text
var $variant_t : Text
var $version_t : Text
var $sentinelName_t : Text
var $settingsPath_t : Text
var $stagingDir_t : Text

GET ENVIRONMENT VARIABLE:C372("RELEASE_VARIANT"; $variant_t)
GET ENVIRONMENT VARIABLE:C372("RELEASE_4D_VERSION"; $version_t)

$sentinelName_t:="build-"+$version_t+"-"+$variant_t
$sentinelPath_t:=$sentinelDir_t+$sentinelName_t+".txt"
$ok_b:=False

// ---------------------------------------------------------------------------
// 1. Locate settings file in the staging tree (placed there by Release_compile)
//    Database folder = .../Release/OTr_Release/
//    Repo root = two levels up
// ---------------------------------------------------------------------------

$stagingDir_t:=Get 4D folder:C485(Database folder:K5:14)
$stagingDir_t:=Replace string:C233($stagingDir_t; \
	"Release"+Folder separator:K24:12+"OTr_Release"+Folder separator:K24:12; "")

If ($variant_t="OTr")
	$stagingDir_t:=Replace string:C233($stagingDir_t; \
		"nativeObjectTools"+Folder separator:K24:12; \
		"staging-koala"+Folder separator:K24:12)
Else
	$stagingDir_t:=Replace string:C233($stagingDir_t; \
		"nativeObjectTools"+Folder separator:K24:12; \
		"staging-platypus"+Folder separator:K24:12)
End if

$settingsPath_t:=$stagingDir_t+"Settings"+Folder separator:K24:12+"buildApp.4DSettings"

If (Test path name:C476($settingsPath_t)#Is a document:K24:1)
	TEXT TO DOCUMENT:C1237($sentinelPath_t; \
		$sentinelName_t+" failed"+Char:C90(13)+"buildApp.4DSettings not found — did Release_compile run first? Path: "+$settingsPath_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 2. Build
// ---------------------------------------------------------------------------

BUILD APPLICATION:C859($settingsPath_t)

If (OK:C265#1)
	TEXT TO DOCUMENT:C1237($sentinelPath_t; \
		$sentinelName_t+" failed"+Char:C90(13)+"BUILD APPLICATION returned OK=0"; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 3. Write success sentinel
// ---------------------------------------------------------------------------

TEXT TO DOCUMENT:C1237($sentinelPath_t; $sentinelName_t+" passed"; "UTF-8")
$ok_b:=True
