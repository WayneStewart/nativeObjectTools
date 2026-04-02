//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayPicture ($handle_i : Integer; \
//   $tag_t : Text; $index_i : Integer) -> $value_g : Picture

// Retrieves a single element from a Picture array item.
// The stored "pic:N" reference is decoded via
// OTr_uTextToPicture. Returns an empty Picture on any
// error or out-of-range index.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $index_i  : Integer : Element index (0 = default element)

// Returns:
//   $value_g : Picture : Element value, or empty Picture on any failure

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $index_i : Integer)->$value_g : Picture

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $arrayType_i : Integer

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get($parent_o; $leafKey_t)
			$arrayType_i:=OTr_zArrayType($arrayObj_o)
			If ($arrayType_i=Picture array:K8:22)
				If (($index_i>=0) & ($index_i<=$arrayObj_o.numElements))
					If (OB Is defined($arrayObj_o; String($index_i)))
						$value_g:=OTr_uTextToPicture($arrayObj_o[String($index_i)])
						OTr_zSetOK(1)
					Else
						OTr_zSetOK(0)
					End if
				Else
					OTr_zSetOK(0)
				End if
			Else
				OTr_zError("Tag does not reference a Picture array"; Current method name)
				OTr_zSetOK(0)
			End if
		Else
			OTr_zSetOK(0)
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
	OTr_zSetOK(0)
End if
