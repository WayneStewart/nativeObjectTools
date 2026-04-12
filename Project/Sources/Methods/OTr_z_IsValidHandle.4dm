//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_IsValidHandle ($handle_i : Integer) --> \
//   $isValid_b : Boolean

// Validates that a handle index is in range and currently allocated.

// Access: Private

// Parameters:
//   $handle_i : Integer : OTr handle to validate

// Returns:
//   $isValid_b : Boolean : True when the handle is currently in use

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-05 - Sets OK to 0 on invalid handle so callers
//   inherit correct error-state OK without individual edits.
// ----------------------------------------------------

#DECLARE($handle_i : Integer)->$isValid_b : Boolean


$isValid_b:=False:C215

Case of 
	: ($handle_i<=0)
		OTr_z_SetOK(0)
		
	: ($handle_i>Size of array:C274(<>OTR_InUse_ab))
		OTr_z_SetOK(0)
		
	Else 
		$isValid_b:=<>OTR_InUse_ab{$handle_i}
		If (Not:C34($isValid_b))
			OTr_z_SetOK(0)
		End if 
		
End case 

