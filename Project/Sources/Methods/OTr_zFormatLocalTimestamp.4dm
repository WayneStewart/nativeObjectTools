//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zFormatLocalTimestamp ($inGMTTimestamp_t : Text) --> Text

// Converts a GMT ISO 8601 timestamp to local time using the cached UTC offset.
// This avoids the overhead of Current date(*) and Current time(*) calls on every
// log write by computing the offset once at startup and caching it in Storage.

// Access: Private

// Parameters:
//   $inGMTTimestamp_t : Text : GMT timestamp in format "YYYY-MM-DDTHH:MM:SS.mmmZ"

// Returns:
//   $localTimestamp_t : Text : Local timestamp in format "YYYY-MM-DDTHH:MM:SS.mmm"

// Created by Wayne Stewart, 2026-04-08
// Wayne Stewart, 2026-04-08 - Implements section 3.2 of OTr-Phase-010-Spec
// (Timestamp Construction C1).
// ----------------------------------------------------

#DECLARE($inGMTTimestamp_t : Text)->$localTimestamp_t : Text

var $year_i; $month_i; $day_i : Integer
var $hour_i; $minute_i; $second_i; $millisecond_i : Integer
var $offsetSeconds_i : Integer
var $totalSeconds_i : Integer
var $daysAdjust_i : Integer
var $yearOfDate_i; $monthOfDate_i; $dayOfDate_i : Integer
var $hourOfTime_i; $minuteOfTime_i; $secondOfTime_i : Integer
var $workingDate_d : Date
var $workingTime_h : Time
var $offsetReal_r : Real
var $dayCount_i : Integer

// Parse the GMT timestamp: "YYYY-MM-DDTHH:MM:SS.mmmZ"
$year_i:=Num:C11(Substring:C12($inGMTTimestamp_t; 1; 4))
$month_i:=Num:C11(Substring:C12($inGMTTimestamp_t; 6; 2))
$day_i:=Num:C11(Substring:C12($inGMTTimestamp_t; 9; 2))
$hour_i:=Num:C11(Substring:C12($inGMTTimestamp_t; 12; 2))
$minute_i:=Num:C11(Substring:C12($inGMTTimestamp_t; 15; 2))
$second_i:=Num:C11(Substring:C12($inGMTTimestamp_t; 18; 2))
$millisecond_i:=Num:C11(Substring:C12($inGMTTimestamp_t; 21; 3))

// Get the cached UTC offset (in seconds)
$offsetReal_r:=Storage:C1525.OTr.log.UTCOffset
$offsetSeconds_i:=Integer:C471($offsetReal_r)

// Build a working date and time, then add the offset
$workingDate_d:=Date:C102($year_i; $month_i; $day_i)
$workingTime_h:=Time:C179($hour_i; $minute_i; $second_i)

// Convert to total seconds since epoch
$totalSeconds_i:=($workingDate_d*86400)+$workingTime_h

// Add the UTC offset
$totalSeconds_i:=$totalSeconds_i+$offsetSeconds_i

// Convert back to date and time components
$dayCount_i:=Int:C8($totalSeconds_i/86400)
$secondOfTime_i:=$totalSeconds_i-($dayCount_i*86400)

// Handle negative seconds (when offset pushes us to previous day)
If ($secondOfTime_i<0)
	$secondOfTime_i:=$secondOfTime_i+86400
	$dayCount_i:=$dayCount_i-1
End if

// Convert seconds back to time components
$hourOfTime_i:=Int:C8($secondOfTime_i/3600)
$minuteOfTime_i:=Int:C8(($secondOfTime_i-($hourOfTime_i*3600))/60)
$secondOfTime_i:=$secondOfTime_i-($hourOfTime_i*3600)-($minuteOfTime_i*60)

// Reconstruct the date from day count
// Day count 0 = 1900-01-01, so we build a date from $dayCount_i days since then
$workingDate_d:=Date:C102(1900; 1; 1)+$dayCount_i

// Extract the adjusted date components
$yearOfDate_i:=Year of:C25($workingDate_d)
$monthOfDate_i:=Month of:C24($workingDate_d)
$dayOfDate_i:=Day of:C23($workingDate_d)

// Format as "YYYY-MM-DDTHH:MM:SS.mmm"
$localTimestamp_t:=String:C10($yearOfDate_i; "0000")+"-"+String:C10($monthOfDate_i; "00")+"-"+String:C10($dayOfDate_i; "00")+"T"+String:C10($hourOfTime_i; "00")+":"+String:C10($minuteOfTime_i; "00")+":"+String:C10($secondOfTime_i; "00")+"."+String:C10($millisecond_i; "000")
