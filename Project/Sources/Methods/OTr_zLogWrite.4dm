//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zLogWrite (inLevel; inSource; inMessage)

// Applies OTr log-level gating and forwards the entry to the
// installed helper logging routines.

// Access: Private

// Parameters:
//   $inLevel_t   : Text : Entry level token
//   $inSource_t  : Text : Entry source token
//   $inMessage_t : Text : Entry message text

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 OTr log routing.
// ----------------------------------------------------

#DECLARE($inLevel_t : Text; $inSource_t : Text; $inMessage_t : Text)

var $activeLevel_t : Text
var $currentFileName_t : Text
var $currentFilePath_t : Text
var $levelRank_i : Integer
var $activeRank_i : Integer
var $sequence_i : Integer
var $size_r : Real

If (Storage.OTr.logInitialised_b#True)
	OTr_zLogInit
End if

If (Storage.OTr.logInitialised_b#True)
	
Else
	$activeLevel_t:=Storage.OTr.logLevel
	If ($activeLevel_t#"off")
		$activeRank_i:=OTr_zLogLevelToInt($activeLevel_t)
		If ($inLevel_t="debug")
			$levelRank_i:=2
		Else 
			$levelRank_i:=1
		End if 
		
		If ($levelRank_i<=$activeRank_i)
			$currentFileName_t:=OTr_zLogFileName
			$currentFilePath_t:=Storage.OTr.logDirectory+$currentFileName_t
			If (Test path name($currentFilePath_t)=Is a document)
				$size_r:=Get document size($currentFilePath_t)
				If ($size_r>=Storage.OTr.logSizeThreshold)
					LOG CLOSE LOG
					Use (Storage.OTr)
						Storage.OTr.logSequence:=Storage.OTr.logSequence+1
						$sequence_i:=Storage.OTr.logSequence
					End use
					$currentFileName_t:=OTr_zLogFileName
				End if 
			End if 
			
			Log Folder Path(Storage.OTr.logDirectory)
			Log File Name($currentFileName_t)
			LOG ENABLE(True)
			LOG ADD ENTRY($inLevel_t; $inSource_t; $inMessage_t)
		End if 
	End if 
End if
