//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: Fnd_FCS_BuildComponent

// Builds the Foundation component

// Access: Private

// Parameters: 
//   $versionNumber_t : Text : Version Number

// Created by Wayne Stewart (2021-08-10)
// Wayne Stewart 2026-03-30: Swapped to new #DECLARE() format
// ----------------------------------------------------

#DECLARE($versionNumber_t : Text)

var $templatePath_t; $json_t; $date_t; $year_t; $enteredValue_t; $archive_t : Text
var $buildSettingsPath_t; $buildFolderPath_t; $LF; $strings_t; $builtComponent_t; $newName_t; $templateSettings_t : Text
var $info_o : Object

//MARK: Update the version info
$templatePath_t:=Get 4D folder:C485(Current resources folder:K5:16)+"InfoPlist.json"
If (Test path name:C476($templatePath_t)=Is a document:K24:1)
	$LF:=Char:C90(Line feed:K15:40)
	$json_t:=Document to text:C1236($templatePath_t)
	$info_o:=JSON Parse:C1218($json_t)
	$date_t:=Timestamp:C1445
	$year_t:=Substring:C12($date_t; 1; 4)
	
	If (Count parameters:C259=1)
		OK:=1
	Else 
		$enteredValue_t:=Request:C163("Please enter the new version number:"; \
			$info_o.CFBundleShortVersionString; \
			"OK"; "Cancel")
		If (OK=1)
			$versionNumber_t:=$enteredValue_t
		End if 
	End if 
	
Else 
	OK:=0
	
	
End if 

//MARK: Build the InfoPlist.strings
If (OK=1)
	// Update the json
	$info_o.CFBundleShortVersionString:=$versionNumber_t
	$info_o.CFBundleGetInfoString:=$info_o.CFBundleName+" "+$versionNumber_t+", "+$year_t
	//$info_o.NSHumanReadableCopyright:="Copyright © 2007-"+$year_t+", Wayne Stewart, portions by Cannon Smith and Rob Laveaux"
	
	$json_t:=JSON Stringify:C1217($info_o; *)
	If (Test path name:C476($templatePath_t)=Is a document:K24:1)
		DELETE DOCUMENT:C159($templatePath_t)
	End if 
	TEXT TO DOCUMENT:C1237($templatePath_t; $json_t; "UTF-8"; Document with LF:K24:22)
	
	// Update the .strings document (this is the one used by Get Info)
	$strings_t:="/* Localized versions of Info.plist keys */"+$LF+$LF
	$strings_t:=$strings_t+"CFBundleName = \""+$info_o.CFBundleName+"\";"+$LF
	$strings_t:=$strings_t+"CFBundleShortVersionString = \""+$info_o.CFBundleShortVersionString+"\";"+$LF
	$strings_t:=$strings_t+"CFBundleGetInfoString = \""+$info_o.CFBundleGetInfoString+"\";"+$LF
	//$strings_t:=$strings_t+"NSHumanReadableCopyright = \""+$info_o.NSHumanReadableCopyright+"\";"
	
	$templatePath_t:=Get 4D folder:C485(Current resources folder:K5:16)+"InfoPlist.strings"
	
	If (Test path name:C476($templatePath_t)=Is a document:K24:1)
		DELETE DOCUMENT:C159($templatePath_t)
	End if 
	TEXT TO DOCUMENT:C1237($templatePath_t; $strings_t; "UTF-8"; Document with LF:K24:22)
	
End if 

//MARK: Verify the Build application settings are in place
If (OK=1)
	$buildSettingsPath_t:=Get 4D file:C1418(Build application settings file:K5:60)
	If (Length:C16($buildSettingsPath_t)=0)
		$templateSettings_t:=Get 4D folder:C485(Current resources folder:K5:16)+"templatebuildApp.xml"
		If (Test path name:C476($templateSettings_t)=Is a document:K24:1)
			$buildSettingsPath_t:=Get 4D folder:C485(Database folder:K5:14)+"Settings"+Folder separator:K24:12
			CREATE FOLDER:C475($buildSettingsPath_t; *)
			$buildSettingsPath_t:=$buildSettingsPath_t+"buildApp.4DSettings"
			COPY DOCUMENT:C541($templateSettings_t; $buildSettingsPath_t)
			OK:=0  // So it won't keep going automatically
			ALERT:C41("I've created a template settings document for you, please now go to\nDesign>Build Application…\n To confirm the default settings.\n\nAlternatively edit the XML directly.")
		End if 
	End if 
	
End if 

If (OK=1)  // If any of the previous steps failed OK will be 0
	
	$buildFolderPath_t:=Get 4D folder:C485(Database folder:K5:14)+"Builds"+Folder separator:K24:12+"Components"+Folder separator:K24:12
	
	Fnd_FCS_WriteDocumentation(""; True:C214; True:C214; True:C214; True:C214)  // Rewrite the documentation, eliminating the private methods
	BUILD APPLICATION:C871($buildSettingsPath_t)
	Fnd_FCS_WriteDocumentation(""; True:C214; False:C215; True:C214; True:C214)  // Rewrite the documentation, now documenting the private methods
	
	If (OK=1)
		SHOW ON DISK:C922($buildFolderPath_t)
		ALERT:C41("Successful Build")
	Else 
		ALERT:C41("Component Build Failed")
	End if 
	
End if 