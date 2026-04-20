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

GET ENVIRONMENT VARIABLE("RELEASE_VARIANT"; $variant_t)
GET ENVIRONMENT VARIABLE("RELEASE_4D_VERSION"; $version_t)

$sentinelName_t:="build-"+$version_t+"-"+$variant_t
$sentinelPath_t:=$sentinelDir_t+$sentinelName_t+".txt"
$ok_b:=False

// ---------------------------------------------------------------------------
// 1. Locate settings file in the staging tree (placed there by Release_compile)
//    Database folder = .../Release/OTr_Release/
//    Repo root = two levels up
// ---------------------------------------------------------------------------

$stagingDir_t:=Get 4D folder(Database folder)
$stagingDir_t:=Replace string($stagingDir_t; \
	"Release"+Folder separator+"OTr_Release"+Folder separator; "")

If ($variant_t="OTr")
	$stagingDir_t:=Replace string($stagingDir_t; \
		"nativeObjectTools"+Folder separator; \
		"staging-koala"+Folder separator)
Else
	$stagingDir_t:=Replace string($stagingDir_t; \
		"nativeObjectTools"+Folder separator; \
		"staging-platypus"+Folder separator)
End if

$settingsPath_t:=$stagingDir_t+"Settings"+Folder separator+"buildApp.4DSettings"

If (Test path name($settingsPath_t)#Is a document)
	TEXT TO DOCUMENT($sentinelPath_t; \
		$sentinelName_t+" failed"+Char(13)+"buildApp.4DSettings not found — did Release_compile run first? Path: "+$settingsPath_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 2. Build
// ---------------------------------------------------------------------------

BUILD APPLICATION($settingsPath_t)

If (OK#1)
	TEXT TO DOCUMENT($sentinelPath_t; \
		$sentinelName_t+" failed"+Char(13)+"BUILD APPLICATION returned OK=0"; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 3. Write success sentinel
// ---------------------------------------------------------------------------

TEXT TO DOCUMENT($sentinelPath_t; $sentinelName_t+" passed"; "UTF-8")
$ok_b:=True
