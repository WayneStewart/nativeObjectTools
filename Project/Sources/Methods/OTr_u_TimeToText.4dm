//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_u_TimeToText ($theTime_h) -> Text

// Converts a Time value to an HH:MM:SS text string
// for storage in OTr objects.

// Access: Private

// Parameters:
//   $theTime_h : Time : The time to convert

// Returns:
//   $timeAsText_t : Text : Time as "HH:MM:SS"

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($theTime_h : Time)->$timeAsText_t : Text

$timeAsText_t:=String:C10($theTime_h; HH MM SS:K7:1)

