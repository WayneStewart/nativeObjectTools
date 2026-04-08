//%attributes = {"invisible":true,"shared":false}
// ============================================================
// REFERENCE METHOD - Copy the relevant sections from this
// method into OTr_zLogWrite.4dm where LOG ADD ENTRY is called
// ============================================================

// This shows the correct approach to timestamp handling for section 3.2
// (Timestamp Construction C1) of OTr-Phase-010-Spec.

// COPY THIS SECTION into OTr_zLogWrite where LOG ADD ENTRY is currently called:
// ============================================================

// -----BEGIN COPY SECTION-----
var $gmtTimestamp_t : Text
var $localTimestamp_t : Text

If ($levelRank_i<=$activeRank_i)
	// ... existing code for file size check ...

	// Get the GMT timestamp and convert to local time
	$gmtTimestamp_t:=Timestamp:C1674
	$localTimestamp_t:=OTr_zFormatLocalTimestamp($gmtTimestamp_t)

	// Pass the local timestamp to the logging system
	LOG ADD ENTRY($inLevel_t; $inSource_t; $inMessage_t; $localTimestamp_t)

End if
// -----END COPY SECTION-----

// NOTE: This assumes LOG ADD ENTRY accepts a timestamp parameter.
// If LOG ADD ENTRY does not accept a timestamp parameter, then construct
// the full log entry manually using this format:
//
//   $logEntry_t := $localTimestamp_t + Char(Tab) + $inLevel_t + Char(Tab) + \
//                   $inSource_t + Char(Tab) + $inMessage_t + Char(LF)
//
// And dispatch $logEntry_t through the appropriate log writer method.
