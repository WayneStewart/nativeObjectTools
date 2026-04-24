//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT SortArrays (inObject; inTag1; inDirection1 … inTag7; inDirection7)

// Sorts one or more OTr arrays within the same OTr object via MULTI SORT ARRAY.
// Up to seven tag/direction pairs may be supplied. Direction codes:
// - ">" ascending
// - "<" descending
// - "*" slave (moves with the preceding key array)

// At least one pair must be ">" or "<". All active arrays must have the same number
// of elements. BLOB, Picture, and Pointer arrays cannot be sorted in any position,
// including slave.

// **ORIGINAL DOCUMENTATION**

// *OT SortArrays* performs a multilevel sort on one or more arrays in *inObject*.
// You may sort up to seven arrays at once with this command.

// If *inObject* is not a valid object handle, if no item in the object has the given
// tag, if the item's type is not a sortable array type, if all of the arrays do not
// have the same number of elements, or if a direction is not valid, an error is
// generated and *OK* is set to zero.

// The direction parameter for each array should be one of:
// - ">" — ascending key
// - "<" — descending key
// - "*" — move with previous array (slave)

// For example, to sort parallel arrays of names and associated ids:
// OT SortArrays($object;"names";">";"ids";"*")

// To sort addresses by state and then by city within each state:
// OT SortArrays($object;"states";">";"cities";">")

// Access: Shared

// Parameters:
//   $inObject_i               : Integer : OTr inObject
//   $inTag1_t .. $inTag7_t    : Text    : Array tag name (inTag1..inTag7)
//   $inDirection1_t .. $inDirection7_t : Text : Sort direction (inDirection1..inDirection7)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Removed spurious OTr_z_SetOK(1) on
//   success path (see OTr-OK0-Conditions specification).
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; \
$inTag1_t : Text; $inDirection1_t : Text; \
$inTag2_t : Text; $inDirection2_t : Text; \
$inTag3_t : Text; $inDirection3_t : Text; \
$inTag4_t : Text; $inDirection4_t : Text; \
$inTag5_t : Text; $inDirection5_t : Text; \
$inTag6_t : Text; $inDirection6_t : Text; \
$inTag7_t : Text; $inDirection7_t : Text)


OTr_z_AddToCallStack(Current method name:C684)

var $pairCount_i; $keyCount_i; $ptrIdx_i : Integer
var $n_i; $j_i; $slot_i : Integer
var $continue_b : Boolean
var $params_o; $temp_o; $arrayObjStore_o; $slotObj_o : Object

ARRAY TEXT:C222($tags_at; 7)
ARRAY TEXT:C222($dirs_at; 7)
ARRAY INTEGER:C220($types_ai; 7)

// ------------------------------------------------
// Phase 1 — Count pairs / validate parameter count
// ------------------------------------------------
$pairCount_i:=(Count parameters:C259-1)/2
$continue_b:=True:C214

If ($pairCount_i<1)
	OTr_z_Error("At least one tag/direction pair required"; \
		Current method name:C684)
	OTr_z_SetOK(0)
	$continue_b:=False:C215
End if 

// Populate tag/dir arrays from named parameters
If ($continue_b)
	$tags_at{1}:=$inTag1_t
	$dirs_at{1}:=$inDirection1_t
	If ($pairCount_i>=2)
		$tags_at{2}:=$inTag2_t
		$dirs_at{2}:=$inDirection2_t
	End if 
	If ($pairCount_i>=3)
		$tags_at{3}:=$inTag3_t
		$dirs_at{3}:=$inDirection3_t
	End if 
	If ($pairCount_i>=4)
		$tags_at{4}:=$inTag4_t
		$dirs_at{4}:=$inDirection4_t
	End if 
	If ($pairCount_i>=5)
		$tags_at{5}:=$inTag5_t
		$dirs_at{5}:=$inDirection5_t
	End if 
	If ($pairCount_i>=6)
		$tags_at{6}:=$inTag6_t
		$dirs_at{6}:=$inDirection6_t
	End if 
	If ($pairCount_i>=7)
		$tags_at{7}:=$inTag7_t
		$dirs_at{7}:=$inDirection7_t
	End if 
End if 

// ------------------------------------------------
// Phase 2 — Validate handle (no lock needed)
// ------------------------------------------------
If ($continue_b)
	If (Not:C34(OTr_z_IsValidHandle($inObject_i)))
		OTr_z_Error("Invalid handle"; Current method name:C684)
		OTr_z_SetOK(0)
		$continue_b:=False:C215
	End if 
End if 

// ------------------------------------------------
// Phase 3 — Resolve paths + validate types
// Each pair validated via OTr_z_SortValidatePair.
// arrayObj references stored in $arrayObjStore_o
// under keys "a1".."a7" for write-back in Phase 8.
// ------------------------------------------------
If ($continue_b)
	$arrayObjStore_o:=New object:C1471
	$params_o:=New object:C1471("handle"; $inObject_i)
	For ($slot_i; 1; $pairCount_i)
		If ($continue_b)
			$params_o.tag:=$tags_at{$slot_i}
			$params_o.dir:=$dirs_at{$slot_i}
			$continue_b:=OTr_z_SortValidatePair($params_o)
			If ($continue_b)
				$types_ai{$slot_i}:=$params_o.arrayType
				$arrayObjStore_o["a"+String:C10($slot_i)]:=$params_o.arrayObj
				If ($slot_i=1)
					$n_i:=$params_o.numElements
				Else 
					If ($params_o.numElements#$n_i)
						OTr_z_Error("Array size mismatch: "+\
							$tags_at{$slot_i}; Current method name:C684)
						OTr_z_SetOK(0)
						$continue_b:=False:C215
					End if 
				End if 
			End if 
		End if 
	End for 
End if 

// ------------------------------------------------
// Phase 4 — Count key pairs (direction ">" or "<")
// ------------------------------------------------
If ($continue_b)
	$keyCount_i:=0
	For ($slot_i; 1; $pairCount_i)
		If ($dirs_at{$slot_i}#"*")
			$keyCount_i:=$keyCount_i+1
		End if 
	End for 
	If ($keyCount_i=0)
		OTr_z_Error("No sort keys specified; all pairs are slaves"; \
			Current method name:C684)
		OTr_z_SetOK(0)
		$continue_b:=False:C215
	End if 
End if 

// ------------------------------------------------
// Phase 5 — Fill interprocess scratch arrays
//           (key pairs only; slaves skipped)
// ------------------------------------------------
If ($continue_b)
	For ($slot_i; 1; $pairCount_i)
		If ($dirs_at{$slot_i}#"*")
			$slotObj_o:=$arrayObjStore_o["a"+String:C10($slot_i)]
			OTr_z_SortFillSlot($slot_i; $slotObj_o; $types_ai{$slot_i})
		End if 
	End for 
End if 

// ------------------------------------------------
// Phase 6 — Build MULTI SORT ARRAY args
//   $ptrs_ap    : pointers to key arrays + index
//   $sortOrd_ai : 1 ascending; -1 descending; 0 slave
// Last slot is always the tracked index array.
// ------------------------------------------------
If ($continue_b)
	ARRAY LONGINT:C221(OTR_SortIdx_ai; $n_i)
	For ($j_i; 1; $n_i)
		OTR_SortIdx_ai{$j_i}:=$j_i
	End for 
	
	ARRAY POINTER:C280($ptrs_aptr; $keyCount_i+1)
	ARRAY LONGINT:C221($sortOrd_ai; $keyCount_i+1)
	$ptrIdx_i:=0
	
	For ($slot_i; 1; $pairCount_i)
		If ($dirs_at{$slot_i}#"*")
			$ptrIdx_i:=$ptrIdx_i+1
			$ptrs_aptr{$ptrIdx_i}:=OTr_z_SortSlotPointer($slot_i; $types_ai{$slot_i})
			$sortOrd_ai{$ptrIdx_i}:=Choose:C955($dirs_at{$slot_i}=">"; 1; -1)
		End if 
	End for 
	
	$ptrs_aptr{$keyCount_i+1}:=->OTR_SortIdx_ai
	$sortOrd_ai{$keyCount_i+1}:=0
End if 

// ------------------------------------------------
// Phase 7 — Execute sort
// ------------------------------------------------
If ($continue_b)
	MULTI SORT ARRAY:C718($ptrs_aptr; $sortOrd_ai)
End if 

// ------------------------------------------------
// Phase 8 — Write sorted order back (under lock)
// All pairs reordered via OTR_SortIdx_ai.
// Element 0 is not touched.
// ------------------------------------------------
If ($continue_b)
	OTr_z_Lock
	For ($slot_i; 1; $pairCount_i)
		$slotObj_o:=$arrayObjStore_o["a"+String:C10($slot_i)]
		$temp_o:=OB Copy:C1225($slotObj_o)
		For ($j_i; 1; $n_i)
			$slotObj_o[String:C10($j_i)]:=\
				$temp_o[String:C10(OTR_SortIdx_ai{$j_i})]
		End for 
	End for 
	OTr_z_Unlock
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
