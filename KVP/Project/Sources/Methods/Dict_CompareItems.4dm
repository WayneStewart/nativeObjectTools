//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_CompareItems

// Method Type:    Shared

// Parameters:
C_LONGINT:C283($DictionaryOneID_i; $1)
C_TEXT:C284($DictionaryOneKey_t; $2)
C_LONGINT:C283($DictionaryTwoID_i; $3)
C_TEXT:C284($DictionaryTwoKey_t; $4)

C_LONGINT:C283($Result_i; $0)

// Local Variables:
C_LONGINT:C283($PictureIndexOne_i; $PictureIndexTwo_i; $DataTypeOne_i; $DataTypetwo_i)
C_TEXT:C284($ValueOne_t; $ValueTwo_t)
C_PICTURE:C286($Mask_pic)

// Created by Wayne Stewart (Jul 29, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------

$DictionaryOneID_i:=$1
$DictionaryOneKey_t:=$2
$DictionaryTwoID_i:=$3
$DictionaryTwoKey_t:=$4

$Result_i:=-1  //  Assume an error occurred

$ValueOne_t:=Dict_GetValue($DictionaryOneID_i; $DictionaryOneKey_t)
$ValueTwo_t:=Dict_GetValue($DictionaryTwoID_i; $DictionaryTwoKey_t)

$DataTypeOne_i:=Dict_DataType($DictionaryOneID_i; $DictionaryOneKey_t)
$DataTypeTwo_i:=Dict_DataType($DictionaryTwoID_i; $DictionaryTwoKey_t)


Case of 
	: ($DataTypeOne_i#$DataTypeTwo_i)
		//  No point in doing anymore, even though they may contain identical values as text.
		
	: ($DataTypeOne_i=Is picture:K8:10) & ($DataTypeTwo_i=Is picture:K8:10)
		$PictureIndexOne_i:=Num:C11(Substring:C12($ValueOne_t; 13))
		$PictureIndexTwo_i:=Num:C11(Substring:C12($ValueTwo_t; 13))
		
		If (Picture size:C356(<>Dict_PictValues_apic{$PictureIndexOne_i})=Picture size:C356(<>Dict_PictValues_apic{$PictureIndexTwo_i}))
			$Result_i:=Num:C11(Equal pictures:C1196(<>Dict_PictValues_apic{$PictureIndexOne_i}; <>Dict_PictValues_apic{$PictureIndexOne_i}; $Mask_pic))
		Else 
			$Result_i:=0
		End if 
		
	: ($DataTypeOne_i=Is BLOB:K8:12) & ($DataTypeTwo_i=Is BLOB:K8:12)
		$PictureIndexOne_i:=Num:C11(Substring:C12($ValueOne_t; 10))
		$PictureIndexTwo_i:=Num:C11(Substring:C12($ValueTwo_t; 10))
		
		If (Picture size:C356(<>Dict_PictValues_apic{$PictureIndexOne_i})=Picture size:C356(<>Dict_PictValues_apic{$PictureIndexTwo_i}))
			$Result_i:=Num:C11(Equal pictures:C1196(<>Dict_PictValues_apic{$PictureIndexOne_i}; <>Dict_PictValues_apic{$PictureIndexOne_i}; $Mask_pic))
		Else 
			$Result_i:=0
		End if 
		
		
	Else 
		$Result_i:=Position:C15($ValueOne_t; $ValueTwo_t; *)
		
		
End case 

$0:=$Result_i


