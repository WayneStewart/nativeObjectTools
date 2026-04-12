//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_ShadowKey ($leafKey_t : Text) --> Text

// Returns the shadow-key name used to carry the original
// OT type constant for a scalar leaf whose 4D representation
// is ambiguous (specifically, Pointer stored as text and,
// under the pre-v19 R2 fallback, BLOB stored as base64 text).
//
// The convention is: append "$type" to the leaf key. The "$"
// character cannot appear in an identifier a 4D developer can
// legitimately use, which guarantees that shadow keys cannot
// collide with user-chosen keys.
//
// Paired with OTr_z_IsShadowKey for the enumerator skip-filter.
//
// The shadow's stored value is the *OT* type constant, not the
// 4D native constant — this keeps it aligned with OTr_ItemType's
// public contract and avoids a conversion step on every read.
//
// Example: OTr_z_ShadowKey("today") --> "today$type"

// Access: Private

// Parameters:
//   $leafKey_t : Text : Leaf key the shadow is attached to

// Returns:
//   $shadowKey_t : Text : Shadow key name

// Created by Wayne Stewart, 2026-04-10
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($leafKey_t : Text)->$shadowKey_t : Text

$shadowKey_t:=$leafKey_t+"$type"
