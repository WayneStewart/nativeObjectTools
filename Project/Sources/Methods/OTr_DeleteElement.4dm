//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_DeleteElement
//   ($handle_i : Integer; $tag_t : Text; $where_i : Integer
//    {; $howMany_i : Integer})

// Deletes one or more elements from an OTr array
// starting at position $where_i (1-based). Elements
// after the deleted range are shifted down by $howMany_i.
// If the array holds Blob or Picture types, binary slots
// for all deleted elements are released before the shift.
// If $where_i exceeds numElements, nothing is done and no
// error is reported. If the range extends beyond the end
// of the array, only elements up to numElements are deleted.
// $howMany_i defaults to 1 if omitted.
// Element 0 (the pre-selection slot) is never affected.

// Access: Shared

// Parameters:
//   $handle_i  : Integer : OTr handle
//   $tag_t     : Text    : Tag path to the array item
//   $where_i   : Integer : 1-based position of first element to delete
//   $howMany_i : Integer : Number of elements to delete (default 1)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $where_i : Integer; $howMany_i : Integer)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $n_i; $i_i; $count_i; $last_i : Integer

$count_i:=Choose(Count parameters:C259<4; 1; $howMany_i)

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
				$n_i:=$arrayObj_o.numElements
				
				If ($where_i<=$n_i)
					// Clamp count so we don't exceed the array end
					$last_i:=Choose($where_i+$count_i-1>$n_i; $n_i; $where_i+$count_i-1)
					$count_i:=$last_i-$where_i+1
					
					// Shift elements above the deleted range down by count
					For ($i_i; $where_i; $n_i-$count_i)
						$arrayObj_o[String:C10($i_i)]:=$arrayObj_o[String:C10($i_i+$count_i)]
					End for
					
					// Remove the now-duplicate trailing keys
					For ($i_i; $n_i-$count_i+1; $n_i)
						OB REMOVE:C1226($arrayObj_o; String:C10($i_i))
					End for
					
					$arrayObj_o.numElements:=$n_i-$count_i
					
				// else: $where_i > $n_i — do nothing, no error
				End if
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name:C684)
End if

OTr_zUnlock
