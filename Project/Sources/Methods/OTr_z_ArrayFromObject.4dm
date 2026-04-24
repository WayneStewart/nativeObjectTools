//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_ArrayFromObject ($arrayObj_o : Object; $arrayPtr : Pointer)

// Populates a 4D array from an OTr array object.
// The target array must already be declared with the
// correct type. Elements are filled using the stored
// arrayType and string-indexed keys "0" through
// "numElements". Type conversions are applied via the
// OTr_u_ utility methods for Date, Time, Pointer,
// BLOB, and Picture types.
//
// Called internally by OT GetArray and typed element
// Get methods. Callers are responsible for locking.

// Access: Private

// Parameters:
//   $arrayObj_o : Object  : OTr array object
//   $arrayPtr   : Pointer : Pointer to target 4D array

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($arrayObj_o : Object; $arrayPtr : Pointer)

var $type_i; $count_i; $existing_i; $index_i : Integer

$type_i:=$arrayObj_o.arrayType
$count_i:=$arrayObj_o.numElements

// Resize the target array to match stored count
$existing_i:=Size of array:C274($arrayPtr->)
If ($existing_i>0)
	DELETE FROM ARRAY:C228($arrayPtr->; 1; $existing_i)
End if 
If ($count_i>0)
	INSERT IN ARRAY:C227($arrayPtr->; 1; $count_i)
End if 

// Fill elements 0 through numElements
For ($index_i; 0; $count_i)
	Case of 
		: ($type_i=Text array:K8:16) | ($type_i=String array:K8:15) | ($type_i=Boolean array:K8:21)
			$arrayPtr->{$index_i}:=$arrayObj_o[String:C10($index_i)]
			
		: ($type_i=LongInt array:K8:19) | ($type_i=Integer array:K8:18) | ($type_i=Real array:K8:17)
			$arrayPtr->{$index_i}:=Num:C11($arrayObj_o[String:C10($index_i)])  // Convert to a number, just in case it got confused
			
		: ($type_i=Date array:K8:20)
			$arrayPtr->{$index_i}:=OTr_u_TextToDate($arrayObj_o[String:C10($index_i)])
			
		: ($type_i=Time array:K8:29)
			$arrayPtr->{$index_i}:=OTr_u_TextToTime($arrayObj_o[String:C10($index_i)])
			
		: ($type_i=Pointer array:K8:23)
			$arrayPtr->{$index_i}:=OTr_u_TextToPointer($arrayObj_o[String:C10($index_i)])
			
		: ($type_i=Picture array:K8:22)
			$arrayPtr->{$index_i}:=$arrayObj_o[String:C10($index_i)]
			
		: ($type_i=Array 2D:K8:24)
			// Retired: was OTr_u_TextToPicture — picture arrays now stored natively
			
	End case 
End for 
