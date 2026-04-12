//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_ArrayType ($arrayObj_o : Object) --> Integer

// Returns the stored arrayType value from an OTr
// array object. Returns -1 if the object is null
// or does not contain an arrayType property.

// This is the primitive used by OTr_z_ArrayType and
// any method that has already resolved its array object
// and does not need to go through a handle/tag lookup.

// Access: Private

// Parameters:
//   $arrayObj_o : Object : OTr array object

// Returns:
//   $arrayType_i : Integer : Stored arrayType, or -1

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($arrayObj_o : Object)->$arrayType_i : Integer

$arrayType_i:=-1

If (OB Is defined:C1231($arrayObj_o; "arrayType"))
	$arrayType_i:=$arrayObj_o.arrayType
End if 
