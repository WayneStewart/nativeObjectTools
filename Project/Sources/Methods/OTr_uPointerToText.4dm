//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uPointerToText ($thePointer_ptr : Pointer) --> Text

// Serialises a Pointer to a storable text string.
// Format: "variableName;tableNum;fieldNum"
//   Variable pointer:    "myVar;-1;0"
//   Array element:       "myArr;3;0"
//   Table pointer:       ";2;0"
//   Field pointer:       ";2;5"

// Access: Private

// Parameters:
//   $thePointer_ptr : Pointer : Pointer to serialise

// Returns:
//   $pointerAsText_t : Text : Serialised text

// Created by Wayne Stewart, 2026-04-01
// Based on Dict_SetPointer by Rob Laveaux
// ----------------------------------------------------

#DECLARE($thePointer_ptr : Pointer)->$pointerAsText_t : Text

var $variableName_t : Text
var $tableNum_i; $fieldNum_i : Integer

RESOLVE POINTER:C394($thePointer_ptr; $variableName_t; $tableNum_i; $fieldNum_i)
$pointerAsText_t:=$variableName_t+";"+String:C10($tableNum_i)+";"+String:C10($fieldNum_i)
