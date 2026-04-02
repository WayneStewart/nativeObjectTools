//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayText ($handle_i : Integer; \
//   $tag_t : Text; $index_i : Integer; $value_t : Text)

// Sets a single element of a Text or String array item.
// Alias for OTr_PutArrayString — Text and String arrays
// are interchangeable in OTr storage.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $index_i  : Integer : Element index (0 = default element)
//   $value_t  : Text    : Value to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_t : Text)

OTr_PutArrayString($handle_i; $tag_t; $index_i; $value_t)
