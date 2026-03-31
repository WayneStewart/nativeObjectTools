//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SetOptions ($options_i : Integer)

// Sets the current OTr options bit field.

// Access: Shared

// Parameters:
//   $options_i : Integer : New options bit field

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($options_i : Integer)

OTr__Lock

<>OTR_Options_i:=$options_i

OTr__Unlock
