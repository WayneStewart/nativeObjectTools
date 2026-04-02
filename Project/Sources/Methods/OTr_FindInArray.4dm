//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_FindInArray (handle ; tag; value{; startFrom}) --> Integer

// Searches an array stored in an OTr object for a
// value matching inValue. The value is passed as text
// and converted to the stored array type before
// searching.
//
// For Boolean arrays, "true" or "1" are treated as
// True; any other value is treated as False.
//
// Not supported for Pointer, BLOB, or Picture arrays.
// If the array type does not support searching, or if
// the handle or tag are invalid, an error is generated,
// OK is set to zero, and -1 is returned.
//
// The result matches the native Find in array command:
// the 1-based index of the first matching element, or
// -1 if the value is not found in the array.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $value_t  : Text    : Value to search for (as text)
//   $startFrom_i : Integer : Where to start from, optional defaults to 1

// Returns:
//   $result_i : Integer : 1-based index of match, or -1

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $value_t : Text; $startFrom_i : Integer)->$result_i : Integer

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

$startFrom_i:=Choose:C955(Count parameters:C259=4; $startFrom_i; 1)

$result_i:=-1

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			$type_i:=OTr_zArrayType($arrayObj_o)
			If ($type_i=-1)
				OTr_zError("Tag does not reference an array"; Current method name:C684)
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
				
				If (OK=1)
					OTr_zArrayFromObject($arrayObj_o; $workPtr)
					
					// Search using native Find in array with type conversion
					Case of 
						: (($type_i=Text array:K8:16) | ($type_i=String array:K8:15))
							$result_i:=Find in array:C230($Work_at; $value_t; $startFrom_i)
							
						: ($type_i=LongInt array:K8:19)
							$result_i:=Find in array:C230($Work_ai; Num:C11($value_t); $startFrom_i)
							
						: ($type_i=Integer array:K8:18)
							$result_i:=Find in array:C230($Work_ai; Num:C11($value_t); $startFrom_i)
							
						: ($type_i=Real array:K8:17)
							$result_i:=Find in array:C230($Work_ar; Num:C11($value_t); $startFrom_i)
							
						: ($type_i=Boolean array:K8:21)
							$searchBool_b:=(($value_t="true") | ($value_t="1"))
							$result_i:=Find in array:C230($Work_ab; $searchBool_b; $startFrom_i)
							
						: ($type_i=Date array:K8:20)
							$searchDate_d:=OTr_uTextToDate($value_t)
							$result_i:=Find in array:C230($Work_ad; $searchDate_d; $startFrom_i)
							
						: ($type_i=Time array:K8:29)
							$search_h:=OTr_uTextToTime($value_t)
							$result_i:=Find in array:C230($Work_ah; $search_h; $startFrom_i)
							
					End case 
				End if 
			End if 
		End if 
	End if 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 
