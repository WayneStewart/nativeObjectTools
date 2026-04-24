//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetArrayDate (inObject; inTag; inIndex) --> Date

// Retrieves a single element from a Date array item.
// Returns \!00/00/00\! on any error or out-of-range index.

// **ORIGINAL DOCUMENTATION**

// *OT GetArrayDate* gets a value in *inObject* from the array item referenced by *inTag*.

// If the object is not a valid object handle, an error is generated, *OK* is set to
// zero, and \!00/00/00\! is returned.

// If no item in the object has the given tag, \!00/00/00\! is returned. If the
// *FailOnNoItem* option is set, an error is generated and *OK* is set to zero.

// If an item with the given tag exists and has the type *Date array*, and *inIndex* is
// in the range (0..*OT SizeOfArray*(*inObject*; *inTag*)), the value of the requested
// element is returned.

// If an item with the given tag exists and has any other type, or if the index is out of
// range, an error is generated, *OK* is set to zero, and \!00/00/00\! is returned.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_d : Date : Element value, or !00/00/00! on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-11 - Added If/Else native/text retrieval guard
//   via stored-type inspection. See OT GetDate for strategy details.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_d : Date

OTr_z_AddToCallStack(Current method name:C684)

var $raw_v : Variant

$raw_v:=OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Date array:K8:20)
If (Value type:C1509($raw_v)#Is undefined:K8:13)
	If (Value type:C1509($raw_v)=Is text:K8:3)
		$result_d:=OTr_u_TextToDate($raw_v)
	Else 
		$result_d:=$raw_v
	End if 
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
