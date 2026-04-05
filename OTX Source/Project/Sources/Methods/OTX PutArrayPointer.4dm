//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX PutArrayPointer

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_LONGINT:C283($inIndex_i; $3)
C_POINTER:C301($inValue_ptr; $4)

// Local Variables:
C_LONGINT:C283($MethodItemType_i)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

// Discussion 
//   OT PutArrayPointer sets an element of an array in inObject. 
//   If the object is not a valid object handle, an error is generated, OK is set to zero, and zero is returned. 
//   If no item in the object has the given tag, an error is generated and OK is set to zero. 
//   If an item with the given tag exists and has the type Pointerint array, and inIndex is 
//   in the range (0..OT SizeOfArray(inObject; inTag)), the value of the requested 
//   element is set to inValue. 
//   If an item with the given tag exists and has any other type, or if the index is out 
//   of range, an error is generated and OK is set to zero. 

//   See Also 
//   OT GetArrayPointer 

//   OT PutArrayPointer(inObject; inTag{; inIndex{; inValue}}) 

//   Parameter       Type        Description 
//   inObject        Pointerint     A handle to an object 
//   inTag           String      Tag of the item to set 
//   inIndex         Number      Index of array element to set 
//   inValue         Number      Value to set
// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$inTag_t:=$2
$inIndex_i:=$3
$inValue_ptr:=$4

$MethodItemType_i:=Pointer array:K8:23

OTX PutArrayElement($inObject_i; $inTag_t; $inIndex_i; $MethodItemType_i; ->$inValue_ptr)