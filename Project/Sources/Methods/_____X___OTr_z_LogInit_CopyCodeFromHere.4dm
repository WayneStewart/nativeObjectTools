//%attributes = {"invisible":true,"shared":false}
// ============================================================
// REFERENCE METHOD - This shows the startup UTC offset
// computation that should be in OTr_z_LogInit.4dm
// ============================================================

// The following change has ALREADY BEEN MADE to OTr_z_LogInit.4dm:
// ============================================================

// OLD LINE (line 36 in OTr_z_LogInit):
//   $utcOffset_r:=0

// NEW LINE:
//   $utcOffset_r:=OTr_zComputeUTCOffset

// This ensures that on startup, the UTC offset is computed ONCE and cached
// in Storage.OTr.log.UTCOffset for use on every subsequent log write.

// The computation:
// 1. Gets local date/time via Current date(*) and Current time(*)
// 2. Gets GMT timestamp via Timestamp command
// 3. Parses UTC date/time from the timestamp
// 4. Converts both to seconds since epoch
// 5. Computes offset as (local - UTC) in seconds
// 6. Returns the offset for storage in Storage.OTr.log.UTCOffset

// This method is implemented in: OTr_zComputeUTCOffset.4dm
