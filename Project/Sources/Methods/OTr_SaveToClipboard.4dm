//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToClipboard (inObject {; inPrettyPrint})

// Places the stored object as a JSON string on the system
// clipboard. Useful for quick inspection in a text editor.

// Access: Shared

// Parameters:
//   $inObject_i      : Integer : OTr inObject
//   $inPrettyPrint_b : Boolean : True for indented output; default True (optional)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inPrettyPrint_b : Boolean)

OTr_zAddToCallStack(Current method name)

var $snapshot_o : Object
var $json_t : Text
var $valid_b : Boolean

If (Count parameters < 2)
	$inPrettyPrint_b:=True
End if

$valid_b:=False

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	$snapshot_o:=OB Copy(<>OTR_Objects_ao{$inObject_i})
	$valid_b:=True
End if

OTr_zUnlock

If ($valid_b)
	If ($inPrettyPrint_b)
		$json_t:=JSON Stringify($snapshot_o; *)
	Else
		$json_t:=JSON Stringify($snapshot_o)
	End if

	SET TEXT TO PASTEBOARD($json_t)
End if

OTr_zRemoveFromCallStack(Current method name)
