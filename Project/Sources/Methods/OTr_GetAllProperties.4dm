//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetAllProperties ($handle_i : Integer; \
//   $outNames_ptr : Pointer \
//   {; $outTypes_ptr : Pointer \
//   {; $outItemSizes_ptr : Pointer \
//   {; $outDataSizes_ptr : Pointer}}})

// Returns information about all top-level items in $handle_i. Delegates
// to OTr_GetAllNamedProperties with an empty tag. Item names are
// returned in indeterminate order.

// Access: Shared

// Parameters:
//   $handle_i         : Integer : A handle to an object
//   $outNames_ptr     : Pointer : Receives item names (Text array)
//   $outTypes_ptr     : Pointer : Receives OT type constants
//                                 (Longint array) (optional)
//   $outItemSizes_ptr : Pointer : Receives item sizes (Longint array)
//                                 (optional)
//   $outDataSizes_ptr : Pointer : Receives data sizes (Longint array)
//                                 (optional)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $outNames_ptr : Pointer; \
	$outTypes_ptr : Pointer; $outItemSizes_ptr : Pointer; \
	$outDataSizes_ptr : Pointer)

// Delegate to OTr_GetAllNamedProperties with an empty tag,
// forwarding only the pointer params that were actually supplied.

Case of

	: (Count parameters<=2)
		OTr_GetAllNamedProperties($handle_i; ""; $outNames_ptr)

	: (Count parameters=3)
		OTr_GetAllNamedProperties( \
			$handle_i; ""; $outNames_ptr; $outTypes_ptr)

	: (Count parameters=4)
		OTr_GetAllNamedProperties( \
			$handle_i; ""; $outNames_ptr; $outTypes_ptr; $outItemSizes_ptr)

	Else
		OTr_GetAllNamedProperties( \
			$handle_i; ""; $outNames_ptr; $outTypes_ptr; \
			$outItemSizes_ptr; $outDataSizes_ptr)

End case
