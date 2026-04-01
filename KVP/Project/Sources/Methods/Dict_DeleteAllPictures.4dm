//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_DeleteAllPictures

// Method Type:    Private

// Parameters:
C_LONGINT:C283($Dictionary_i; $1)

// Local Variables:
C_PICTURE:C286($Blank_pic)
C_LONGINT:C283($Position_i; $SizeOfPictureArray_i; $PictureIndex_i)
C_TEXT:C284($PictureIndex_t)

// Created by Wayne Stewart (Jun 28, 2012)
//     waynestewart@mac.com
//   
// ----------------------------------------------------

$Dictionary_i:=$1

$Position_i:=Find in array:C230(<>Dict_Values_at{$Dictionary_i}; "Picture at: @")


While ($Position_i>0)
	$PictureIndex_t:=<>Dict_Values_at{$Dictionary_i}{$Position_i}
	
	$PictureIndex_i:=Num:C11(Substring:C12($PictureIndex_t; 13))
	$SizeOfPictureArray_i:=Size of array:C274(<>Dict_PictValues_apic)
	
	Case of 
		: ($PictureIndex_i=$SizeOfPictureArray_i)  //  Last picture? Just delete the elements
			$SizeOfPictureArray_i:=$SizeOfPictureArray_i-1
			ARRAY PICTURE:C279(<>Dict_PictValues_apic; $SizeOfPictureArray_i)
			ARRAY TEXT:C222(<>Dict_PictIndexSlots_at; $SizeOfPictureArray_i)
			
		: ($PictureIndex_i<$SizeOfPictureArray_i)  //  In this case, just blank off the entries
			<>Dict_PictValues_apic{$PictureIndex_i}:=$Blank_pic
			<>Dict_PictIndexSlots_at{$PictureIndex_i}:=""
			
		Else 
			Dict_BugAlert(Current method name:C684; "Tried to remove a picture from a dictionary that did not exist.")
			
	End case 
	
	<>Dict_Values_at{$Dictionary_i}{$Position_i}:=""  //  so we won't find it again
	$Position_i:=Find in array:C230(<>Dict_Values_at{$Dictionary_i}; "Picture at: @")
End while 
