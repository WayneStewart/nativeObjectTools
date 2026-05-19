//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_u_AccessArrayElement (inObject; inTag; inIndex; inArrayType {; inValue}) --> Variant

// Middle-layer dispatcher — Mode synthesis and mechanism dispatch
// (Phase 100, §3.2 — "Middle Layer — Mode Synthesis and Dispatch").
//
// Synthesises the access mode from arity, validates it, then delegates
// to the appropriate Inner-layer method based on Storage.OTr.mechanism.
// Under OTR IP Arrays: OTr_u_IPArrayAccess. Under OTR Storage: error
// (not operational until W8). No storage state is touched directly here.

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
// Wayne Stewart, 2026-05-19 - W1 (Phase 100): synthesise $mode_i (OTR Get Element /
//       OTR Put Element) at entry from Count parameters; replace arity-based
//       branch with constant-based branch; add mode-validation guard.
// Wayne Stewart, 2026-05-19 - W7 (Phase 100): reshaped as pure Middle-layer
//       dispatcher; IP-array body extracted to OTr_u_IPArrayAccess (Inner layer).
//       Dispatcher reads Storage.OTr.mechanism and delegates accordingly.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inArrayType_i : Integer; $inValue_v : Variant)->$result_v : Variant

var $mode_i : Integer

// mode synthesis
If (Count parameters:C259=5)
	$mode_i:=OTR Put Element
Else
	$mode_i:=OTR Get Element
End if

// mode validation (unreachable given synthesis above; guards Middle→Inner contract)
If (($mode_i#OTR Get Element) & ($mode_i#OTR Put Element))
	OTr_z_Error("Unrecognised access mode"; Current method name:C684)
	OTr_z_SetOK(0)
Else
	Case of
		: (Storage:C1525.OTr.mechanism=OTR IP Arrays)
			If ($mode_i=OTR Put Element)
				$result_v:=OTr_u_IPArrayAccess($inObject_i; $inTag_t; $inIndex_i; $inArrayType_i; $mode_i; $inValue_v)
			Else
				$result_v:=OTr_u_IPArrayAccess($inObject_i; $inTag_t; $inIndex_i; $inArrayType_i; $mode_i)
			End if
		: (Storage:C1525.OTr.mechanism=OTR Storage)
			//  Storage mechanism not operational until W8.
			OTr_z_Error("Storage mechanism not yet implemented"; Current method name:C684)
			OTr_z_SetOK(0)
	End case
End if
