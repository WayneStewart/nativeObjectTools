//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_InsertElement
//   ($handle_i : Integer; $tag_t : Text; $where_i : Integer
//    {; $howMany_i : Integer})

// Inserts one or more empty elements into an OTr array
// at position $where_i (1-based). Existing elements at
// and above $where_i are shifted up by $howMany_i.
// Inserted elements are initialised to the type's default value.
// If $where_i exceeds numElements, elements are appended
// at the end. $howMany_i defaults to 1 if omitted.
// Element 0 (the pre-selection slot) is never affected.

// Access: Shared

// Parameters:
//   $handle_i  : Integer : OTr handle
//   $tag_t     : Text    : Tag path to the array item
//   $where_i   : Integer : 1-based insert position
//   $howMany_i : Integer : Number of elements to insert (default 1)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $where_i : Integer; $howMany_i : Integer)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $n_i; $i_i; $count_i; $effectivePos_i; $arrayType_i : Integer

$count_i:=Choose(Count parameters:C259<4; 1; $howMany_i)

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
				$n_i:=$arrayObj_o.numElements
				$arrayType_i:=OTr_zArrayType($arrayObj_o)
				
				// Clamp: if position exceeds array size, append at end
				$effectivePos_i:=Choose($where_i>$n_i; $n_i+1; $where_i)
				
				// Shift elements n..effectivePos up by count (preserves native types)
				For ($i_i; $n_i; $effectivePos_i; -1)
					$arrayObj_o[String:C10($i_i+$count_i)]:=$arrayObj_o[String:C10($i_i)]
				End for
				
				// Initialise new slots to type-appropriate default value
				For ($i_i; $effectivePos_i; $effectivePos_i+$count_i-1)
					$arrayObj_o[String:C10($i_i)]:=OTr_uNewValueForEmbeddedType($arrayType_i)
				End for
				
				$arrayObj_o.numElements:=$n_i+$count_i
				
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name:C684)
End if
