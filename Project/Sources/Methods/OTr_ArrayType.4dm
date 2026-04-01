//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ArrayType ($handle_i : Integer; $tag_t : Text) --> Integer

// Returns the stored arrayType value from an OTr
// array object. Used to verify type compatibility
// before performing array operations.
// Returns -1 if the handle is invalid, the tag does
// not exist, or the tag does not reference an array.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item

// Returns:
//   $arrayType_i : Integer : Stored arrayType, or -1

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$arrayType_i : Integer

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text

$arrayType_i:=-1

If (OTr__IsValidHandle($handle_i))
	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			$arrayType_i:=OTr__ArrayType($arrayObj_o)
		End if 
	End if 
End if 
