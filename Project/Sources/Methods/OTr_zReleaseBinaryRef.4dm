//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_zReleaseBinaryRef ($ref_t : Text)

// Releases a BLOB or Picture parallel array slot
// referenced by a stored text value. If $ref_t begins
// with "blob:" the corresponding slot in
// <>OTR_Blobs_ablob is cleared and marked free. If it
// begins with "pic:" the corresponding slot in
// <>OTR_Pictures_apic is marked free. Any other value
// is silently ignored.
//
// Must be called within a held registry lock.

// Access: Private

// Parameters:
//   $ref_t : Text : Stored element value to inspect

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($ref_t : Text)

var $idx_i : Integer

If (Substring:C12($ref_t; 1; 5)="blob:")
	$idx_i:=Num:C11(Substring:C12($ref_t; 6))
	If (($idx_i>0) \
		& ($idx_i<=Size of array:C274(<>OTR_Blobs_ablob)) \
		& (<>OTR_BlobInUse_ab{$idx_i}))
		CLEAR VARIABLE:C89(<>OTR_Blobs_ablob{$idx_i})
		<>OTR_BlobInUse_ab{$idx_i}:=False:C215
	End if

Else
	If (Substring:C12($ref_t; 1; 4)="pic:")
		$idx_i:=Num:C11(Substring:C12($ref_t; 5))
		If (($idx_i>0) \
			& ($idx_i<=Size of array:C274(<>OTR_Pictures_apic)) \
			& (<>OTR_PicInUse_ab{$idx_i}))
			<>OTR_PicInUse_ab{$idx_i}:=False:C215
		End if
	End if

End if
