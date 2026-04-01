//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_SetArrayReal

// Method Type:    Shared

// Parameters:
C_LONGINT:C283($DictionaryID_i; $1)
C_TEXT:C284($Key_t; $2)
C_LONGINT:C283($inIndex_i; $3)
C_REAL:C285($inValue_r; $4)

// Local Variables:
C_TEXT:C284($ElementKeyLabel_t)

// Created by Wayne Stewart (Sep 11, 2007)
//     waynestewart@mac.com

// Modified by: Wayne Stewart (Sep 29, 2009)
//   Rewritten from OTX component to Dict

//   Dict_SetArrayReal(Dictionary; Key{; inIndex{; inValue}}) 

//   Parameter       Type        Description 
//   Dictionary        Longint     A handle to an object 
//   Key           String      Tag of the item to set 
//   inIndex         Number      Index of array element to set 
//   inValue         Number      Value to set
// ----------------------------------------------------

$DictionaryID_i:=$1
$Key_t:=$2
$inIndex_i:=$3
$inValue_r:=$4

Dict_LockInternalState(True:C214)

If (Dict_IsValid($DictionaryID_i))
	$ElementKeyLabel_t:=$Key_t+"."+String:C10($inIndex_i)
	Dict_SetReal($DictionaryID_i; $ElementKeyLabel_t; $inValue_r)
End if 

Dict_LockInternalState(False:C215)