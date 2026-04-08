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

If (Storage:C1525.OTr.logInitialised_b#True:C214)
	OTr_z_LogInit
End if 

If (Storage:C1525.OTr.logInitialised_b#True:C214)
	
Else 
	$activeLevel_t:=Storage:C1525.OTr.logLevel
	If ($activeLevel_t#"off")
		$activeRank_i:=OTr_zLogLevelToInt($activeLevel_t)
		If ($inLevel_t="debug")
			$levelRank_i:=2
		Else 
			$levelRank_i:=1
		End if 
		
		If ($levelRank_i<=$activeRank_i)
			$currentFileName_t:=OTr_zLogFileName
			$currentFilePath_t:=Storage:C1525.OTr.logDirectory+$currentFileName_t
			If (Test path name:C476($currentFilePath_t)=Is a document:K24:1)
				$size_r:=Get document size:C479($currentFilePath_t)
				If ($size_r>=Storage:C1525.OTr.logSizeThreshold)
					LOG CLOSE LOG
					Use (Storage:C1525.OTr)
						Storage:C1525.OTr.log.sequence:=Storage:C1525.OTr.log.sequence+1
						$sequence_i:=Storage:C1525.OTr.log.sequence
					End use 
					$currentFileName_t:=OTr_zLogFileName
				End if 
			End if 
			
			Log Folder Path(Storage:C1525.OTr.logDirectory)
			Log File Name($currentFileName_t)
			LOG ENABLE(True:C214)
			LOG ADD ENTRY($inLevel_t; $inSource_t; $inMessage_t)
		End if 
	End if 
End if 
