//%attributes = {"invisible":true,"shared":false}
// ============================================================
// FILES CREATED AND MODIFIED
// Implementation of Section 3.2: Timestamp Construction (C1)
// ============================================================

// FILES CREATED:
// ==============

// 1. OTr_zComputeUTCOffset.4dm
//    Purpose: Calculate UTC offset once at startup
//    Location: Project/Sources/Methods/
//    Signature: #DECLARE()->$offset_r : Real
//    What it does:
//      - Gets local date/time via Current date(*) and Current time(*)
//      - Gets GMT timestamp via Timestamp command
//      - Parses UTC date/time from "YYYY-MM-DDTHH:MM:SS.mmmZ" format
//      - Converts both to seconds since epoch (1900-01-01)
//      - Returns offset in seconds: (local - UTC)
//      - Handles all timezones from UTC-12 to UTC+14
//      - Handles half-hour offsets (UTC±5:30, etc.)

// 2. OTr_zFormatLocalTimestamp.4dm
//    Purpose: Convert GMT timestamp to local time using cached offset
//    Location: Project/Sources/Methods/
//    Signature: #DECLARE($inGMTTimestamp_t : Text)->$localTimestamp_t : Text
//    Input: GMT timestamp string "YYYY-MM-DDTHH:MM:SS.mmmZ"
//    Output: Local timestamp string "YYYY-MM-DDTHH:MM:SS.mmm"
//    What it does:
//      - Parses all 7 components from input timestamp
//      - Retrieves cached offset from Storage.OTr.log.UTCOffset
//      - Converts GMT to total seconds since epoch
//      - Adds cached offset to seconds
//      - Handles day boundary adjustments (for DST/timezone wrapping)
//      - Converts back to date/time components
//      - Returns formatted local timestamp (no Z suffix)

// 3. _____X___OTr_zLogWrite_CopyCodeFromHere.4dm
//    Purpose: Reference showing timestamp handling for OTr_zLogWrite
//    Location: Project/Sources/Methods/
//    What it shows:
//      - How to call Timestamp command
//      - How to pass GMT timestamp to OTr_zFormatLocalTimestamp
//      - How to integrate converted timestamp with LOG ADD ENTRY
//      - Note: Actual integration depends on LOG ADD ENTRY signature

// 4. _____X___OTr_z_LogInit_CopyCodeFromHere.4dm
//    Purpose: Reference showing UTC offset initialization
//    Location: Project/Sources/Methods/
//    What it shows:
//      - Line 36 change from: $utcOffset_r:=0
//      - To: $utcOffset_r:=OTr_zComputeUTCOffset
//      - Status: ALREADY APPLIED

// 5. _____X___IMPLEMENTATION_SUMMARY.4dm
//    Purpose: Checklist and summary of all work
//    Location: Project/Sources/Methods/
//    What it contains:
//      - Completed items
//      - TODO items requiring manual integration
//      - Verification checklist
//      - Testing notes

// 6. _____X___EXAMPLE_CALCULATIONS.4dm
//    Purpose: Example calculations for different timezones
//    Location: Project/Sources/Methods/
//    What it contains:
//      - Sydney (UTC+10) example with day calculations
//      - New York (UTC-5) example with day calculations
//      - India (UTC+5:30) example with half-hour offset
//      - UTC (UTC+0) example as baseline
//      - Validation rules for all scenarios

// 7. _____X___FILES_CREATED_AND_MODIFIED.4dm (THIS FILE)
//    Purpose: Documentation of all changes
//    Location: Project/Sources/Methods/

// FILES MODIFIED:
// ===============

// 1. OTr_z_LogInit.4dm
//    Line 36 changed from: $utcOffset_r:=0
//    To: $utcOffset_r:=OTr_zComputeUTCOffset
//    Effect: UTC offset is now computed at startup instead of hardcoded to 0
//    Status: ALREADY APPLIED

// FILES REQUIRING MANUAL CHANGES:
// ===============================

// 1. OTr_zLogWrite.4dm
//    Current behavior: Calls LOG ADD ENTRY directly with GMT timestamp
//    Required changes:
//      a) Before calling LOG ADD ENTRY:
//         - Get GMT timestamp: Timestamp command
//         - Convert to local: OTr_zFormatLocalTimestamp
//         - (Exact integration depends on LOG ADD ENTRY signature)
//      b) After changes:
//         - Log entries will show local time instead of GMT
//         - Timestamp conversion happens once per write (overhead minimal)
//    Reference: See _____X___OTr_zLogWrite_CopyCodeFromHere.4dm

// STORAGE STRUCTURE IMPACTS:
// ==========================

// Storage.OTr.log.UTCOffset
//   Type: Real (changed from unused)
//   Set by: OTr_zComputeUTCOffset during OTr_z_LogInit
//   Used by: OTr_zFormatLocalTimestamp on every log write
//   Value: Offset in seconds (e.g. 36000 for UTC+10, -18000 for UTC-5)
//   Persistence: Session only (computed fresh on every startup)

// BACKWARDS COMPATIBILITY:
// ========================

// Fully backwards compatible:
//   - Public API unchanged
//   - Storage structure uses new property but doesn't break existing code
//   - Log file format and location unchanged
//   - Helper logging methods unchanged
//   - Only timestamp values in log entries will change (from GMT to local)

// METHOD CALL GRAPH:
// ==================

// On startup (once):
//   OTr_z_LogInit
//     └─> OTr_zComputeUTCOffset  [NEW]
//           └─ Timestamp (4D built-in)
//           └─ Current date(*) (4D built-in)
//           └─ Current time(*) (4D built-in)

// On each log write:
//   OTr_zLogWrite
//     └─> (TODO) OTr_zFormatLocalTimestamp  [NEW]
//           └─ Timestamp (4D built-in)
//           └─ Storage.OTr.log.UTCOffset (cached)
//     └─> LOG ADD ENTRY (helper)
