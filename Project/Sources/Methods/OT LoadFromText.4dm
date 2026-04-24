//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT LoadFromText (inJSON) --> Longint

// Parses a JSON string and stores the resulting object in
// a new OTr handle. 

// If the top-level JSON value is an array,
// it is automatically wrapped in an object keyed "OBJ" to
// preserve OTr's object-at-root convention. 

// JSON parse errors are caught silently; check the return value to
// know whether parsing succeeded.

// Returns 0 if inJSON is empty or cannot be parsed.

// **NOTE:** there is no equivalent Object Tools command

// Input must be OTr JSON text, such as text produced by OT SaveToText.
// Legacy ObjectTools text serialisation is not compatible with this
// loader.

// Access: Shared

// Parameters:
//   $inJSON_t : Text : JSON string to parse

// Returns:
//   $handle_i : Integer : New OTr handle, or 0 if parsing failed

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-12 - Added OTr_z_Error on JSON parse failure so that
//     callers can detect the error via OK=0; empty input remains a silent no-op.
// ----------------------------------------------------

#DECLARE($inJSON_t : Text)->$handle_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $parsed_o : Object
var $slot_i : Integer
var $currentErrMethod_t : Text

$handle_i:=0

If ($inJSON_t#"")
	
	// Strip UTF-8 BOM if present (character code 65279)
	If (Character code:C91($inJSON_t[[1]])=65279)
		$inJSON_t:=Substring:C12($inJSON_t; 2)
	End if 
	
	// Wrap top-level arrays so an object is always at the root
	If ($inJSON_t[[1]]="[")
		$inJSON_t:="{\"OBJ\":"+$inJSON_t+"}"
	End if 
	
	$currentErrMethod_t:=Method called on error:C704
	ON ERR CALL:C155("OTr_z_ErrIgnore")
	$parsed_o:=JSON Parse:C1218($inJSON_t; Is object:K8:27)
	ON ERR CALL:C155($currentErrMethod_t)
	
	If ($parsed_o#Null:C1517)
		
		OTr_z_Lock
		
		$slot_i:=Find in array:C230(<>OTR_InUse_ab; False:C215)
		If ($slot_i=-1)
			$slot_i:=Size of array:C274(<>OTR_InUse_ab)+1
			INSERT IN ARRAY:C227(<>OTR_InUse_ab; $slot_i)
			INSERT IN ARRAY:C227(<>OTR_Objects_ao; $slot_i)
		End if 
		
		<>OTR_Objects_ao{$slot_i}:=OB Copy:C1225($parsed_o)
		<>OTR_InUse_ab{$slot_i}:=True:C214
		
		OTr_z_Unlock
		
		$handle_i:=$slot_i
		
	Else 
		OTr_z_Error("JSON parse failed"; Current method name:C684)
	End if 
	
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
