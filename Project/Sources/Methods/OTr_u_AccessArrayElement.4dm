//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_u_AccessArrayElement (inObject; inTag; inIndex; inArrayType {; inValue}) --> Variant

// Unified array element accessor — the OTr equivalent of the
// OTX GetArrayElement / OTX PutArrayElement pair, combined
// into a single setter/getter method using the Variant type.
//
// When called with four parameters (Get mode): navigates to
// the element at inIndex within the array item at inTag and
// returns it as a Variant. OK is unchanged on success.
//
// When called with five parameters (Put mode): stores inValue
// into that element, then returns the stored value. The
// lock/unlock around any write is the caller's responsibility.
//
// In both modes, all error paths set OK to 0.
//
// Compatible type pairs are handled internally:
//   LongInt array / Integer array
//   Text array / String array

// Access: Private

// Parameters:
//   $inObject_i    : Integer : OTr object handle
//   $inTag_t       : Text    : Tag path to the array item
//   $inIndex_i     : Integer : Element index, 1-based; 0 = default element
//   $inArrayType_i : Integer : Expected OT array type constant
//   $inValue_v     : Variant : Value to store (optional — omit for Get mode)

// Returns:
//   $result_v : Variant : The element value after any Put; undefined on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inArrayType_i : Integer; $inValue_v : Variant)->$result_v : Variant

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $storedType_i : Integer
var $typeOK_b : Boolean
var $key_t : Text

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; ->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			If (OB Get type($parent_o; $leafKey_t) = Is object)
				$arrayObj_o := OB Get($parent_o; $leafKey_t)
				$storedType_i := OTr_zArrayType($arrayObj_o)

				$typeOK_b := ($storedType_i = $inArrayType_i)
				If (Not($typeOK_b))
					Case of
						: (($inArrayType_i = LongInt array) | ($inArrayType_i = Integer array))
							$typeOK_b := ($storedType_i = LongInt array) | ($storedType_i = Integer array)
						: (($inArrayType_i = Text array) | ($inArrayType_i = String array))
							$typeOK_b := ($storedType_i = Text array) | ($storedType_i = String array)
					End case
				End if

				If ($typeOK_b)
					If (($inIndex_i >= 0) & ($inIndex_i <= $arrayObj_o.numElements))
						$key_t := String($inIndex_i)
						If (Count parameters = 5)
							$arrayObj_o[$key_t] := $inValue_v
						End if
						If (OB Is defined($arrayObj_o; $key_t))
							$result_v := $arrayObj_o[$key_t]
						Else
							OTr_zSetOK(0)
						End if
					Else
						OTr_zError("Index out of range"; Current method name)
						OTr_zSetOK(0)
					End if
				Else
					OTr_zError("Array type mismatch"; Current method name)
					OTr_zSetOK(0)
				End if
			Else
				// The tag exists but holds a scalar, not an array object.
				OTr_zError("Array type mismatch"; Current method name)
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
