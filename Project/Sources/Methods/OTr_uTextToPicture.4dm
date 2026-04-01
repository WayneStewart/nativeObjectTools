//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uTextToPicture ($picRef_t : Text) --> Picture

// Retrieves a Picture from the OTr parallel picture
// array using a reference string in "pic:N" format.
// Returns an empty Picture if the reference is
// invalid or the slot is not in use.

// Access: Private

// Parameters:
//   $picRef_t : Text : Reference string "pic:N"

// Returns:
//   $thePicture_g : Picture : The stored Picture, or empty

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($picRef_t : Text)->$thePicture_pic : Picture

var $slot_i : Integer

If (Substring:C12($picRef_t; 1; 4)="pic:")
	$slot_i:=Num:C11(Substring:C12($picRef_t; 5))
	If (($slot_i>0) & ($slot_i<=Size of array:C274(<>OTR_Pictures_apic)))
		If (<>OTR_PicInUse_ab{$slot_i})
			$thePicture_pic:=<>OTR_Pictures_apic{$slot_i}
		End if 
	End if 
Else 
	// $thePicture_pic will be returned as an empty picture
End if 
