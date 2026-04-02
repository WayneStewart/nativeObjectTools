//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayBLOB ($handle_i : Integer; \
//   $tag_t : Text; $index_i : Integer) -> $value_x : Blob

// Retrieves a single element from a Blob array item.
// The stored "blob:N" reference is decoded via
// OTr_uTextToBlob. Returns an empty BLOB on any
// error or out-of-range index.

// Access: Shared

// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $index_i  : Integer : Element index (0 = default element)

// Returns:
//   $value_x : Blob : Element value, or empty BLOB on any failure

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $index_i : Integer)->$value_x : Blob

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
			If ($arrayType_i=Blob array:K8:30)
				If (($index_i>=0) & ($index_i<=$arrayObj_o.numElements))
					If (OB Is defined($arrayObj_o; String($index_i)))
						$value_x:=OTr_uTextToBlob($arrayObj_o[String($index_i)])
						OTr_zSetOK(1)
					Else
						OTr_zSetOK(0)
					End if
				Else
					OTr_zSetOK(0)
				End if
			Else
				OTr_zError("Tag does not reference a Blob array"; Current method name)
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
