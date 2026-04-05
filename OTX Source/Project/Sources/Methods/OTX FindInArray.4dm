//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTX FindInArray

// Method Type:    Protected

C_LONGINT:C283($inObject_i; $1)
C_TEXT:C284($inTag_t; $2)
C_TEXT:C284($inValue_t; $3)
C_LONGINT:C283($inStart_i; $4)
C_LONGINT:C283($ElementPosition_i; $0)

// Local Variables:
C_LONGINT:C283($ItemPosition_i; $ItemType_i; $MethodItemType_i; $ArrayType_i)
C_POINTER:C301($Object_ptr; $SearchForThis_ptr)
C_POINTER:C301($ListOfItemNames_ptr; $ListOfItemVariables_ptr; $ListOfItemTypes_ptr; $ItemVariable_ptr)

C_BOOLEAN:C305($inValue_b)
C_LONGINT:C283($inValue_i)
C_REAL:C285($inValue_r)

// Created by Wayne Stewart (Sep 12, 2007)
//     waynestewart@mac.com

// Discussion 
//   OT FindInArray searches an array in inObject for the value inValue. 
//   If inObject is not a valid object handle, if no item in the object has the given tag, 
//   or if the item’s type is not an array type, an error is generated, OK is set to zero, 
//   and -1 is returned. 
//   If inStart is not specified or is zero, it defaults to 1. The text inValue is converted 
//   to the type appropriate for the array being searched. For example, for a Longint 
//   array or Real array, inValue is converted as if it where passed to the 4D Num 
//   command. The formats used to convert values are as follows: 
//   The result of the command is the index of the first matching element, or -1 if 
//   no match is found. 

//   OT FindInArray(inObject; inTag; inValue {; inStart}) -> Longint 
//   Parameter       Type            Description 
//   inObject        Longint         A handle to an object 
//   inTag           String          Tag of the array item to change 
//   inValue         Text            Value to search for 
//   inStart         Number          Element at which to start search 
//   Function result Number          The index of the first element found 

//   Array type              Example inValue 
//   Boolean array           "true" or "1" = true, "false" or "0" = false 
//   Date array              String(!08/27/31!) 
//   Longint array           String(7) 
//   Real array              String(13.27) 
//   Note Wildcards may be used when searching string/text arrays just as in 4D.

// ----------------------------------------------------

OTX Init  //  Check the component is initialised

$inObject_i:=$1
$inTag_t:=$2
$inValue_t:=$3
$ElementPosition_i:=-1  //  Initialise to can't find

Case of 
	: (Count parameters:C259=3)
		$inStart_i:=1
	Else 
		$inStart_i:=$4
End case 

$Object_ptr:=OTX Get Object Pointer($inObject_i)  //  Find the object pointer, OK is set to 1 if the object exists

If (OK=1)  //                         Only work if valid pointer is found, set some pointers to the array elements
	$ListOfItemNames_ptr:=$Object_ptr->{<>OTX_ItemNames_i}  //               This is the item tag
	$ListOfItemVariables_ptr:=$Object_ptr->{<>OTX_ItemVariables_i}  //       This is the item variable ptr
	$ListOfItemTypes_ptr:=$Object_ptr->{<>OTX_ItemTypes_i}  //               This is the item type
	$ItemPosition_i:=OTX Get Item Position($Object_ptr; $inTag_t)  //       Get the item position within the object
	If ($ItemPosition_i=-1)  //                                              If the item does not exist, create it
		OK:=0  //                                                             Set OK to 0
	Else 
		$ItemType_i:=$ListOfItemTypes_ptr->{$ItemPosition_i}  //              Get the item type
		If (rVar_IsAnArray($ItemType_i))  //                                if it is the correct type
			$ItemVariable_ptr:=$ListOfItemVariables_ptr->{$ItemPosition_i}  // Get the pointer to the array
			$ArrayType_i:=Type:C295($ItemVariable_ptr->)
			Case of 
				: ($ArrayType_i=Boolean array:K8:21)
					Case of 
						: ($inValue_t="1") | ($inValue_t="True")
							$inValue_b:=True:C214
						: ($inValue_t="0") | ($inValue_t="False")
							$inValue_b:=False:C215
						Else 
							$inValue_b:=False:C215
					End case 
					$SearchForThis_ptr:=->$inValue_b
					
				: ($ArrayType_i=LongInt array:K8:19) | ($ArrayType_i=Integer array:K8:18)
					$inValue_i:=Num:C11($inValue_t)
					$SearchForThis_ptr:=->$inValue_i
					
				: ($ArrayType_i=Real array:K8:17)
					$inValue_r:=Num:C11($inValue_t)
					$SearchForThis_ptr:=->$inValue_r
					
				Else 
					$SearchForThis_ptr:=->$inValue_t
					
			End case 
			$ElementPosition_i:=Find in array:C230($ItemVariable_ptr->; $SearchForThis_ptr->; $inStart_i)
			
		Else 
			OK:=0  //                                                         otherwise set OK to 0
		End if 
	End if 
End if 



$0:=$ElementPosition_i
