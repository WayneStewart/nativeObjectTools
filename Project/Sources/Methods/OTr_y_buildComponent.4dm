//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_y_buildComponent

// Headless CI build wrapper.
// Called from On Startup when 4D is launched with --headless.
// Updates Resources/InfoPlist.json and InfoPlist.strings with the current
// version from OTr_Info, then calls BUILD APPLICATION with the appropriate
// settings file from Release/BuildSettings/.

// Access: Private

// Parameters:
//   $variant_t     : Text : e.g. "OTr" or "OT"
//   $4dVersion_t   : Text : e.g. "19", "20", "21"
//   $sentinelDir_t : Text : POSIX path to folder where sentinel file is written

// This method is stripped from Koala/Platypus by the exclusions manifest.
// It shouldn't ship with the component.

// Created by Wayne Stewart, 2026-04-21
// ----------------------------------------------------

#DECLARE($variant_t : Text; $4dVersion_t : Text; $sentinelDir_t : Text)

var $settingsPath_t; $sentinelPath_t; $sentinel_t; $version_t : Text
var $infoPlistPath_t; $stringsPath_t; $json_t; $strings_t; $LF; $year_t : Text
var $info_o : Object

$version_t:=OTr_Info("version")
LOG ADD ENTRY(Current method name:C684; "version"; $version_t)

//MARK: Update InfoPlist.json and InfoPlist.strings

$infoPlistPath_t:=Get 4D folder:C485(Current resources folder:K5:16)+"InfoPlist.json"

If (Test path name:C476($infoPlistPath_t)=Is a document:K24:1)
	
	$LF:=Char:C90(Line feed:K15:40)
	$year_t:=Substring:C12(OTr_z_timestampLocal; 1; 10)
	
	$json_t:=Document to text:C1236($infoPlistPath_t)
	$info_o:=JSON Parse:C1218($json_t)
	
	$info_o.CFBundleShortVersionString:=$version_t
	$info_o.CFBundleGetInfoString:=$info_o.CFBundleName+" "+$version_t+" (4D "+$4dVersion_t+" LTS), "+$year_t
	
	$json_t:=JSON Stringify:C1217($info_o; *)
	DELETE DOCUMENT:C159($infoPlistPath_t)
	TEXT TO DOCUMENT:C1237($infoPlistPath_t; $json_t; "UTF-8"; Document with LF:K24:22)
	LOG ADD ENTRY(Current method name:C684; "InfoPlist.json updated"; $version_t)
	
	// Update the .strings document (this is the one used by Get Info)
	$strings_t:="/* Localized versions of Info.plist keys */"+$LF+$LF
	$strings_t:=$strings_t+"CFBundleName = \""+$info_o.CFBundleName+"\";"+$LF
	$strings_t:=$strings_t+"CFBundleShortVersionString = \""+$info_o.CFBundleShortVersionString+"\";"+$LF
	$strings_t:=$strings_t+"CFBundleGetInfoString = \""+$info_o.CFBundleGetInfoString+"\";"+$LF
	
	$stringsPath_t:=Get 4D folder:C485(Current resources folder:K5:16)+"InfoPlist.strings"
	If (Test path name:C476($stringsPath_t)=Is a document:K24:1)
		DELETE DOCUMENT:C159($stringsPath_t)
	End if 
	TEXT TO DOCUMENT:C1237($stringsPath_t; $strings_t; "UTF-8"; Document with LF:K24:22)
	LOG ADD ENTRY(Current method name:C684; "InfoPlist.strings updated")
	
Else 
	LOG ADD ENTRY(Current method name:C684; "InfoPlist.json not found"; $infoPlistPath_t)
	
End if 

//MARK: Compile (universal — arm64 + x86_64)

LOG ADD ENTRY(Current method name:C684; "Compile start")
OTr_y_testCompilation($sentinelDir_t)
LOG ADD ENTRY(Current method name:C684; "Compile done")

//MARK: Write documentation (public methods only — as shipped)

LOG ADD ENTRY(Current method name:C684; "WriteDocumentation start")
Fnd_FCS_WriteDocumentation(""; True:C214; True:C214; True:C214; True:C214)
LOG ADD ENTRY(Current method name:C684; "WriteDocumentation done")

//MARK: Build

$settingsPath_t:=Get 4D folder:C485(Database folder:K5:14)+"Release"+Folder separator:K24:12+"BuildSettings"+Folder separator:K24:12+"buildApp-"+$4dVersion_t+"-"+$variant_t+".4DSettings"

LOG ADD ENTRY(Current method name:C684; "settings path"; $settingsPath_t)

BUILD APPLICATION:C871($settingsPath_t)

LOG ADD ENTRY(Current method name:C684; "BUILD APPLICATION done"; "OK"; String:C10(OK))

//MARK: Write sentinel

$sentinelPath_t:=Convert path POSIX to system:C1107($sentinelDir_t)+"build-"+$version_t+"-"+$variant_t+".txt"

If (OK=1)
	$sentinel_t:="build-"+$version_t+"-"+$variant_t+" passed"
Else 
	$sentinel_t:="build-"+$version_t+"-"+$variant_t+" failed"
End if 

LOG ADD ENTRY(Current method name:C684; "sentinel"; $sentinel_t)
TEXT TO DOCUMENT:C1237($sentinelPath_t; $sentinel_t; "UTF-8"; Document with LF:K24:22)
LOG ADD ENTRY(Current method name:C684; "sentinel written"; $sentinelPath_t)
