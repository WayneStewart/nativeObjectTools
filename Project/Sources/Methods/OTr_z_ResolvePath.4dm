//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_ResolvePath ($root_o : Object; $tag_t : Text; \
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

ARRAY TEXT:C222($parts_at; 0)

$resolved_b:=False:C215
$leafObject_ptr->:=Null:C1517
$leafKey_ptr->:=""

If (($root_o=Null:C1517) | ($tag_t=""))
	$invalid_b:=True:C214
Else 
	$invalid_b:=False:C215
End if 

If (Not:C34($invalid_b))
	$working_t:=$tag_t
	Repeat 
		$pos_i:=Position:C15("."; $working_t)
		If ($pos_i>0)
			$part_t:=Substring:C12($working_t; 1; $pos_i-1)
			$working_t:=Substring:C12($working_t; $pos_i+1)
		Else 
			$part_t:=$working_t
			$working_t:=""
		End if 
		
		If ($part_t="")
			$invalid_b:=True:C214
		Else 
			APPEND TO ARRAY:C911($parts_at; $part_t)
		End if 
	Until ($working_t="") | ($invalid_b)
End if 

If ((Not:C34($invalid_b)) & (Size of array:C274($parts_at)>0))
	$current_o:=$root_o
	
	For ($index_i; 1; Size of array:C274($parts_at)-1)
		$next_o:=OB Get:C1224($current_o; $parts_at{$index_i}; Is object:K8:27)
		If ($next_o=Null:C1517)
			If ($createIntermediates_b)
				$next_o:=New object:C1471
				OB SET:C1220($current_o; $parts_at{$index_i}; $next_o)
			Else 
				$invalid_b:=True:C214
			End if 
		End if 
		
		If ($invalid_b)
			$index_i:=Size of array:C274($parts_at)
		Else 
			$current_o:=$next_o
		End if 
	End for 
	
	If (Not:C34($invalid_b))
		$leafObject_ptr->:=$current_o
		$leafKey_ptr->:=$parts_at{Size of array:C274($parts_at)}
		$resolved_b:=True:C214
	End if 
End if 
