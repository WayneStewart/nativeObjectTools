//%attributes = {"invisible":true}

// ----------------------------------------------------
// Project Method: OTr_u_EqualPictures ($picture_01_pic : Picture; \
//   $picture_02_pic : Picture) --> $isEqual_b : Boolean

// Compares two Picture values for equality.
// Empty pictures are considered equal. Different sizes are not equal.
// For equal non-zero sizes, Equal pictures is used.

// Access: Private

// Parameters:
//   $picture_01_pic : Picture : First picture to compare
//   $picture_02_pic : Picture : Second picture to compare

// Returns:
//   $isEqual_b : Boolean : True if pictures are equal, otherwise False

// Created by Wayne Stewart, 2026-04-01

// ----------------------------------------------------


#DECLARE($picture_01_pic : Picture; $picture_02_pic : Picture)->$isEqual_b : Boolean

var $mask_pic : Picture
var $sizeOfPictureOne_i; $sizeOfPictureTwo_i : Integer

$isEqual_b:=False:C215

$sizeOfPictureOne_i:=Picture size:C356($picture_01_pic)
$sizeOfPictureTwo_i:=Picture size:C356($picture_02_pic)

Case of 
	: ($sizeOfPictureOne_i=0) & ($sizeOfPictureTwo_i=0)  // Both empty pictures
		$isEqual_b:=True:C214
		
	: ($sizeOfPictureOne_i#$sizeOfPictureTwo_i)  // Different size pictures
		
	Else 
		// Save the most time consuming test until last
		$isEqual_b:=Equal pictures:C1196($picture_01_pic; $picture_02_pic; $mask_pic)
End case 

