//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_IncludeShadowKey ({inValue}) --> Boolean

// Gets or sets the global flag that controls whether shadow-type
// keys (leafKey$type) are included in XML, JSON, and file exports.
//
// Shadow keys are the sibling properties that record the original
// OT type constant for scalars whose 4D representation is
// ambiguous (Pointer and, on pre-v19 R2, BLOB — both stored as
// plain text). Including them in exports preserves full type
// fidelity on round-trip; excluding them produces cleaner output
// for consumption by non-OTr systems.

// **NOTE:** there is no equivalent Object Tools command

// Default: True (include shadow keys).
//
// Call with no argument to read the current setting.
// Call with True or False to change it and return the previous value.
//
// The flag is stored in Storage.OTr.includeShadowKeys so it is
// visible to all processes and preemptive workers.

// Access: Shared

// Parameters:
//   $inValue_b : Boolean : New setting (optional)

// Returns:
//   $previous_b : Boolean : Setting before this call
//                           (current setting if called with no argument)

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inValue_b : Boolean)->$previous_b : Boolean

OTr_z_Init

$previous_b:=Storage:C1525.OTr.includeShadowKeys

If (Count parameters:C259>=1)
	If ($inValue_b#$previous_b)
		Use (Storage:C1525.OTr)
			Storage:C1525.OTr.includeShadowKeys:=$inValue_b
		End use 
	End if 
End if 
