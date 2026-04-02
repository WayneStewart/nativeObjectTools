//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zIsValidHandle ($handle_i : Integer) --> \
//   $isValid_b : Boolean

// Validates that a handle index is in range and currently allocated.

// Access: Private

// Parameters:
//   $handle_i : Integer : OTr handle to validate

// Returns:
//   $isValid_b : Boolean : True when the handle is currently in use

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer)->$isValid_b : Boolean


$isValid_b:=False:C215

Case of 
	: ($handle_i<=0)
		
	: ($handle_i>Size of array:C274(<>OTR_InUse_ab))
		
	Else 
		$isValid_b:=<>OTR_InUse_ab{$handle_i}
		
		
End case 

