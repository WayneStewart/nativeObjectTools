//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: __BuildComponent_Headless

// Headless CI wrapper for Fnd_FCS_BuildComponent.
// Called from On Startup when 4D is launched with --headless --user-param "build".
//
// Reads RELEASE_VARIANT (OTr or OT) and RELEASE_VERSION from the environment,
// copies the appropriate buildApp.4DSettings into the project's Settings/ folder,
// calls BUILD APPLICATION, writes a sentinel file, then calls QUIT 4D.
//
// This method is stripped from Koala/Platypus by the exclusions manifest.
// It must never ship with the component.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-21
// ----------------------------------------------------

var $variant_t; $version_t; $stderr_t : Text
var $settingsSource_t; $settingsDest_t; $settingsDir_t : Text
var $sentinelDir_t; $sentinelPath_t; $sentinel_t : Text
var $buildSettingsPath_t : Text
var $appInfo_o : Object

//MARK: Read environment variables

LAUNCH EXTERNAL PROCESS("printenv RELEASE_VARIANT"; $variant_t; $stderr_t)
$variant_t:=Replace string($variant_t; Char(10); "")  // strip trailing newline

LAUNCH EXTERNAL PROCESS("printenv RELEASE_VERSION"; $version_t; $stderr_t)
$version_t:=Replace string($version_t; Char(10); "")

LAUNCH EXTERNAL PROCESS("printenv SENTINEL_DIR"; $sentinelDir_t; $stderr_t)
$sentinelDir_t:=Replace string($sentinelDir_t; Char(10); "")

If (Length($variant_t)=0)
	$variant_t:="OTr"  // safe default for manual testing
End if

If (Length($sentinelDir_t)=0)
	$sentinelDir_t:=Get 4D folder(Database folder)  // fallback for manual testing
End if

//MARK: Copy the correct buildApp.4DSettings into Settings/

// Settings file is at Release/BuildSettings/buildApp-VERSION-VARIANT.4DSettings
// relative to the database (project) folder.
$settingsSource_t:=Get 4D folder(Database folder)+"Release"+Folder separator+"BuildSettings"+Folder separator+"buildApp-"+$version_t+"-"+$variant_t+".4DSettings"
$settingsDir_t:=Get 4D folder(Database folder)+"Settings"+Folder separator
$settingsDest_t:=$settingsDir_t+"buildApp.4DSettings"

If (Test path name($settingsSource_t)#Is a document)
	// Source settings file not found — write failure sentinel and quit
	$sentinelPath_t:=$sentinelDir_t+"build-"+$version_t+"-"+$variant_t+".txt"
	TEXT TO DOCUMENT($sentinelPath_t; "build-"+$version_t+"-"+$variant_t+" failed"+Char(10)+"Settings file not found: "+$settingsSource_t; "UTF-8"; Document with LF)
	QUIT 4D
End if

If (Test path name($settingsDir_t)#Is a folder)
	CREATE FOLDER($settingsDir_t; *)
End if

COPY DOCUMENT($settingsSource_t; $settingsDest_t; *)

//MARK: Update version in InfoPlist.json

var $templatePath_t; $json_t; $date_t; $year_t; $strings_t; $LF : Text
var $info_o : Object

$templatePath_t:=Get 4D folder(Current resources folder)+"InfoPlist.json"
$LF:=Char(Line feed)

If (Test path name($templatePath_t)=Is a document)
	$json_t:=Document to text($templatePath_t)
	$info_o:=JSON Parse($json_t)
	$date_t:=Timestamp
	$year_t:=Substring($date_t; 1; 4)

	If (Length($version_t)>0)
		$info_o.CFBundleShortVersionString:=$version_t
		$info_o.CFBundleGetInfoString:=$info_o.CFBundleName+" "+$version_t+", "+$year_t

		$json_t:=JSON Stringify($info_o; *)
		If (Test path name($templatePath_t)=Is a document)
			DELETE DOCUMENT($templatePath_t)
		End if
		TEXT TO DOCUMENT($templatePath_t; $json_t; "UTF-8"; Document with LF)

		// Update InfoPlist.strings
		$strings_t:="/* Localized versions of Info.plist keys */"+$LF+$LF
		$strings_t:=$strings_t+"CFBundleName = \""+$info_o.CFBundleName+"\";"+$LF
		$strings_t:=$strings_t+"CFBundleShortVersionString = \""+$info_o.CFBundleShortVersionString+"\";"+$LF
		$strings_t:=$strings_t+"CFBundleGetInfoString = \""+$info_o.CFBundleGetInfoString+"\";"+$LF

		$templatePath_t:=Get 4D folder(Current resources folder)+"InfoPlist.strings"
		If (Test path name($templatePath_t)=Is a document)
			DELETE DOCUMENT($templatePath_t)
		End if
		TEXT TO DOCUMENT($templatePath_t; $strings_t; "UTF-8"; Document with LF)
	End if
End if

//MARK: Write documentation (inline, silent, public methods only — single pass)

Fnd_FCS_WriteDocumentation(""; True; True; True; True)

//MARK: Build

$buildSettingsPath_t:=Get 4D file(Build application settings file)
BUILD APPLICATION($buildSettingsPath_t)

//MARK: Write sentinel and quit

$sentinelPath_t:=$sentinelDir_t+"build-"+$version_t+"-"+$variant_t+".txt"

If (OK=1)
	$sentinel_t:="build-"+$version_t+"-"+$variant_t+" passed"+Char(10)
Else
	$sentinel_t:="build-"+$version_t+"-"+$variant_t+" failed"+Char(10)
End if

TEXT TO DOCUMENT($sentinelPath_t; $sentinel_t; "UTF-8"; Document with LF)

QUIT 4D
