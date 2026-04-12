//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uEqualStrings ($stringOne_t : Text; \
//   $stringTwo_t : Text) --> $isEqual_b : Boolean

// Compares two text values for equality.
// Empty strings are considered equal. Different lengths are not equal.
// For equal lengths, a case-sensitive position check is used.

// Access: Private

// Parameters:
//   $stringOne_t : Text : First string to compare
//   $stringTwo_t : Text : Second string to compare

// Returns:
//   $isEqual_b : Boolean : True if strings are equal, otherwise False

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself and Thibaud
// ----------------------------------------------------

#DECLARE($stringOne_t : Text; $stringTwo_t : Text)->$isEqual_b : Boolean

var $lengthOfStringOne_i; $lengthOfStringTwo_i : Integer

$isEqual_b:=False:C215

$lengthOfStringOne_i:=Length:C16($stringOne_t)
$lengthOfStringTwo_i:=Length:C16($stringTwo_t)

Case of 
	: ($lengthOfStringOne_i=0) & ($lengthOfStringTwo_i=0)
		$isEqual_b:=True:C214
		
	: ($lengthOfStringOne_i#$lengthOfStringTwo_i)
		
	: (Position:C15($stringOne_t; $stringTwo_t; *)#1)
		
	Else 
		
		$isEqual_b:=True:C214
		
End case 