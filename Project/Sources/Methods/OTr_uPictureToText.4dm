//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uPictureToText ($thePicture_g : Picture) --> Text

// Stores a Picture in the OTr parallel picture array
// and returns a reference string "pic:N" for storage
// in an OTr object. Reuses released slots in
// <>OTR_Pictures_apic before appending a new one.

// Access: Private

// Parameters:
//   $thePicture_g : Picture : The Picture to store

// Returns:
//   $picRef_t : Text : Reference string "pic:N"

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($thePicture_g : Picture)->$picRef_t : Text

var $slot_i : Integer

$slot_i:=Find in array:C230(<>OTR_PicInUse_ab; False:C215)
If ($slot_i=-1)
	$slot_i:=Size of array:C274(<>OTR_Pictures_apic)+1
	INSERT IN ARRAY:C227(<>OTR_Pictures_apic; $slot_i; 1)
	INSERT IN ARRAY:C227(<>OTR_PicInUse_ab; $slot_i; 1)
End if

<>OTR_Pictures_apic{$slot_i}:=$thePicture_g
<>OTR_PicInUse_ab{$slot_i}:=True:C214

$picRef_t:="pic:"+String:C10($slot_i)
