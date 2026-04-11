//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_InsertElement (inObject; inTag; inWhere {; inHowMany})

// Inserts one or more empty elements into an OTr array
// at position $inWhere_i (1-based). Existing elements at
// and above $inWhere_i are shifted up by $inHowMany_i.
// Inserted elements are initialised to the type's default value.
// If $inWhere_i exceeds numElements, elements are appended
// at the end. $inHowMany_i defaults to 1 if omitted.
// Element 0 (the pre-selection slot) is never affected.

// Access: Shared

// Parameters:
//   $inObject_i  : Integer : OTr inObject
//   $inTag_t     : Text    : Tag path to the array item (inTag)
//   $inWhere_i   : Integer : 1-based insert position (inWhere)
//   $inHowMany_i : Integer : Number of elements to insert; default 1 (inHowMany)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is object type argument
//     to prevent crash when tag holds a scalar rather than an array.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inWhere_i : Integer; $inHowMany_i : Integer)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $n_i; $i_i; $count_i; $effectivePos_i; $arrayType_i : Integer

$count_i:=Choose(Count parameters:C259<4; 1; $inHowMany_i)

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
				$n_i:=$arrayObj_o.numElements
				$arrayType_i:=OTr_zArrayType($arrayObj_o)
				
				// Clamp: if position exceeds array size, append at end
				$effectivePos_i:=Choose($inWhere_i>$n_i; $n_i+1; $inWhere_i)
				
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

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
