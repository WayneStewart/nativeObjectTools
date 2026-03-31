//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetText ($handle_i : Integer; $tag_t : Text) \
//   --> $value_t : Text

// Retrieves a Text value from the specified tag path.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path

// Returns:
//   $value_t : Text : Stored value, or empty text when missing/invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$value_t : Text

$value_t:=OTr_GetString($handle_i; $tag_t)
