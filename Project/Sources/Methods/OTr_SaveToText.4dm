//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToText (inObject {; inPrettyPrint}) --> Text

// Returns the stored object as a JSON string. Useful for
// inspection and testing.

// Access: Shared

// Parameters:
//   $inObject_i      : Integer : OTr inObject
//   $inPrettyPrint_b : Boolean : True for indented output; default False (optional)

// Returns:
//   $json_t : Text : JSON representation of the object, \
//                    or empty text if the handle is invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inPrettyPrint_b : Boolean)->$json_t : Text

OTr_z_AddToCallStack(Current method name:C684)

var $snapshot_o : Object
var $valid_b : Boolean
var $prettyPrint_b : Boolean

If (Count parameters:C259<2)
	$prettyPrint_b:=False:C215
Else 
	$prettyPrint_b:=$inPrettyPrint_b
End if 

$json_t:=""
$valid_b:=False:C215

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	$snapshot_o:=OB Copy:C1225(<>OTR_Objects_ao{$inObject_i})
	$valid_b:=True:C214
End if 

OTr_z_Unlock

If ($valid_b)
	If ($prettyPrint_b)
		$json_t:=JSON Stringify:C1217($snapshot_o; *)
	Else 
		$json_t:=JSON Stringify:C1217($snapshot_o)
	End if 
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
