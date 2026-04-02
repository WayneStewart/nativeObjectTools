//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_zSortSlotPointer
//   ($slot_i : Integer; $type_i : Integer) --> Pointer

// Returns a pointer to the interprocess scratch array
// for the given sort slot number and OTr array type.
//
// Slot 1..7 maps to <>OTR_Sort1_* .. <>OTR_Sort7_*.
// Type suffix mapping:
//   Text/String   -> _at   LongInt/Integer -> _ai
//   Real          -> _ar   Date            -> _ad
//   Time          -> _ah   Boolean         -> _ab

// Access: Private

// Parameters:
//   $slot_i : Integer : Sort slot (1..7)
//   $type_i : Integer : OTr array type constant

// Returns:
//   Pointer : Pointer to the matching interprocess array

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($slot_i : Integer; $type_i : Integer)->$ptr_p : Pointer

var $suffix_t : Text

Case of 
	: ($type_i=Text array:K8:16) | ($type_i=String array:K8:15)
		$suffix_t:="t"
	: ($type_i=LongInt array:K8:19) | ($type_i=Integer array:K8:18)
		$suffix_t:="i"
	: ($type_i=Real array:K8:17)
		$suffix_t:="r"
	: ($type_i=Date array:K8:20)
		$suffix_t:="d"
	: ($type_i=Time array:K8:29)
		$suffix_t:="h"
	: ($type_i=Boolean array:K8:21)
		$suffix_t:="b"
End case 

$ptr_p:=Get pointer:C304("<>OTR_Sort"+String:C10($slot_i)+"_a"+$suffix_t)
