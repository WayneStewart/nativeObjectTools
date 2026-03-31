//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr__IsValidHandle ($handle_i : Integer) --> \
//   $isValid_b : Boolean

// Validates that a handle index is in range and currently allocated.

// Access: Private

// Parameters:
//   $handle_i : Integer : OTr handle to validate

// Returns:
//   $isValid_b : Boolean : True when the handle is currently in use

// Created by Wayne Stewart, 2026-03-31
// ----------------------------------------------------

#DECLARE($handle_i : Integer)->$isValid_b : Boolean

$isValid_b:=False

If ($handle_i<=0)
	return
End if

If ($handle_i>Size of array(<>OTR_InUse_ab))
	return
End if

$isValid_b:=<>OTR_InUse_ab{$handle_i}
