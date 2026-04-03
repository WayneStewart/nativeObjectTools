//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ResizeArray (inObject; inTag; inSize)

// Resizes an array item to the specified number of
// elements (not counting element 0). If growing,
// new elements are appended with the array type's default value. If
// shrinking, excess elements are removed from the end.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inSize_i   : Integer : New number of elements (inSize)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inSize_i : Integer)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $currentSize_i; $index_i; $arrayType_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
				$currentSize_i:=$arrayObj_o.numElements
				$arrayType_i:=OTr_zArrayType($arrayObj_o)
				
				If ($inSize_i>$currentSize_i)
					// Grow: append type-appropriate default values
					For ($index_i; $currentSize_i+1; $inSize_i)
						$arrayObj_o[String:C10($index_i)]:=OTr_uNewValueForEmbeddedType($arrayType_i)
					End for 
					
				Else 
					If ($inSize_i<$currentSize_i)
							// Shrink: remove entries
							For ($index_i; $inSize_i+1; $currentSize_i)
							OB REMOVE:C1226($arrayObj_o; String:C10($index_i))
						End for 
					End if 
				End if 
				
				$arrayObj_o.numElements:=$inSize_i
				OTr_zSetOK(1)
			End if 
		End if 
	End if 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK(0)
End if 

OTr_zUnlock
