//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_FindInArray (inObject; inTag; inValue {; inStart}) --> Longint

// Searches an array stored in an OTr object for a
// value matching inValue. The value is passed as text
// and converted to the stored array type before
// searching.
//
// For Boolean arrays, "true" or "1" are treated as
// True; any other value is treated as False.
//
// Not supported for Pointer, BLOB, or Picture arrays.
// If inObject is not a valid object handle, if no item in
// the object has the given tag, or if the item's type is not
// an array type, an error is generated, OK is set to zero,
// and -1 is returned.
//
// The result matches the native Find in array command:
// the 1-based index of the first matching element, or
// -1 if the value is not found in the array.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr handle
//   $inTag_t    : Text    : Tag path to the array item
//   $inValue_t  : Text    : Value to search for (as text)
//   $inStart_i      : Integer : Starting index, 1-based; default 1 (inStart)

// Returns:
//   $result_i : Integer : 1-based index of match, or -1

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is object type argument
//     to prevent crash when tag holds a scalar rather than an array.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_t : Text; $inStart_i : Integer)->$result_i : Integer

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $type_i : Integer
var $workPtr : Pointer
var $searchBool_b : Boolean
var $searchDate_d : Date
var $search_h : Time

ARRAY TEXT:C222($Work_at; 0)
ARRAY LONGINT:C221($Work_ai; 0)

ARRAY REAL:C219($Work_ar; 0)
ARRAY BOOLEAN:C223($Work_ab; 0)
ARRAY DATE:C224($Work_ad; 0)
ARRAY TIME:C1223($Work_ah; 0)

$inStart_i:=Choose:C955(Count parameters:C259=4; $inStart_i; 1)

$result_i:=-1

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
			$type_i:=OTr_zArrayType($arrayObj_o)
			If ($type_i=-1)
				OTr_zError("Tag does not reference an array"; Current method name:C684)
				OTr_zSetOK(0)
			Else 
				// Assign working pointer to the appropriate typed array
				Case of 
					: (($type_i=Text array:K8:16) | ($type_i=String array:K8:15))
						$workPtr:=->$Work_at
						
					: ($type_i=LongInt array:K8:19) | ($type_i=Integer array:K8:18)
						$workPtr:=->$Work_ai
						
					: ($type_i=Real array:K8:17)
						$workPtr:=->$Work_ar
						
					: ($type_i=Boolean array:K8:21)
						$workPtr:=->$Work_ab
						
					: ($type_i=Date array:K8:20)
						$workPtr:=->$Work_ad
						
					: ($type_i=Time array:K8:29)
						$workPtr:=->$Work_ah
						
					Else 
						OTr_zError("Array type not supported for Find in array"; \
							Current method name:C684)
				End case 
				
				If ($workPtr#Null)
					OTr_zArrayFromObject($arrayObj_o; $workPtr)

					// Search using native Find in array with type conversion.
					// A result of -1 means "not found" — that is a valid search
					// outcome, not an error. OK is not modified on the search path;
					// it is only set to 0 on genuine error paths above.
					Case of
						: (($type_i=Text array:K8:16) | ($type_i=String array:K8:15))
							$result_i:=Find in array:C230($Work_at; $inValue_t; $inStart_i)

						: ($type_i=LongInt array:K8:19)
							$result_i:=Find in array:C230($Work_ai; Num:C11($inValue_t); $inStart_i)

						: ($type_i=Integer array:K8:18)
							$result_i:=Find in array:C230($Work_ai; Num:C11($inValue_t); $inStart_i)

						: ($type_i=Real array:K8:17)
							$result_i:=Find in array:C230($Work_ar; Num:C11($inValue_t); $inStart_i)

						: ($type_i=Boolean array:K8:21)
							$searchBool_b:=(($inValue_t="true") | ($inValue_t="1"))
							$result_i:=Find in array:C230($Work_ab; $searchBool_b; $inStart_i)

						: ($type_i=Date array:K8:20)
							$searchDate_d:=OTr_uTextToDate($inValue_t)
							$result_i:=Find in array:C230($Work_ad; $searchDate_d; $inStart_i)

						: ($type_i=Time array:K8:29)
							$search_h:=OTr_uTextToTime($inValue_t)
							$result_i:=Find in array:C230($Work_ah; $search_h; $inStart_i)

					End case
				End if 
			End if 
		Else 
			OTr_zSetOK(0)
		End if 
	End if 
Else
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK(0)
End if

OTr_zRemoveFromCallStack(Current method name)
