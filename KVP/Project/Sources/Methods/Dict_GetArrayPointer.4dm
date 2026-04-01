//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_GetArrayPointer

// Method Type:    Protected

// Parameters:
C_LONGINT:C283($DictionaryID_i; $1)
C_TEXT:C284($Key_t; $2)
C_LONGINT:C283($inIndex_i; $3)
C_POINTER:C301($0; $outArrayElement_ptr)

// Local Variables:
C_TEXT:C284($ElementKeyLabel_t)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

// Modified by: Wayne Stewart (Sep 29, 2009)
//   Rewritten from OTX component to Dict

//   Dict_GetArrayPointer(Dictionary; Key; inIndex) => Pointer 
//   Parameter           Type        Description 
//   Dictionary            Longint     A handle to an object 
//   Key               String      Tag of the item to retrieve 
//   inIndex             Number      Index of array element to retrieve 
//   Function result     Pointer      The array element’s contents

// ----------------------------------------------------

Dict_Init  //  Check the component is initialised

$DictionaryID_i:=$1
$Key_t:=$2
$inIndex_i:=$3

Dict_LockInternalState(True:C214)

If (Dict_IsValid($DictionaryID_i))
	$ElementKeyLabel_t:=$Key_t+"."+String:C10($inIndex_i)
	$outArrayElement_ptr:=Dict_GetPointer($DictionaryID_i; $ElementKeyLabel_t)
End if 

Dict_LockInternalState(False:C215)

$0:=$outArrayElement_ptr