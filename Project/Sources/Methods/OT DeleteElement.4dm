//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT DeleteElement (inObject; inTag; inWhere {; inHowMany})

// Deletes one or more elements from an OTr array
// starting at position $inWhere_i (1-based). Elements
// after the deleted range are shifted down by $inHowMany_i.
// If the array holds Blob or Picture types, binary slots
// for all deleted elements are released before the shift.
// If $inWhere_i exceeds numElements, nothing is done and no
// error is reported. If the range extends beyond the end
// of the array, only elements up to numElements are deleted.
// $inHowMany_i defaults to 1 if omitted.
// Element 0 (the pre-selection slot) is never affected.

// Access: Shared

// Parameters:
//   $inObject_i  : Integer : OTr inObject
//   $inTag_t     : Text    : Tag path to the array item (inTag)
//   $inWhere_i   : Integer : 1-based position of first element to delete (inWhere)
//   $inHowMany_i : Integer : Number of elements to delete; default 1 (inHowMany)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inWhere_i : Integer; $inHowMany_i : Integer)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $n_i; $i_i; $count_i; $last_i : Integer

$count_i:=Choose(Count parameters:C259<4; 1; $inHowMany_i)

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
				$n_i:=$arrayObj_o.numElements
				
				If ($inWhere_i<=$n_i)
					// Clamp count so we don't exceed the array end
					$last_i:=Choose($inWhere_i+$count_i-1>$n_i; $n_i; $inWhere_i+$count_i-1)
					$count_i:=$last_i-$inWhere_i+1
					
					// Shift elements above the deleted range down by count
					For ($i_i; $inWhere_i; $n_i-$count_i)
						$arrayObj_o[String:C10($i_i)]:=$arrayObj_o[String:C10($i_i+$count_i)]
					End for
					
					// Remove the now-duplicate trailing keys
					For ($i_i; $n_i-$count_i+1; $n_i)
						OB REMOVE:C1226($arrayObj_o; String:C10($i_i))
					End for
					
					$arrayObj_o.numElements:=$n_i-$count_i
					
				// else: $inWhere_i > $n_i — do nothing, no error
				End if
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name:C684)
End if

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
