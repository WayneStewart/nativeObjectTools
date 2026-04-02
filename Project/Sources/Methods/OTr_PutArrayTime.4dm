//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArrayTime ($handle_i : Integer; \
//   $tag_t : Text; $index_i : Integer; $value_h : Time)

// Sets a single element of a Time array item.
// Times are encoded to text via OTr_uTimeToText for storage.
// The tag must reference an existing Time array and
// $index_i must be in range 0..numElements.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $index_i  : Integer : Element index (0 = default element)
//   $value_h  : Time    : Value to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_h : Time)

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $arrayType_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$arrayObj_o:=OB Get($parent_o; $leafKey_t)
			$arrayType_i:=OTr_zArrayType($arrayObj_o)
			If ($arrayType_i=Time array:K8:29)
				If (($index_i>=0) & ($index_i<=$arrayObj_o.numElements))
					$arrayObj_o[String($index_i)]:=OTr_uTimeToText($value_h)
					OTr_zSetOK(1)
				Else
					OTr_zError("Index out of range"; Current method name)
					OTr_zSetOK(0)
				End if
			Else
				OTr_zError("Tag does not reference a Time array"; Current method name)
				OTr_zSetOK(0)
			End if
		Else
			OTr_zError("Tag not found"; Current method name)
			OTr_zSetOK(0)
		End if
	End if
Else
	OTr_zError("Invalid handle"; Current method name)
	OTr_zSetOK(0)
End if

OTr_zUnlock
