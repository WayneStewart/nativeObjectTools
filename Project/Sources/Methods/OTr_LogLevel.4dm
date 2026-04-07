//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_LogLevel (setLogLevel {; permanent}) --> Text

// Gets or sets the active OTr logging control level.

// Access: Shared

// Parameters:
//   $setLogLevel_t : Text    : Optional new log level (off, info, debug)
//   $permanent_b   : Boolean : Optional True to persist the token to disk

// Returns:
//   $getLogLevel_t : Text : Active OTr log level after any change

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 public log-level API.
// ----------------------------------------------------

#DECLARE($setLogLevel_t : Text; $permanent_b : Boolean)->$getLogLevel_t : Text

OTr_zAddToCallStack(Current method name)

var $parametersCount_i : Integer
var $resolvedLevel_t : Text
var $logLevelFile_t : Text

$parametersCount_i:=Count parameters
$setLogLevel_t:=Choose($parametersCount_i<1; ""; Lowercase($setLogLevel_t))
$permanent_b:=Choose($parametersCount_i<2; False; $permanent_b)

If (Storage.OTr.logInitialised_b#True)
	OTr_zLogInit
End if

$resolvedLevel_t:=Storage.OTr.logLevel

Case of
	: ($setLogLevel_t="off")
		$resolvedLevel_t:="off"
	
	: ($setLogLevel_t="debug")
		$resolvedLevel_t:="debug"
	
	: ($setLogLevel_t="info")
		$resolvedLevel_t:="info"
	
	: ($setLogLevel_t="")
		
	Else 
		
End case

Use (Storage.OTr)
	Storage.OTr.logLevel:=$resolvedLevel_t
End use

If ($resolvedLevel_t="off")
	LOG ENABLE(False)
Else 
	Log Folder Path(Storage.OTr.logDirectory)
	Log File Name(OTr_zLogFileName)
	LOG ENABLE(True)
End if 

If ($permanent_b)
	$logLevelFile_t:=Storage.OTr.logDirectory+"log_level"
	TEXT TO DOCUMENT($logLevelFile_t; $resolvedLevel_t; "UTF-8")
End if

$getLogLevel_t:=Storage.OTr.logLevel

OTr_zRemoveFromCallStack(Current method name)
