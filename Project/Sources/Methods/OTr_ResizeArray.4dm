//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ResizeArray ($handle_i : Integer; $tag_t : Text; $size_i : Integer)

// Resizes an array item to the specified number of
// elements (not counting element 0). If growing,
// new elements are appended with the array type's default value. If
// shrinking, excess elements are removed from the end.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $size_i   : Integer : New number of elements

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $size_i : Integer)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $currentSize_i; $index_i; $arrayType_i : Integer
var $storedVal_t : Text

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			If (OB Is defined:C1231($arrayObj_o; "numElements"))
				$currentSize_i:=$arrayObj_o.numElements
				$arrayType_i:=OTr_zArrayType($arrayObj_o)
				
				If ($size_i>$currentSize_i)
					// Grow: append type-appropriate default values
					For ($index_i; $currentSize_i+1; $size_i)
						$arrayObj_o[String:C10($index_i)]:=OTr_uNewValueForEmbeddedType($arrayType_i)
					End for 
					
				Else 
					If ($size_i<$currentSize_i)
						// Shrink: release binary slots then remove entries
						For ($index_i; $size_i+1; $currentSize_i)
							If (($arrayType_i=Blob array:K8:30) | ($arrayType_i=Picture array:K8:22))
								$storedVal_t:=OB Get:C1224($arrayObj_o; String:C10($index_i); Is text:K8:3)
								OTr_zReleaseBinaryRef($storedVal_t)
							End if 
							OB REMOVE:C1226($arrayObj_o; String:C10($index_i))
						End for 
					End if 
				End if 
				
				$arrayObj_o.numElements:=$size_i
				OTr_zSetOK(1)
			End if 
		End if 
	End if 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK(0)
End if 

OTr_zUnlock
