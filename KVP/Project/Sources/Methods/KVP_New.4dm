//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: KVP_New


// Method Type:    Shared

// Parameters:
C_TEXT:C284($1; $0)

// Local Variables:
C_LONGINT:C283($MyDictionary_i)

// Created by Wayne Stewart (Jun 14, 2012)
//     waynestewart@mac.com

//   

// ----------------------------------------------------

Dict_Init

$MyDictionary_i:=Dict_New($1)


$0:=Dict_Name($MyDictionary_i)