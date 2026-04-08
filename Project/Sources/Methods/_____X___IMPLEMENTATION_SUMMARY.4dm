//%attributes = {"invisible":true,"shared":false}
// ============================================================
// IMPLEMENTATION SUMMARY: Section 3.2 Timestamp Construction (C1)
// OTr-Phase-010-Spec
// ============================================================

// COMPLETED:
// ==========

// 1. OTr_zComputeUTCOffset.4dm (NEW METHOD)
//    - Computes UTC offset once at startup
//    - Gets local date/time via Current date(*) and Current time(*)
//    - Parses GMT timestamp from Timestamp command
//    - Calculates offset in seconds: (local seconds) - (UTC seconds)
//    - Returns offset for storage in Storage.OTr.log.UTCOffset

// 2. OTr_zFormatLocalTimestamp.4dm (NEW METHOD)
//    - Takes a GMT timestamp string: "YYYY-MM-DDTHH:MM:SS.mmmZ"
//    - Parses all components (year, month, day, hour, minute, second, millisecond)
//    - Retrieves cached offset from Storage.OTr.log.UTCOffset
//    - Adds offset to the UTC timestamp
//    - Handles day/hour boundary adjustments
//    - Returns formatted local timestamp: "YYYY-MM-DDTHH:MM:SS.mmm"

// 3. OTr_z_LogInit.4dm (MODIFIED)
//    - Changed line 36 from: $utcOffset_r:=0
//    - To: $utcOffset_r:=OTr_zComputeUTCOffset
//    - This computes and caches the UTC offset at startup

// TODO - MANUAL INTEGRATION REQUIRED:
// ===================================

// 1. OTr_zLogWrite.4dm
//    - Needs to be updated to use OTr_zFormatLocalTimestamp
//    - Currently calls: LOG ADD ENTRY($inLevel_t; $inSource_t; $inMessage_t)
//    - Needs to:
//      a) Get GMT timestamp via: Timestamp command
//      b) Convert to local time via: OTr_zFormatLocalTimestamp
//      c) Pass timestamp to logging system (method depends on LOG ADD ENTRY signature)
//    - See: _____X___OTr_zLogWrite_CopyCodeFromHere.4dm

// VERIFICATION CHECKLIST:
// ======================

// [ ] UTC offset computation method exists and returns Real
// [ ] Local timestamp formatting method exists and returns Text
// [ ] OTr_z_LogInit calls OTr_zComputeUTCOffset instead of hardcoded 0
// [ ] OTr_zLogWrite calls OTr_zFormatLocalTimestamp before logging
// [ ] Timestamp format verification: "YYYY-MM-DDTHH:MM:SS.mmmZ" (with Z)
// [ ] Local timestamp format: "YYYY-MM-DDTHH:MM:SS.mmm" (no Z)
// [ ] Offset stored in Storage.OTr.log.UTCOffset as Real
// [ ] Offset is computed ONCE at startup, not on every write
// [ ] Milliseconds are preserved in timestamp conversion
// [ ] Day boundary adjustments work correctly (UTC-11 to UTC+14)
// [ ] Log entries show correct local time, not GMT

// TESTING NOTES:
// ==============

// Test in different timezones:
// - UTC timezone (offset should be 0)
// - Positive offset (e.g. UTC+10 Australia = 36000 seconds)
// - Negative offset (e.g. UTC-5 Eastern = -18000 seconds)
// - Half-hour offset (e.g. UTC+5:30 India = 19800 seconds)
// - Negative half-hour (e.g. UTC-3:30 = -12600 seconds)

// Verify timestamps:
// - Startup: log level entries should show correct local time
// - Runtime: error and info entries should show correct local time
// - Compare logged timestamps with wall-clock time to verify accuracy
