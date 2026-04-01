//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uTextToDate ($dateAsText_t : Text) --> Date

// Parses an ISO 8601 text string in YYYY-MM-DD format
// back into a 4D Date value.

// Access: Private

// Parameters:
//   $dateAsText_t : Text : Date as "YYYY-MM-DD"

// Returns:
//   $theDate_d : Date : Parsed date, or !00/00/00!
//                       when the input is empty

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($dateAsText_t : Text)->$theDate_d : Date

var $year_i; $month_i; $day_i : Integer

$theDate_d:=!00-00-00!  // Initialise to null

// Convert the text value back to a date
If ($dateAsText_t#"")
	$year_i:=Num:C11(Substring:C12($dateAsText_t; 1; 4))
	$month_i:=Num:C11(Substring:C12($dateAsText_t; 6; 2))
	$day_i:=Num:C11(Substring:C12($dateAsText_t; 9; 2))
	$theDate_d:=Add to date:C393(!00-00-00!; $year_i; $month_i; $day_i)
End if 
