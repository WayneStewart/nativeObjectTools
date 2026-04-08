//%attributes = {"invisible":true,"shared":false}
// ============================================================
// EXAMPLE CALCULATIONS: UTC Offset and Timestamp Conversion
// Reference for section 3.2 of OTr-Phase-010-Spec
// ============================================================

// EXAMPLE 1: Sydney, Australia (UTC+10)
// ====================================

// At startup (assume wall clock shows 2026-04-08 16:01:15.347):
//   Current date(*) = 2026-04-08
//   Current time(*) = 16:01:15 (57675 seconds since midnight)
//   Timestamp = "2026-04-08T06:01:15.347Z" (GMT, 10 hours behind)

// Calculation:
//   Local seconds = (18826 days × 86400) + 57675 = 1625673675
//   UTC seconds = (18826 days × 86400) + 21675 = 1625637675
//   Offset = 1625673675 - 1625637675 = 36000 seconds (UTC+10)

// Stored in: Storage.OTr.log.UTCOffset = 36000

// On a log write (assume wall clock shows 2026-04-08 16:05:30.123):
//   Timestamp returns: "2026-04-08T06:05:30.123Z"
//   OTr_zFormatLocalTimestamp processes:
//     - Parse: Y=2026, M=04, D=08, H=06, Mi=05, S=30, ms=123
//     - Seconds from epoch = (18826 × 86400) + (6×3600) + (5×60) + 30 = 1625638530
//     - Add offset: 1625638530 + 36000 = 1625674530
//     - Convert back: 1625674530 / 86400 = 18827 days (2026-04-09)
//     - Remainder: 1625674530 % 86400 = 57330 seconds
//     - 57330 / 3600 = 15 hours, 630 seconds remaining
//     - 630 / 60 = 10 minutes, 30 seconds
//   - Result: "2026-04-09T15:10:30.123" (wrong - let me recalculate)

// Actually, let me recalculate more carefully:
//   UTC: 2026-04-08T06:05:30.123Z = day 18826 + (6*3600 + 5*60 + 30) seconds
//   Day offset: +10 hours = 36000 seconds
//   UTC seconds from epoch base = (6*3600 + 5*60 + 30) = 21930
//   Local seconds = 21930 + 36000 = 57930
//   Hours: 57930 / 3600 = 16 hours, 330 seconds remaining
//   Minutes: 330 / 60 = 5 minutes, 30 seconds
//   Local time = 16:05:30 (on same day 2026-04-08)
//   Result: "2026-04-08T16:05:30.123" ✓ Correct!

// EXAMPLE 2: New York, USA (UTC-5)
// ================================

// At startup (assume wall clock shows 2026-04-08 01:00:00):
//   Current date(*) = 2026-04-08
//   Current time(*) = 01:00:00 (3600 seconds)
//   Timestamp = "2026-04-08T06:00:00.000Z" (UTC, 5 hours ahead)

// Calculation:
//   Local seconds = (18826 × 86400) + 3600
//   UTC seconds = (18826 × 86400) + 21600  (6 hours = 21600 seconds)
//   Offset = (local) - (UTC) = 3600 - 21600 = -18000 seconds (UTC-5)

// On a log write with Timestamp = "2026-04-08T06:05:30.123Z":
//   UTC seconds = (18826 × 86400) + 21930
//   Add offset: 21930 + (-18000) = 3930
//   3930 / 3600 = 1 hour, 330 seconds
//   330 / 60 = 5 minutes, 30 seconds
//   Result: "2026-04-08T01:05:30.123" ✓ Correct! (same day, earlier time)

// EXAMPLE 3: India Standard Time (UTC+5:30)
// =========================================

// At startup (assume wall clock shows 2026-04-08 11:30:00):
//   Current date(*) = 2026-04-08
//   Current time(*) = 11:30:00 (41400 seconds)
//   Timestamp = "2026-04-08T06:00:00.000Z"

// Calculation:
//   Offset = 41400 - 21600 = 19800 seconds (5.5 hours = UTC+5:30)

// On a log write with Timestamp = "2026-04-07T23:50:00.000Z":
//   UTC seconds = 21:50:00 = (23×3600) + (50×60) = 86400 - 600 = 85800
//   But this is previous day! Day is 18825, not 18826
//   Local: previous day + (85800 + 19800) seconds
//   105600 seconds = 29.33 hours (wraps to next day)
//   105600 - 86400 = 19200 seconds on 2026-04-08
//   19200 / 3600 = 5 hours, 1200 remaining
//   1200 / 60 = 20 minutes
//   Result: "2026-04-08T05:20:00.000" ✓ Correct! (day boundary handled)

// EXAMPLE 4: Midnight UTC (UTC+0)
// ===============================

// At startup (assume wall clock shows 2026-04-08 00:00:00):
//   Current date(*) = 2026-04-08
//   Current time(*) = 00:00:00 (0 seconds)
//   Timestamp = "2026-04-08T00:00:00.000Z"

// Calculation:
//   Offset = 0 - 0 = 0 seconds (UTC+0)

// Result: UTC timestamps pass through unchanged
//   Input: "2026-04-08T12:34:56.789Z"
//   Output: "2026-04-08T12:34:56.789" ✓ Correct!

// VALIDATION RULES:
// =================

// 1. Offset must be computed ONCE at startup and cached
// 2. Offset stored as Real in Storage.OTr.log.UTCOffset
// 3. Each log write must call Timestamp (not cached)
// 4. Each log write must call OTr_zFormatLocalTimestamp with the GMT timestamp
// 5. Day boundaries must be handled when offset crosses midnight
// 6. Milliseconds (3 digits) must be preserved exactly
// 7. Output format is always "YYYY-MM-DDTHH:MM:SS.mmm" (no Z)
// 8. All calculations in seconds to avoid floating-point errors
