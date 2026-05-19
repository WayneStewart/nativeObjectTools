//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_u_IPArrayAccess (inObject; inTag; inIndex; inArrayType; inMode {; inValue}) --> Variant

// Inner-layer array element accessor for the IP Arrays storage mechanism
// (Phase 100, §3.3 — "Inner Layer — Locked Storage Operations").
//
// Acquires the reentrant lock via OTr_z_Lock, performs the requested
// Get or Put operation directly on the IP-arrays store (<>OTR_Objects_ao),
// then releases the lock unconditionally on every exit path including all
// error branches (§3.3 "Error-path discipline").
//
// Mode is received as the explicit constant $inMode_i (OTR Get Element or
// OTR Put Element). The caller (OTr_u_AccessArrayElement) synthesises the
// mode from arity; this method never inspects Count parameters.
//
// Compatible type pairs handled internally:
//   LongInt array / Integer array
//   Text array / String array

// Access: Private

// Parameters:
//   $inObject_i    : Integer : OTr object handle
//   $inTag_t       : Text    : Tag path to the array item
//   $inIndex_i     : Integer : Element index, 1-based; 0 = default element
//   $inArrayType_i : Integer : Expected OT array type constant
//   $inMode_i      : Integer : OTR Get Element or OTR Put Element
//   $inValue_v     : Variant : Value to store (required for Put; omit for Get)

// Returns:
//   $result_v : Variant : The element value after any Put; undefined on any failure

// Created by Wayne Stewart, 2026-05-19
// Wayne Stewart, 2026-05-19 - W7 (Phase 100): extracted from OTr_u_AccessArrayElement
//       to realise the Inner layer of the three-layer architecture (§3.3).
//       Acquires/releases OTr_z_Lock internally; mode arrives as explicit
//       $inMode_i constant; mode synthesis and validation remain in the dispatcher.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; \
$inArrayType_i : Integer; $inMode_i : Integer; $inValue_v : Variant)->$result_v : Variant

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $storedType_i : Integer
var $typeOK_b : Boolean
var $key_t : Text

OTr_z_Lock($inObject_i)

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			If (OB Get type:C1230($parent_o; $leafKey_t)=Is object:K8:27)
				$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t)
				$storedType_i:=OTr_z_ArrayType($arrayObj_o)

				$typeOK_b:=($storedType_i=$inArrayType_i)
				If (Not:C34($typeOK_b))
					Case of
						: (($inArrayType_i=LongInt array:K8:19) | ($inArrayType_i=Integer array:K8:18))
							$typeOK_b:=($storedType_i=LongInt array:K8:19) | ($storedType_i=Integer array:K8:18)
						: (($inArrayType_i=Text array:K8:16) | ($inArrayType_i=String array:K8:15))
							$typeOK_b:=($storedType_i=Text array:K8:16) | ($storedType_i=String array:K8:15)
					End case
				End if

				If ($typeOK_b)
					If (($inIndex_i>=0) & ($inIndex_i<=$arrayObj_o.numElements))
						$key_t:=String:C10($inIndex_i)
						If ($inMode_i=OTR Put Element)
							$arrayObj_o[$key_t]:=$inValue_v
						End if
						If (OB Is defined:C1231($arrayObj_o; $key_t))
							$result_v:=$arrayObj_o[$key_t]
						Else
							OTr_z_SetOK(0)
						End if
					Else
						OTr_z_Error("Index out of range"; Current method name:C684)
						OTr_z_SetOK(0)
					End if
				Else
					OTr_z_Error("Array type mismatch"; Current method name:C684)
					OTr_z_SetOK(0)
				End if
			Else
				// The tag exists but holds a scalar, not an array object.
				OTr_z_Error("Array type mismatch"; Current method name:C684)
				OTr_z_SetOK(0)
			End if
		Else
			OTr_z_Error("Tag not found"; Current method name:C684)
			OTr_z_SetOK(0)
		End if
	End if
Else
	OTr_z_Error("Invalid handle"; Current method name:C684)
	OTr_z_SetOK(0)
End if

OTr_z_Unlock($inObject_i)
