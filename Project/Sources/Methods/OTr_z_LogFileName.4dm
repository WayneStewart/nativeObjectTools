//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_LogFileName () --> Text

// Builds the current session log file name for OTr.

// Access: Private

// Returns:
//   $outFileName_t : Text : Current session log file name

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-07 - Added Phase 10 session log filename helper.
// ----------------------------------------------------

#DECLARE()->$outFileName_t : Text

var $sequenceText_t : Text

$sequenceText_t:=String:C10(Storage:C1525.OT_Logging.sequence; "000")
$outFileName_t:="ObjectTools "+Storage:C1525.OT_Logging.session+"."+$sequenceText_t+".txt"
