//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_LogLevelToInt (inLevel) --> Integer

// Converts an OTr log control token to a numeric rank.

// Access: Private

// Parameters:
//   $inLevel_t : Text : Log control token

// Returns:
//   $outRank_i : Integer : 0=off, 1=info, 2=debug

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 log-level rank helper.
// ----------------------------------------------------

#DECLARE($inLevel_t : Text)->$outRank_i : Integer

$outRank_i:=1

Case of 
	: ($inLevel_t="off")
		$outRank_i:=0
		
	: ($inLevel_t="debug")
		$outRank_i:=2
		
	Else 
		$outRank_i:=1
		
End case 
