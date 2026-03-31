//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetOptions () --> $options_i : Integer

// Returns the current OTr options bit field.

// Access: Shared

// Returns:
//   $options_i : Integer : Current options bit field

// Created by Wayne Stewart, 2026-03-31
// ----------------------------------------------------

#DECLARE()->$options_i : Integer

OTr__Init

$options_i:=<>OTR_Options_i
