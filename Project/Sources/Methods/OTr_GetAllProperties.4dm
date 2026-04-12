//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetAllProperties (inObject; outNames {; outTypes {; outItemSizes {; outDataSizes}}})

// Returns information about all top-level items in $inObject_i. Delegates
// to OTr_GetAllNamedProperties with an empty tag. Item names are
// returned in indeterminate order.

// **ORIGINAL DOCUMENTATION**

// *OT IsEmbedded* tests the item referenced by *inTag* to see if it is an embedded
// object.

// If *inObject* is not a valid object handle or if no item in object has the given tag,
// an error is generated, *OK* is set to zero, and zero is returned.

// If an item with the given tag exists and has the type *OT Is Object*, 1 is returned.
// If an item with the given tag exists and has any other type, zero is returned.



// Access: Shared

// Parameters:
//   $inObject_i         : Integer : OTr inObject
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
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $outNames_ptr : Pointer; \
$outTypes_ptr : Pointer; $outItemSizes_ptr : Pointer; \
$outDataSizes_ptr : Pointer)

OTr_zAddToCallStack(Current method name:C684)

// Delegate to OTr_GetAllNamedProperties with an empty tag,
// forwarding only the pointer params that were actually supplied.

Case of 
		
	: (Count parameters:C259<=2)
		OTr_GetAllNamedProperties($inObject_i; ""; $outNames_ptr)
		
	: (Count parameters:C259=3)
		OTr_GetAllNamedProperties(\
			$inObject_i; ""; $outNames_ptr; $outTypes_ptr)
		
	: (Count parameters:C259=4)
		OTr_GetAllNamedProperties(\
			$inObject_i; ""; $outNames_ptr; $outTypes_ptr; $outItemSizes_ptr)
		
	Else 
		OTr_GetAllNamedProperties(\
			$inObject_i; ""; $outNames_ptr; $outTypes_ptr; \
			$outItemSizes_ptr; $outDataSizes_ptr)
		
End case 

OTr_zRemoveFromCallStack(Current method name:C684)
