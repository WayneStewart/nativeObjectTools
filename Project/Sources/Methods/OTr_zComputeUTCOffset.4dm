//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zComputeUTCOffset () --> Real

// Computes and returns the UTC offset in seconds once at startup.
// The offset is cached and used to convert GMT timestamps to local time
// without the overhead of repeated Current date(*) and Current time(*) calls.

// Access: Private

// Returns:
//   $offset_r : Real : UTC offset in seconds (e.g. 36000 for UTC+10, -12600 for UTC-3.5)

// Created by Wayne Stewart, 2026-04-08
// Wayne Stewart, 2026-04-08 - Implements section 3.2 of OTr-Phase-010-Spec
// (Timestamp Construction C1).
// ----------------------------------------------------

#DECLARE()->$offset_r : Real

var $localDate_d : Date
var $localTime_h : Time
var $gmtTimestamp_t : Text
var $utcYear_i; $utcMonth_i; $utcDay_i : Integer
var $utcHour_i; $utcMinute_i; $utcSecond_i : Integer
var $utcDate_d : Date
var $utcTime_h : Time
var $localSeconds_i : Integer
var $utcSeconds_i : Integer

// Get local wall-clock values
$localDate_d:=Current date:C33(*)
$localTime_h:=Current time:C178(*)

// Get UTC timestamp in format "YYYY-MM-DDTHH:MM:SS.mmmZ"
$gmtTimestamp_t:=Timestamp:C1445

// Parse UTC components from timestamp string
// Format: "YYYY-MM-DDTHH:MM:SS.mmmZ"

$dateSection_t:=Substring:C12($gmtTimestamp_t; 1; 10)
$utcYear_i:=Num:C11(Substring:C12($dateSection_t; 1; 4))
$utcMonth_i:=Num:C11(Substring:C12($dateSection_t; 6; 2))
$utcDay_i:=Num:C11(Substring:C12($dateSection_t; 9; 2))

$timeSection_t:=Substring:C12($gmtTimestamp_t; 12; 8)
//$i:=Num(Substring($gmtTimestamp_t; 12; 9))
//$utcMinute_i:=Num(Substring($gmtTimestamp_t; 15; 2))
//$utcSecond_i:=Num(Substring($gmtTimestamp_t; 18; 2))

// Construct UTC date and time values
$utcDate_d:=Add to date:C393(!00-00-00!; $utcYear_i; $utcMonth_i; $utcDay_i)
$utcTime_h:=Time:C179($timeSection_t)

// Convert both to seconds for comparison
// 4D date values are days since 1900-01-01, times are seconds since 00:00:00
$localSeconds_i:=($localDate_d*86400)+$localTime_h
$utcSeconds_i:=($utcDate_d*86400)+$utcTime_h

// Compute offset: (local - UTC) in seconds
$offset_r:=$localSeconds_i-$utcSeconds_i
