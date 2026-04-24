//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_IsShadowKey ($key_t : Text) --> Boolean

// Returns True if $key_t is an OTr shadow-type key (a key
// ending in the reserved "$type" suffix used to carry the
// original OT type constant for text-collapsed scalars).
//
// Used by the property enumerators (OT GetNamedProperties,
// OT GetAllNamedProperties, OT GetItemProperties) to hide
// shadow keys from callers, and by OTr_z_MapType to avoid
// recursively mapping a shadow as if it were a user property.
//
// Paired with OTr_z_ShadowKey which constructs shadow keys.

// Access: Private

// Parameters:
//   $key_t : Text : Property key to test

// Returns:
//   $isShadow_b : Boolean : True if $key_t is a shadow key

// Created by Wayne Stewart, 2026-04-10
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($key_t : Text)->$isShadow_b : Boolean

var $len_i : Integer
var $suffix_t : Text

$isShadow_b:=False:C215

$suffix_t:="$type"
$len_i:=Length:C16($suffix_t)

If (Length:C16($key_t)>$len_i)
	If (Substring:C12($key_t; Length:C16($key_t)-$len_i+1)=$suffix_t)
		$isShadow_b:=True:C214
	End if 
End if 
