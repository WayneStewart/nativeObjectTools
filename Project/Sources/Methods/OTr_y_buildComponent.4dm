//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: __BuildComponent_Headless

// Headless CI build wrapper.
// Called from On Startup when 4D is launched with --headless.
// Constructs the path to the appropriate buildApp.4DSettings in Release/BuildSettings/,
// passes it directly to BUILD APPLICATION, and writes a sentinel file.

// Access: Private

// Parameters:
//   $variant_t    : Text : e.g. "OTr" or "OT"
//   $4dVersion_t  : Text : e.g. "19", "20", "21"
//   $sentinelDir_t : Text : POSIX path to folder where sentinel file is written

// This method is stripped from Koala/Platypus by the exclusions manifest.
// It must never ship with the component.

// Created by Wayne Stewart, 2026-04-21
// ----------------------------------------------------

#DECLARE($variant_t : Text; $4dVersion_t : Text; $sentinelDir_t : Text)

var $settingsPath_t; $sentinelPath_t; $sentinel_t; $version_t : Text

$version_t:=OTr_Info("version")

//MARK: Build

$settingsPath_t:=Get 4D folder(Database folder)+"Release"+Folder separator+"BuildSettings"+Folder separator+"buildApp-"+$4dVersion_t+"-"+$variant_t+".4DSettings"
BUILD APPLICATION($settingsPath_t)

//MARK: Write sentinel

$sentinelPath_t:=Convert path POSIX to system($sentinelDir_t)+"build-"+$version_t+"-"+$variant_t+".txt"

If (OK=1)
	$sentinel_t:="build-"+$version_t+"-"+$variant_t+" passed"
Else
	$sentinel_t:="build-"+$version_t+"-"+$variant_t+" failed"
End if

TEXT TO DOCUMENT($sentinelPath_t; $sentinel_t; "UTF-8"; Document with LF)
