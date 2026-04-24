//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_LogInit

// Initialises OTr logging state and configures the helper logger.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

OTr_z_Init

var $applicationType_t; $buildType_t; $dateText_t; $legacyLevelFile_t; $locale_t; \
$logDirectory_t; $logFileName_t; $logLevelFile_t; $processor_t; $rawLevel_t; \
$resolvedLevel_t; $session_t; $summary_t; $timeText_t; $version_t : Text

var $systemInfo_o : Object
var $logEnabled_b : Boolean
var $applicationType_i; $retainSessions_i; $threshold_i : Integer
var $utcOffset_r : Real
var $ram_r : Real
var $fileIndex_i; $retainIndex_i; $prefixCount_i : Integer
var $filePrefix_t : Text

If (Storage:C1525.OT_Logging=Null:C1517)
	
	$logDirectory_t:=OTr_z_LogDirectory
	$session_t:=Replace string:C233(Substring:C12(OTr_z_timestampLocal; 1; 16); ":"; "-")  // This is the file name for the log
	$resolvedLevel_t:="info"
	$threshold_i:=1024*1024
	$retainSessions_i:=10
	
	$logLevelFile_t:=$logDirectory_t+"log_level"
	$legacyLevelFile_t:=$logDirectory_t+"log_debug_level"
	
	If (Test path name:C476($logLevelFile_t)=Is a document:K24:1)
		$rawLevel_t:=Document to text:C1236($logLevelFile_t; "UTF-8")
	Else 
		If (Test path name:C476($legacyLevelFile_t)=Is a document:K24:1)
			$rawLevel_t:=Document to text:C1236($legacyLevelFile_t; "UTF-8")
		End if 
	End if 
	
	$rawLevel_t:=Lowercase:C14($rawLevel_t)
	$rawLevel_t:=Replace string:C233($rawLevel_t; Char:C90(Carriage return:K15:38); "")
	$rawLevel_t:=Replace string:C233($rawLevel_t; Char:C90(Line feed:K15:40); "")
	$rawLevel_t:=Replace string:C233($rawLevel_t; Char:C90(Tab:K15:37); "")
	$rawLevel_t:=Replace string:C233($rawLevel_t; " "; "")
	
	Case of 
		: ($rawLevel_t="off")
			$resolvedLevel_t:="off"
			
		: ($rawLevel_t="debug")
			$resolvedLevel_t:="debug"
			
		: ($rawLevel_t="info")
			$resolvedLevel_t:="info"
			
		Else 
			$resolvedLevel_t:="info"
			
	End case 
	
	Use (Storage:C1525)
		Storage:C1525.OT_Logging:=New shared object:C1526()
	End use 
	
	Use (Storage:C1525.OT_Logging)
		Storage:C1525.OT_Logging.directory:=$logDirectory_t  // Where the logs are saved
		Storage:C1525.OT_Logging.session:=$session_t  // Base name of the log file
		Storage:C1525.OT_Logging.sequence:=1  // Initial sequence for this launch
		Storage:C1525.OT_Logging.sizeThreshold:=$threshold_i  // maximum log size in bytes
		Storage:C1525.OT_Logging.retainSessions:=$retainSessions_i  // The numer of launches kept
		Storage:C1525.OT_Logging.level:=$resolvedLevel_t
	End use 
	
	ARRAY TEXT:C222($logFiles_at; 0)
	ARRAY TEXT:C222($sessionPrefixes_at; 0)
	DOCUMENT LIST:C474($logDirectory_t; $logFiles_at)
	For ($fileIndex_i; Size of array:C274($logFiles_at); 1; -1)
		If (Substring:C12($logFiles_at{$fileIndex_i}; 1; 12)="ObjectTools ")
			$filePrefix_t:=Substring:C12($logFiles_at{$fileIndex_i}; 13; 16)
			If (Find in array:C230($sessionPrefixes_at; $filePrefix_t)=-1)
				APPEND TO ARRAY:C911($sessionPrefixes_at; $filePrefix_t)
			End if 
		Else 
			DELETE FROM ARRAY:C228($logFiles_at; $fileIndex_i)
		End if 
	End for 
	SORT ARRAY:C229($sessionPrefixes_at; >)
	$prefixCount_i:=Size of array:C274($sessionPrefixes_at)
	If ($prefixCount_i>$retainSessions_i)
		For ($retainIndex_i; 1; $prefixCount_i-$retainSessions_i)
			$filePrefix_t:=$sessionPrefixes_at{$retainIndex_i}
			For ($fileIndex_i; 1; Size of array:C274($logFiles_at))
				If (Substring:C12($logFiles_at{$fileIndex_i}; 13; 16)=$filePrefix_t)
					DELETE DOCUMENT:C159($logDirectory_t+$logFiles_at{$fileIndex_i})
				End if 
			End for 
		End for 
	End if 
	
	$logFileName_t:=OTr_z_LogFileName
	Log Folder Path($logDirectory_t)
	Log File Name($logFileName_t)
	LOG ENABLE(True:C214)
	
	LOG ADD ENTRY("info"; "env"; "*****************************************************************")
	LOG ADD ENTRY("info"; "env"; "  ObjectTools Replacement")
	LOG ADD ENTRY("info"; "env"; "*****************************************************************")
	LOG ADD ENTRY("info"; "env"; "checking log level path: "+$logLevelFile_t)
	LOG ADD ENTRY("info"; "env"; "checking log level path: "+$legacyLevelFile_t)
	
	If (Test path name:C476($logLevelFile_t)=Is a document:K24:1)
		LOG ADD ENTRY("info"; "env"; "found log level file: "+$logLevelFile_t)
		LOG ADD ENTRY("info"; "env"; "read log level: \""+$resolvedLevel_t+"\"")
	Else 
		If (Test path name:C476($legacyLevelFile_t)=Is a document:K24:1)
			LOG ADD ENTRY("info"; "env"; "found log level file: "+$legacyLevelFile_t)
			LOG ADD ENTRY("info"; "env"; "read log level: \""+$resolvedLevel_t+"\"")
		Else 
			LOG ADD ENTRY("info"; "env"; "no log level file found")
		End if 
	End if 
	
	If ($resolvedLevel_t#"off")
		LOG ADD ENTRY("info"; "env"; "log level = "+$resolvedLevel_t)
		$version_t:=OT Info("version")
		If (Is compiled mode:C492)
			$buildType_t:="release"
		Else 
			$buildType_t:="interpreted"
		End if 
		LOG ADD ENTRY("info"; "env"; $version_t+" ["+$buildType_t+", 64-bit]")
		
		$summary_t:=""
		$systemInfo_o:=Get system info:C1571
		If ($systemInfo_o#Null:C1517)
			$processor_t:=$systemInfo_o.processor
			If ($systemInfo_o.macRosetta=True:C214)
				$processor_t:=$processor_t+" (Rosetta)"
			End if 
			$ram_r:=$systemInfo_o.physicalMemory/1048576
			$locale_t:=Get database localization:C1009
			$summary_t:="["+$systemInfo_o.model+", "+$systemInfo_o.osVersion+", "+$processor_t+", "+String:C10($systemInfo_o.cores)+" cores, "+String:C10($systemInfo_o.cpuThreads)+" threads, "+String:C10($ram_r; "###0")+" GB, "+$locale_t+"]"
			LOG ADD ENTRY("info"; "env"; $summary_t)
			If ($resolvedLevel_t="debug")
				LOG ADD ENTRY("debug"; "env"; "looking for locale data")
				LOG ADD ENTRY("debug"; "env"; "raw system locale: "+$systemInfo_o.osLanguage)
			End if 
		End if 
		
		$applicationType_i:=Application type:C494
		Case of 
			: ($applicationType_i=4D Remote mode:K5:5)
				$applicationType_t:="4D Remote mode"
				
			: ($applicationType_i=4D Server:K5:6)
				$applicationType_t:="4D Server"
				
			: ($applicationType_i=4D Local mode:K5:1)
				$applicationType_t:="4D Local mode"
				
			: ($applicationType_i=4D Volume desktop:K5:2)
				$applicationType_t:="4D Volume desktop"
				
			: ($applicationType_i=6)  // I'm not certain this is possible
				$applicationType_t:="tool4D"
				
			: ($applicationType_i=4D Desktop:K5:4)
				$applicationType_t:="4D Desktop"
				
			Else 
				$applicationType_t:="Unknown Environment"
		End case 
		
		LOG ADD ENTRY("info"; "env"; "["+OTr_z_Get4DVersion+", "+$buildType_t+"]")
		LOG ADD ENTRY("info"; "env"; "checked")
		$logEnabled_b:=True:C214
	Else 
		$logEnabled_b:=False:C215
	End if 
	
	LOG ENABLE($logEnabled_b)
	
End if 
