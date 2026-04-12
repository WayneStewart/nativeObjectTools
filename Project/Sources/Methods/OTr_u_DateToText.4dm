//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_u_DateToText ($theDate_d : Date) --> Text

// Converts a Date value to an ISO 8601 text string
// in YYYY-MM-DD format for storage in OTr objects.

// Access: Private

// Parameters:
//   $theDate_d : Date : The date to convert

// Returns:
//   $dateAsText_t : Text : Date as "YYYY-MM-DD"

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($theDate_d : Date)->$dateAsText_t : Text
$dateAsText_t:=String:C10(Year of:C25($theDate_d); "0000")+"-"+String:C10(Month of:C24($theDate_d); "00")+"-"+String:C10(Day of:C23($theDate_d); "00")


