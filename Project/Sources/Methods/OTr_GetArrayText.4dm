//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayText ($handle_i : Integer; \
//   $tag_t : Text; $index_i : Integer) -> $value_t : Text

// Retrieves a single element from a Text or String array item.
// Alias for OTr_GetArrayString — Text and String arrays
// are interchangeable in OTr storage.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $index_i  : Integer : Element index (0 = default element)

// Returns:
//   $value_t : Text : Element value, or "" on any failure

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $index_i : Integer)->$value_t : Text

$value_t:=OTr_GetArrayString($handle_i; $tag_t; $index_i)
