//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX GetArrayText

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_LONGINT:C283($inIndex_i; $3)
C_TEXT:C284($0; $outArrayElement_t)

// Local Variables:
C_LONGINT:C283($MethodItemType_i)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

// Discussion 
//   OT GetArrayText gets a value in inObject from the array item referenced by inTag. 
//   If the object is not a valid object handle, an error is generated, OK is set to zero, 
//   and zero is returned. 
//   If no item in the object has the given tag, zero is returned. If the FailOnNoItem 
//   option is set, an error is generated and OK is set to zero. 
//   If an item with the given tag exists and has the type Longint array, and inIndex is 
//   in the range (0..OT SizeOfArray(inObject; inTag)), the value of the requested 
//   element is returned. 
//   If an item with the given tag exists and has any other type, or if the index is out 
//   of range, an error is generated, OK is set to zero, and zero is returned. 
//   See Also 

//   OT GetArrayText(inObject; inTag; inIndex) => Number 
//   Parameter           Type        Description 
//   inObject            Longint     A handle to an object 
//   inTag               String      Tag of the item to retrieve 
//   inIndex             Number      Index of array element to retrieve 
//   Function result     Number      The array element’s contents

// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$inTag_t:=$2
$inIndex_i:=$3
$MethodItemType_i:=Text array:K8:16

OTX GetArrayElement($inObject_i; $inTag_t; $inIndex_i; $MethodItemType_i; ->$outArrayElement_t)

$0:=$outArrayElement_t