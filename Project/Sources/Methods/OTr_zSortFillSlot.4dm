//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_zSortFillSlot
//   ($slot_i : Integer; $arrayObj_o : Object;
//    $type_i : Integer)

// Fills the process-scope scratch array for one sort
// slot from an OTr array object. The target array is
// addressed via OTr_zSortSlotPointer using the slot
// number and type. OTr_zArrayFromObject handles
// resizing and all type conversions (Date, Time, etc.).

// Access: Private

// Parameters:
//   $slot_i    : Integer : Sort slot (1..7)
//   $arrayObj_o: Object  : OTr array object to read from
//   $type_i    : Integer : OTr array type constant

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($slot_i : Integer; $arrayObj_o : Object; $type_i : Integer)

OTr_zArrayFromObject($arrayObj_o; OTr_zSortSlotPointer($slot_i; $type_i))
