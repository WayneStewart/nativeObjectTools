//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_u_TextToTime ($timeAsText_t : Text) --> $theTime_h : Time

// Parses an HH:MM:SS text string back into a 4D
// Time value.

// Access: Private

// Parameters:
//   $timeAsText_t : Text : Time as "HH:MM:SS"

// Returns:
//   $theTime_h : Time : Parsed time, or ?00:00:00?
//                       when the input is empty

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($timeAsText_t : Text)->$theTime_h : Time

var $year_i; $month_i; $day_i : Integer

// Convert the text value back to a time
If ($timeAsText_t#"")
	$theTime_h:=Time:C179($timeAsText_t)
End if 
