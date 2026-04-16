//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_PluginShouldWork --> Boolean

// Determines if the plugin should work based on the OS

// Access: Private

// Returns: 
//   $pluginShouldWork_b : Boolean : Returns true if the plugin is a) present and b) the OS supports it

// Created by Wayne Stewart 2026-04-17
// ----------------------------------------------------

#DECLARE()->$pluginShouldWork_b : Boolean

var $pluginPresent_b; $operatingSystemIsOK_b : Boolean
var $pluginPath_t; $OS_t : Text
var $systemInfo_o : Object

$pluginPath_t:=Get 4D folder:C485(Database folder:K5:14)+"Plugins"+Folder separator:K24:12+"ObjectTools.bundle"+Folder separator:K24:12
$pluginPresent_b:=(Test path name:C476($pluginPath_t)=Is a folder:K24:2)


$systemInfo_o:=Get system info:C1571
If ($systemInfo_o#Null:C1517)
	$OS_t:=Replace string:C233($systemInfo_o.osVersion; "MacOS "; "")
End if 

$operatingSystemIsOK_b:=Not:C34($OS_t="26.4@")

$pluginShouldWork_b:=$pluginPresent_b & $operatingSystemIsOK_b




