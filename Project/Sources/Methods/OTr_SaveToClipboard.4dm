//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToClipboard \
//   ($handle_i : Integer {; $prettyPrint_b : Boolean})

// Places the stored object as a JSON string on the system
// clipboard. Useful for quick inspection in a text editor.

// Access: Shared

// Parameters:
//   $handle_i      : Integer : OTr handle
//   $prettyPrint_b : Boolean : True for indented output; \
//                              default True (optional)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $prettyPrint_b : Boolean)

var $snapshot_o : Object
var $json_t : Text
var $valid_b : Boolean

If (Count parameters < 2)
	$prettyPrint_b:=True
End if

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

	SET TEXT TO PASTEBOARD($json_t)
End if
