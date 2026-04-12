//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_timestampLocal ({UTCtimeStamp}) --> localTimeStamp

// This method converts a UTC timestamp into one in 
//   the local time zone

// Access: Private

// Parameters: 
//   $UTCtimeStamp_t : Text : UTC timestamp (optional)

// Returns: 
//   $localTimeStamp_t : Text : Local timestamp

// Created by Wayne Stewart (2026-04-09)
// Code by Arnaud de Montard, shared on
// https://discuss.4d.com/t/local-timestamp-including-milliseconds/24156/4
// ----------------------------------------------------

#DECLARE($UTCtimeStamp_t : Text)->$localTimeStamp_t : Text

var $local_t; $useThisTimeStamp_t : Text
var $local_d : Date  //local date
var $local_h : Time  //local hour

If (Count parameters:C259=0)
	$useThisTimeStamp_t:=Timestamp:C1445
Else 
	$useThisTimeStamp_t:=$UTCtimeStamp_t
End if 

$local_t:=Substring:C12($useThisTimeStamp_t; 1; 23)  //locale (remove Z)
$local_d:=Date:C102($useThisTimeStamp_t)
$local_h:=Time:C179($useThisTimeStamp_t)

$localTimeStamp_t:=String:C10($local_d; ISO date:K1:8; $local_h)+Substring:C12($useThisTimeStamp_t; 20; 4)