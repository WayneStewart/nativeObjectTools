//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToText \
//   ($handle_i : Integer {; $prettyPrint_b : Boolean}) --> $json_t : Text

// Returns the stored object as a JSON string. Useful for
// inspection and testing.

// Access: Shared

// Parameters:
//   $handle_i      : Integer : OTr handle
//   $prettyPrint_b : Boolean : True for indented output; \
//                              default False (optional)

// Returns:
//   $json_t : Text : JSON representation of the object, \
//                    or empty text if the handle is invalid

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $prettyPrint_b : Boolean)->$json_t : Text

var $snapshot_o : Object
var $valid_b : Boolean

If (Count parameters < 2)
	$prettyPrint_b:=False
End if

$json_t:=""
$valid_b:=False

OTr__Lock

If (OTr__IsValidHandle($handle_i))
	$snapshot_o:=OB Copy(<>OTR_Objects_ao{$handle_i})
	$valid_b:=True
End if

OTr__Unlock

If ($valid_b)
	If ($prettyPrint_b)
		$json_t:=JSON Stringify($snapshot_o; *)
	Else
		$json_t:=JSON Stringify($snapshot_o)
	End if
End if
