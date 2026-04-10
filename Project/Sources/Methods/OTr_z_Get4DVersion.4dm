//%attributes = {"invisible":true,"preemptive":"capable"}
// ----------------------------------------------------
// Project Method: OTr_z_Get4DVersion --> ReturnType

// Returns a neatly formatted string describing the version of 4D
// Eg. 4D 20 R3 (100359)

// Access: Private

// Returns: 
//   $buildVersion  : Text : Description

// Created by Wayne Stewart (2024-05-18)
// ----------------------------------------------------

#DECLARE()->$buildVersion_t : Text

var $build_i : Integer
var $version_t; $releaseDetails_t : Text

$version_t:=Application version:C493($build_i)


$buildVersion_t:=$version_t[[1]]+$version_t[[2]]  //version number, e.g. 20
$releaseDetails_t:=$version_t[[3]]  //Rx

$buildVersion_t:="4D "+$buildVersion_t

If ($releaseDetails_t="0")  //4D v20.x
	$releaseDetails_t:=$version_t[[4]]  //.x
	$buildVersion_t:=$buildVersion_t+Choose:C955($releaseDetails_t#"0"; "."+$releaseDetails_t; "")
	
Else   //4D v20 Rx
	$buildVersion_t:=$buildVersion_t+" R"+$releaseDetails_t
End if 

$buildVersion_t:=$buildVersion_t+" ("+String:C10($build_i)+")"


