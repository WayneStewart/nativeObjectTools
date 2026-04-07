//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zLogInit

// Initialises OTr logging state and configures the helper logger.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 startup logging initialisation.
// ----------------------------------------------------

OTr_zInit

If (Storage.OTr.logInitialised_b=True)
	
Else
	var $logDirectory_t : Text
	var $session_t : Text
	var $logFileName_t : Text
	var $logLevelFile_t : Text
	var $legacyLevelFile_t : Text
	var $rawLevel_t : Text
	var $resolvedLevel_t : Text
	var $dateText_t : Text
	var $timeText_t : Text
	var $version_t : Text
	var $buildType_t : Text
	var $summary_t : Text
	var $processor_t : Text
	var $applicationType_t : Text
	var $locale_t : Text
	var $systemInfo_o : Object
	var $logEnabled_b : Boolean
	var $applicationType_i : Integer
	var $retainSessions_i : Integer
	var $threshold_i : Integer
	var $utcOffset_r : Real
	var $ram_r : Real
	
	$logDirectory_t:=OTr_zLogDirectory
	$dateText_t:=OTr_uDateToText(Current date(*))
	$timeText_t:=OTr_uTimeToText(Current time(*))
	$session_t:=Substring($dateText_t; 3; 2)+"-"+Substring($dateText_t; 6; 2)+"-"+Substring($dateText_t; 9; 2)+"-"+Substring($timeText_t; 1; 2)+"-"+Substring($timeText_t; 4; 2)
	$resolvedLevel_t:="info"
	$threshold_i:=1048576
	$retainSessions_i:=10
	$utcOffset_r:=0
	
	$logLevelFile_t:=$logDirectory_t+"log_level"
	$legacyLevelFile_t:=$logDirectory_t+"log_debug_level"
	
	If (Test path name($logLevelFile_t)=Is a document)
		$rawLevel_t:=Document to text($logLevelFile_t; "UTF-8")
	Else 
		If (Test path name($legacyLevelFile_t)=Is a document)
			$rawLevel_t:=Document to text($legacyLevelFile_t; "UTF-8")
		End if 
	End if 
	
	$rawLevel_t:=Lowercase($rawLevel_t)
	$rawLevel_t:=Replace string($rawLevel_t; Char(Carriage return); "")
	$rawLevel_t:=Replace string($rawLevel_t; Char(Line feed); "")
	$rawLevel_t:=Replace string($rawLevel_t; Char(Tab); "")
	$rawLevel_t:=Replace string($rawLevel_t; " "; "")
	
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
	
	Use (Storage.OTr)
		Storage.OTr.logDirectory:=$logDirectory_t
		Storage.OTr.logSession:=$session_t
		Storage.OTr.logSequence:=1
		Storage.OTr.logSizeThreshold:=$threshold_i
		Storage.OTr.logRetainSessions:=$retainSessions_i
		Storage.OTr.logUTCOffset:=$utcOffset_r
		Storage.OTr.logLevel:=$resolvedLevel_t
		Storage.OTr.logInitialised_b:=True
	End use
	
	$logFileName_t:=OTr_zLogFileName
	Log Folder Path($logDirectory_t)
	Log File Name($logFileName_t)
	LOG ENABLE(True)
	
	LOG ADD ENTRY("info"; "env"; "*****************************************************************")
	LOG ADD ENTRY("info"; "env"; "  ObjectTools")
	LOG ADD ENTRY("info"; "env"; "*****************************************************************")
	LOG ADD ENTRY("info"; "env"; "checking log level path: "+$logLevelFile_t)
	LOG ADD ENTRY("info"; "env"; "checking log level path: "+$legacyLevelFile_t)
	
	If (Test path name($logLevelFile_t)=Is a document)
		LOG ADD ENTRY("info"; "env"; "found log level file: "+$logLevelFile_t)
		LOG ADD ENTRY("info"; "env"; "read log level: \""+$resolvedLevel_t+"\"")
	Else 
		If (Test path name($legacyLevelFile_t)=Is a document)
			LOG ADD ENTRY("info"; "env"; "found log level file: "+$legacyLevelFile_t)
			LOG ADD ENTRY("info"; "env"; "read log level: \""+$resolvedLevel_t+"\"")
		Else 
			LOG ADD ENTRY("info"; "env"; "no log level file found")
		End if 
	End if 
	
	If ($resolvedLevel_t#"off")
		LOG ADD ENTRY("info"; "env"; "log level = "+$resolvedLevel_t)
		$version_t:=OTr_GetVersion
		If (Is compiled mode)
			$buildType_t:="release"
		Else 
			$buildType_t:="interpreted"
		End if 
		LOG ADD ENTRY("info"; "env"; $version_t+" ["+$buildType_t+", 64-bit]")
		
		$summary_t:=""
		$systemInfo_o:=Get system info
		If ($systemInfo_o#Null)
			$processor_t:=$systemInfo_o.processor
			If ($systemInfo_o.macRosetta=True)
				$processor_t:=$processor_t+" (Rosetta)"
			End if 
			$ram_r:=$systemInfo_o.physicalMemory/1048576
			$locale_t:=Get database localization
			$summary_t:="["+$systemInfo_o.model+", "+$systemInfo_o.osVersion+", "+$processor_t+", "+String($systemInfo_o.cores)+" cores, "+String($systemInfo_o.cpuThreads)+" threads, "+String($ram_r; "###0")+" GB, "+$locale_t+"]"
			LOG ADD ENTRY("info"; "env"; $summary_t)
			If ($resolvedLevel_t="debug")
				LOG ADD ENTRY("debug"; "env"; "looking for locale data")
				LOG ADD ENTRY("debug"; "env"; "raw system locale: "+$systemInfo_o.osLanguage)
			End if 
		End if 
		
		$applicationType_i:=Application type
		If ($applicationType_i=4D Remote mode)
			$applicationType_t:="Remote"
		Else 
			$applicationType_t:="Mono"
		End if 
		LOG ADD ENTRY("info"; "env"; "4D v"+String(Application version)+" ["+$applicationType_t+", "+$buildType_t+", Unicode mode]")
		LOG ADD ENTRY("info"; "env"; "checked")
		$logEnabled_b:=True
	Else 
		$logEnabled_b:=False
	End if 
	
	LOG ENABLE($logEnabled_b)
	
End if
