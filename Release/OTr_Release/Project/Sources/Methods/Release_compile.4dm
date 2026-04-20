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

GET ENVIRONMENT VARIABLE:C372("RELEASE_VARIANT"; $variant_t)    // "OTr" or "OT"
GET ENVIRONMENT VARIABLE:C372("RELEASE_4D_VERSION"; $version_t) // "19", "20", or "21"

$sentinelName_t:="compile-"+$version_t+"-"+$variant_t
$sentinelPath_t:=$sentinelDir_t+$sentinelName_t+".txt"
$ok_b:=False

// ---------------------------------------------------------------------------
// 1. Locate the appropriate buildApp settings file
//    Database folder = .../Release/OTr_Release/
//    Repo root = two levels up; settings live at repo-root/Release/BuildSettings/
// ---------------------------------------------------------------------------

$settingsPath_t:=Get 4D folder:C485(Database folder:K5:14)
$settingsPath_t:=Replace string:C233($settingsPath_t; \
	"Release"+Folder separator:K24:12+"OTr_Release"+Folder separator:K24:12; "")
$settingsPath_t:=$settingsPath_t+"Release"+Folder separator:K24:12+"BuildSettings"+Folder separator:K24:12
$settingsPath_t:=$settingsPath_t+"buildApp-"+$version_t+"-"+$variant_t+".4DSettings"

If (Test path name:C476($settingsPath_t)#Is a document:K24:1)
	TEXT TO DOCUMENT:C1237($sentinelPath_t; \
		$sentinelName_t+" failed"+Char:C90(13)+"Settings file not found: "+$settingsPath_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 2. Locate the staged project
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

$projectPath_t:=$stagingDir_t+"Project"+Folder separator:K24:12+"nativeObjectTools.4DProject"

If (Test path name:C476($projectPath_t)#Is a document:K24:1)
	TEXT TO DOCUMENT:C1237($sentinelPath_t; \
		$sentinelName_t+" failed"+Char:C90(13)+"Project file not found: "+$projectPath_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 3. Copy settings file into staging tree's Settings/ folder
// ---------------------------------------------------------------------------

$stagingDir_t:=$stagingDir_t+"Settings"+Folder separator:K24:12
CREATE FOLDER:C475($stagingDir_t; *)
COPY DOCUMENT:C541($settingsPath_t; $stagingDir_t+"buildApp.4DSettings"; *)

// ---------------------------------------------------------------------------
// 4. Compile
// ---------------------------------------------------------------------------

$compileOptions_o:=New object:C1471
$compileOptions_o["path"]:=$projectPath_t
$compileOptions_o["targets"]:=New collection:C1472("x86_64_rosetta2"; "arm64")

$compileResult_o:=Compile project:C1581($compileOptions_o)

$errors_c:=$compileResult_o.errors.query("isError == :1"; True)

If ($errors_c.length>0)
	$errorDetail_t:=""
	For each ($error_o; $errors_c)
		$line_t:=$error_o.message+" ["+$error_o.methodName+":"+String:C10($error_o.lineInMethod)+"]"
		$errorDetail_t:=$errorDetail_t+$line_t+Char:C90(13)
	End for each
	TEXT TO DOCUMENT:C1237($sentinelPath_t; \
		$sentinelName_t+" failed"+Char:C90(13)+$errorDetail_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 5. Write success sentinel
// ---------------------------------------------------------------------------

TEXT TO DOCUMENT:C1237($sentinelPath_t; $sentinelName_t+" passed"; "UTF-8")
$ok_b:=True
