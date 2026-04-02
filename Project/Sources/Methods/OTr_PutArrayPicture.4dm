//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayPicture ($handle_i : Integer; \
//   $tag_t : Text; $index_i : Integer; $value_g : Picture)

// Sets a single element of a Picture array item.
// The Picture is stored via OTr_uPictureToText which
// allocates a slot in <>OTR_Pictures_apic and returns
// a "pic:N" reference text. If the element already holds
// a picture reference, the old slot is released first.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $index_i  : Integer : Element index (0 = default element)
//   $value_g  : Picture : Value to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_g : Picture)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $arrayType_i : Integer
var $existingRef_t : Text

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
			$arrayType_i:=OTr_zArrayType($arrayObj_o)
			If ($arrayType_i=Picture array:K8:22)
				If (($index_i>=0) & ($index_i<=$arrayObj_o.numElements))
					// Release any existing picture slot before allocating a new one
					$existingRef_t:=$arrayObj_o[String:C10($index_i)]
					OTr_zReleaseBinaryRef($existingRef_t)
					$arrayObj_o[String:C10($index_i)]:=OTr_uPictureToText($value_g)
					OTr_zSetOK  // (1)
				Else 
					OTr_zError("Index out of range"; Current method name:C684)
					OTr_zSetOK  // (0)
				End if 
			Else 
				OTr_zError("Tag does not reference a Picture array"; Current method name:C684)
				OTr_zSetOK  // (0)
			End if 
		Else 
			OTr_zError("Tag not found"; Current method name:C684)
			OTr_zSetOK  // (0)
		End if 
	End if 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK  // (0)
End if 

OTr_zUnlock
