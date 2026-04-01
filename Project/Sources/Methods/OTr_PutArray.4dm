//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArray ($handle_i : Integer; $tag_t : Text; $array_ptr : Pointer)

// Stores a 4D array into an OTr object at the given
// tag path. The array is serialised as a 4D Object
// with metadata properties (arrayType, numElements,
// currentItem) and one string-keyed property per
// element ("0" through "n"). Date and Time elements
// are stored as ISO text via OTr_uDateToText and
// OTr_uTimeToText.

// Access: Shared

// Parameters:
//   $handle_i  : Integer : OTr handle
//   $tag_t     : Text    : Tag path for the array
//   $array_ptr : Pointer : Pointer to a 4D array

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
#DECLARE($handle_i : Integer; $tag_t : Text; $array_ptr : Pointer)

var $anObj_o; $parent_o; $arrayObject_o : Object
var $leafKey_t : Text
var $type_i; $index_i; $count_i; $currentItem_i : Integer

OTr__Lock

If (OTr__IsValidHandle($handle_i))
	$anObj_o:=<>OTR_Objects_ao{$handle_i}  // Make the code easier to read
	
	If (OTr__ResolvePath($anObj_o; $tag_t; True:C214; ->$parent_o; ->$leafKey_t))
		$type_i:=Type:C295($array_ptr->)
		$count_i:=Size of array:C274($array_ptr->)
		$currentItem_i:=$array_ptr->
		$arrayObject_o:=New object:C1471("arrayType"; $type_i; "numElements"; $count_i; "currentItem"; $currentItem_i)
		
		For ($index_i; 0; $count_i)
			
			Case of 
					// This first group is easy, just assign the value
				: ($type_i=Text array:K8:16) | ($type_i=String array:K8:15)\
					 | (($type_i=LongInt array:K8:19) | ($type_i=Integer array:K8:18))\
					 | ($type_i=Real array:K8:17) | ($type_i=Boolean array:K8:21)
					$arrayObject_o[String:C10($index_i)]:=$array_ptr->{$index_i}
					
				: ($type_i=Date array:K8:20)
					$arrayObject_o[String:C10($index_i)]:=OTr_uDateToText($array_ptr->{$index_i})
					
				: ($type_i=Time array:K8:29)
					$arrayObject_o[String:C10($index_i)]:=OTr_uTimeToText($array_ptr->{$index_i})
					
				: ($type_i=Pointer array:K8:23)
					$arrayObject_o[String:C10($index_i)]:=OTr_uPointerToText($array_ptr->{$index_i})
					
				: ($type_i=Blob array:K8:30)
					$arrayObject_o[String:C10($index_i)]:=OTr_uBlobToText($array_ptr->{$index_i})
					
				: ($type_i=Picture array:K8:22)
					$arrayObject_o[String:C10($index_i)]:=OTr_uPictureToText($array_ptr->{$index_i})
					
					// Others to be implemented
					
			End case 
			
			
			
		End for 
		
		OB SET:C1220($parent_o; $leafKey_t; $arrayObject_o)
		
	End if 
	
Else 
	OTr__Error("Invalid handle"; Current method name:C684)
End if 

OTr__Unlock



