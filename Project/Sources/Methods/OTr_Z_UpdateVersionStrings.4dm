//%attributes = {"invisible":true}
var $build_t; $buildVersion_t; $version_t; $templatePath_t; $date_t; $json_t; $LF; $strings_t : Text
var $info_o : Object

$version_t:=Application version:C493
$buildVersion_t:=$version_t[[1]]+$version_t[[2]]+" LTS"  //version number, e.g. 20


$build_t:=OTr_Info("version")
$build_t:=$build_t+" ("+$buildVersion_t+")"


$templatePath_t:=Get 4D folder:C485(Current resources folder:K5:16)+"InfoPlist.json"
If (Test path name:C476($templatePath_t)=Is a document:K24:1)
	$LF:=Char:C90(Line feed:K15:40)
	$json_t:=Document to text:C1236($templatePath_t)
	$info_o:=JSON Parse:C1218($json_t)
	$date_t:=OTr_z_timestampLocal
	$date_t:=Substring:C12($date_t; 1; 10)
	
	// Update the json
	$info_o.CFBundleShortVersionString:=$build_t
	$info_o.CFBundleGetInfoString:=$info_o.CFBundleName+" "+$build_t+", "+$date_t
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