//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr__ResolvePath ($root_o : Object; $tag_t : Text; \
//   $createIntermediates_b : Boolean; $leafObject_ptr : Pointer; \
//   $leafKey_ptr : Pointer) --> $resolved_b : Boolean

// Resolves a dotted tag path and returns the leaf object pointer and key.
// Intermediate objects are optionally auto-created for setter calls.

// Access: Private

// Parameters:
//   $root_o                : Object  : Root object to navigate
//   $tag_t                 : Text    : Dot path (for example "a.b.c")
//   $createIntermediates_b : Boolean : True to auto-create missing levels
//   $leafObject_ptr        : Pointer : ->Object that owns final key
//   $leafKey_ptr           : Pointer : ->Text final property key

// Returns:
//   $resolved_b : Boolean : True when path resolved successfully

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($root_o : Object; $tag_t : Text; $createIntermediates_b : Boolean; \
	$leafObject_ptr : Pointer; $leafKey_ptr : Pointer)->$resolved_b : Boolean

var $part_t : Text
var $working_t : Text
var $pos_i : Integer
var $index_i : Integer
var $current_o : Object
var $next_o : Object
var $invalid_b : Boolean

ARRAY TEXT($parts_at; 0)

$resolved_b:=False
$leafObject_ptr->:=Null
$leafKey_ptr->:=""

If (($root_o=Null) | ($tag_t=""))
	$invalid_b:=True
Else
	$invalid_b:=False
End if

If (Not($invalid_b))
	$working_t:=$tag_t
	Repeat
		$pos_i:=Position("."; $working_t)
		If ($pos_i>0)
			$part_t:=Substring($working_t; 1; $pos_i-1)
			$working_t:=Substring($working_t; $pos_i+1)
		Else
			$part_t:=$working_t
			$working_t:=""
		End if

		If ($part_t="")
			$invalid_b:=True
		Else
			APPEND TO ARRAY($parts_at; $part_t)
		End if
	Until ($working_t="") | ($invalid_b)
End if

If ((Not($invalid_b)) & (Size of array($parts_at)>0))
	$current_o:=$root_o

	For ($index_i; 1; Size of array($parts_at)-1)
		$next_o:=OB Get($current_o; $parts_at{$index_i}; Is object)
		If ($next_o=Null)
			If ($createIntermediates_b)
				$next_o:=New object
				OB SET($current_o; $parts_at{$index_i}; $next_o)
			Else
				$invalid_b:=True
			End if
		End if

		If ($invalid_b)
			$index_i:=Size of array($parts_at)
		Else
			$current_o:=$next_o
		End if
	End for

	If (Not($invalid_b))
		$leafObject_ptr->:=$current_o
		$leafKey_ptr->:=$parts_at{Size of array($parts_at)}
		$resolved_b:=True
	End if
End if
