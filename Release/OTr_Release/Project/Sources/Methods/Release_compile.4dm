//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Release_compile ($sentinelDir_t) --> Boolean
//
// Compiles a staged component tree using Compile project.
// The variant and 4D version are read from the RELEASE_VARIANT and
// RELEASE_4D_VERSION environment variables set by the workflow.
//
// Parameters:
//   $sentinelDir_t : Text : Absolute path to directory for sentinel files
//
// Returns:
//   $ok_b : Boolean : True if stage passed, False if failed
//
// Sentinel file: <sentinelDir>/compile-<version>-<variant>.txt
//   e.g. compile-20-OTr.txt
// ----------------------------------------------------

#DECLARE($sentinelDir_t : Text)->$ok_b : Boolean

var $sentinelPath_t : Text
var $variant_t : Text
var $version_t : Text
var $sentinelName_t : Text
var $settingsPath_t : Text
var $stagingDir_t : Text
var $projectPath_t : Text
var $compileOptions_o : Object
var $compileResult_o : Object
var $errors_c : Collection
var $error_o : Object
var $errorDetail_t : Text
var $line_t : Text
var $i_i : Integer

GET ENVIRONMENT VARIABLE("RELEASE_VARIANT"; $variant_t)    // "OTr" or "OT"
GET ENVIRONMENT VARIABLE("RELEASE_4D_VERSION"; $version_t) // "19", "20", or "21"

$sentinelName_t:="compile-"+$version_t+"-"+$variant_t
$sentinelPath_t:=$sentinelDir_t+$sentinelName_t+".txt"
$ok_b:=False

// ---------------------------------------------------------------------------
// 1. Locate the appropriate buildApp settings file
//    Database folder = .../Release/OTr_Release/
//    Repo root = two levels up; settings live at repo-root/Release/BuildSettings/
// ---------------------------------------------------------------------------

$settingsPath_t:=Get 4D folder(Database folder)
$settingsPath_t:=Replace string($settingsPath_t; \
	"Release"+Folder separator+"OTr_Release"+Folder separator; "")
$settingsPath_t:=$settingsPath_t+"Release"+Folder separator+"BuildSettings"+Folder separator
$settingsPath_t:=$settingsPath_t+"buildApp-"+$version_t+"-"+$variant_t+".4DSettings"

If (Test path name($settingsPath_t)#Is a document)
	TEXT TO DOCUMENT($sentinelPath_t; \
		$sentinelName_t+" failed"+Char(13)+"Settings file not found: "+$settingsPath_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 2. Locate the staged project
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

$projectPath_t:=$stagingDir_t+"Project"+Folder separator+"nativeObjectTools.4DProject"

If (Test path name($projectPath_t)#Is a document)
	TEXT TO DOCUMENT($sentinelPath_t; \
		$sentinelName_t+" failed"+Char(13)+"Project file not found: "+$projectPath_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 3. Copy settings file into staging tree's Settings/ folder
// ---------------------------------------------------------------------------

$stagingDir_t:=$stagingDir_t+"Settings"+Folder separator
CREATE FOLDER($stagingDir_t; *)
COPY DOCUMENT($settingsPath_t; $stagingDir_t+"buildApp.4DSettings"; *)

// ---------------------------------------------------------------------------
// 4. Compile
// ---------------------------------------------------------------------------

$compileOptions_o:=New object
$compileOptions_o["path"]:=$projectPath_t
$compileOptions_o["targets"]:=New collection("x86_64_rosetta2"; "arm64")

$compileResult_o:=Compile project($compileOptions_o)

$errors_c:=$compileResult_o.errors.query("isError == :1"; True)

If ($errors_c.length>0)
	$errorDetail_t:=""
	For each ($error_o; $errors_c)
		$line_t:=$error_o.message+" ["+$error_o.methodName+":"+String($error_o.lineInMethod)+"]"
		$errorDetail_t:=$errorDetail_t+$line_t+Char(13)
	End for each
	TEXT TO DOCUMENT($sentinelPath_t; \
		$sentinelName_t+" failed"+Char(13)+$errorDetail_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 5. Write success sentinel
// ---------------------------------------------------------------------------

TEXT TO DOCUMENT($sentinelPath_t; $sentinelName_t+" passed"; "UTF-8")
$ok_b:=True
