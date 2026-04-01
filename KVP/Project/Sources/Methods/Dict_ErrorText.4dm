//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_ErrorText


// Method Type:    Shared

// Parameters:
C_LONGINT:C283($1)
C_TEXT:C284($0)

// Local Variables:
C_TEXT:C284($Dict_ErrorDetails_t)

// Created by Wayne Stewart (Jul 24, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------



Case of 
	: ($1=-17000)
		$0:="Unclassified KVP Dictionary Error"
		
	: ($1=-17001)
		$0:="Non unique dictionary name"
		
		
	Else 
		$0:="Unclassified KVP Dictionary Error"
		
End case 

$Dict_ErrorDetails_t:=Dict_ErrorDetails  //  This will clear the variable!

If (Length:C16($Dict_ErrorDetails_t)>0)
	$0:=$0+(Char:C90(Carriage return:K15:38)*2)+$Dict_ErrorDetails_t
End if 