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

OTr_zAddToCallStack(Current method name:C684)

var $parametersCount_i : Integer
var $currentLoggingLevel_t; $initialLoggingLevel_t : Text
var $logLevelFile_t : Text

$parametersCount_i:=Count parameters:C259

Case of 
	: ($parametersCount_i=0)
		$setLogLevel_t:=""
		$permanent_b:=False:C215
		
	: ($parametersCount_i=1)
		$permanent_b:=False:C215
		
		
End case 

$setLogLevel_t:=Lowercase:C14($setLogLevel_t)
Case of 
	: (($setLogLevel_t="off") | ($setLogLevel_t="info") | ($setLogLevel_t="debug"))
		// Valid token
		
	: (Length:C16($setLogLevel_t)=0)
		// Getter call
		
	Else 
		$setLogLevel_t:=""
		
End case 

$currentLoggingLevel_t:=Storage:C1525.OT_Logging.level
$initialLoggingLevel_t:=$currentLoggingLevel_t

Case of 
	: (Length:C16($setLogLevel_t)=0)
		// Do nothing
		
	: ($currentLoggingLevel_t=$setLogLevel_t)
		// Do Nothing
		
	Else 
		Use (Storage:C1525.OT_Logging)
			Storage:C1525.OT_Logging.level:=$setLogLevel_t
		End use 
		
End case 

$currentLoggingLevel_t:=Storage:C1525.OT_Logging.level  // It may have changed

If ($currentLoggingLevel_t="off")
	LOG ENABLE(False:C215)
Else 
	LOG ENABLE(True:C214)
End if 

If ($permanent_b) & ($initialLoggingLevel_t#$currentLoggingLevel_t)  // Write the changes (if there were any)
	$logLevelFile_t:=Storage:C1525.OT_Logging.directory+"log_level"
	TEXT TO DOCUMENT:C1237($logLevelFile_t; $currentLoggingLevel_t; "UTF-8")
End if 

$getLogLevel_t:=Storage:C1525.OT_Logging.level

OTr_zRemoveFromCallStack(Current method name:C684)
