//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SizeOfArray (inObject; inTag) --> Longint

// Returns the number of elements in an array item.
// Does not count element 0. Returns 0 if the handle
// is invalid, the tag does not exist, or the tag
// does not reference an array item.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)

// Returns:
//   $size_i : Integer : Number of elements (not counting element 0), or 0

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text)->$size_i : Integer

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text

$size_i:=0

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
					$size_i:=$arrayObj_o.numElements
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name:C684)
End if

OTr_zRemoveFromCallStack(Current method name)
