//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SizeOfArray (inObject; inTag) --> Longint

// Returns the number of elements in an array item.
// Does not count element 0. Returns 0 if the handle
// is invalid, the tag does not exist, or the tag
// does not reference an array item.

// **ORIGINAL DOCUMENTATION**

// OT SizeOfArray returns the number of elements in an array item within an object.

// If *inObject* is not a valid object handle, if no item in the object has the given
// tag, or if the item’s type is not an array type, an error is generated, *OK* is set to
// zero, and zero is returned.



// *OT SortArrays* performs a multilevel sort on one or more arrays in *inObject*. You
// may sort up to seven arrays at once with this command.

// If *inObject* is not a valid object handle, if no item in the object has the given
// tag, if the item’s type is not a sortable array type, if all of the arrays do not have
// the same number of elements, or if a direction is not valid, an error is generated and
// *OK* is set to zero.

// The direction should be one of three values to indicate how to sort the array:

// Value Sort direction

// ">" Ascending

// "<" Descending

// "*" Move with previous array

// For example, to sort parallel arrays of names and associated ids, you would use
// something like this:

// OT SortArrays($object;"names";">";"ids";"*")

// To sort a group of addresses by state and then city within each state, you would use
// something like this:

// OT SortArrays($object;"states";">";"cities";">")

// Object Info Routines

// The following routines provide the ability to obtain complete information about an
// object as a whole. To obtain information about individual items within an object, see
// “Item Info Routines” on page 88.



// To test whether a given *Longint* value is a valid object handle, use *OT IsObject*.
// If inObject points to a valid object, 1 is returned. If inObject* * is zero or points
// to some other type of object, zero is returned.

// While it is possible to construct a BLOB that would fool ObjectTools into thinking it
// was a object, this is extremely unlikely.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)

// Returns:
//   $size_i : Integer : Number of elements (not counting element 0), or 0

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is object type argument
//     to prevent crash when tag holds a scalar rather than an array.
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
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
					$size_i:=$arrayObj_o.numElements
			End if
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name:C684)
End if

OTr_zRemoveFromCallStack(Current method name)
