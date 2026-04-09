//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT LoadFromText (inJSON) --> Longint

// Parses a JSON string and stores the resulting object in
// a new OTr handle. If the top-level JSON value is an array,
// it is automatically wrapped in an object keyed "OBJ" to
// preserve OTr's object-at-root convention. JSON parse
// errors are caught silently; check the return value to
// know whether parsing succeeded.
// Returns 0 if inJSON is empty or cannot be parsed.

// Access: Shared

// Parameters:
//   $inJSON_t : Text : JSON string to parse

// Returns:
//   $handle_i : Integer : New OTr handle, \
//                         or 0 if parsing failed

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inJSON_t : Text)->$handle_i : Integer

OTr_zAddToCallStack(Current method name)

var $parsed_o : Object
var $slot_i : Integer
var $currentErrMethod_t : Text

$handle_i:=0

If ($inJSON_t#"")

	// Strip UTF-8 BOM if present (character code 65279)
	If (Character code($inJSON_t[[1]])=65279)
		$inJSON_t:=Substring($inJSON_t; 2)
	End if

	// Wrap top-level arrays so an object is always at the root
	If ($inJSON_t[[1]]="[")
		$inJSON_t:="{\"OBJ\":"+$inJSON_t+"}"
	End if

	$currentErrMethod_t:=Method called on error
	ON ERR CALL("OTr_zErrIgnore")
	$parsed_o:=JSON Parse($inJSON_t; Is object)
	ON ERR CALL($currentErrMethod_t)

	If ($parsed_o#Null)

		OTr_zLock

		$slot_i:=Find in array(<>OTR_InUse_ab; False)
		If ($slot_i=-1)
			$slot_i:=Size of array(<>OTR_InUse_ab)+1
			INSERT IN ARRAY(<>OTR_InUse_ab; $slot_i)
			INSERT IN ARRAY(<>OTR_Objects_ao; $slot_i)
		End if

		<>OTR_Objects_ao{$slot_i}:=OB Copy($parsed_o)
		<>OTR_InUse_ab{$slot_i}:=True

		OTr_zUnlock

		$handle_i:=$slot_i

	End if

End if

OTr_zRemoveFromCallStack(Current method name)
