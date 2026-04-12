//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutArray (inObject; inTag; inArray)

// Stores a 4D array into an OTr object at the given
// tag path. The array is serialised as a 4D Object
// with metadata properties (arrayType, numElements,
// currentItem) and one string-keyed property per
// element ("0" through "n"). Date and Time elements
// are stored as ISO text via OTr_uDateToText and
// OTr_uTimeToText.

// **ORIGINAL DOCUMENTATION**

// *OT PutArray* puts *inArray* into *inObject*. The element count and current element
// are stored with the array elements and are restored by OT *GetArray*. You may not
// store two- dimensional arrays in objects.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to
// zero. If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has a compatible type (see below), its value
// is replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

// Array Type Compatibility

// Except for * *String and Text *array* s, you must put and get *array* s into the same
// type of *array* variable. String and Text *array* s, however, may be mixed and
// matched, because ObjectTools stores both types of *array* with an item type of *OT
// Character array* (113).

// Access: Shared

// Parameters:
//   $inObject_i  : Integer : OTr inObject
//   $inTag_t     : Text    : Tag path for the array (inTag)
//   $inArray_ptr : Pointer : Pointer to the source 4D array (inArray)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------
#DECLARE($inObject_i : Integer; $inTag_t : Text; $inArray_ptr : Pointer)

OTr_zAddToCallStack(Current method name)

var $anObj_o; $parent_o; $arrayObject_o : Object
var $leafKey_t : Text
var $type_i; $index_i; $count_i; $currentItem_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	$anObj_o:=<>OTR_Objects_ao{$inObject_i}  // Make the code easier to read
	
	If (OTr_zResolvePath($anObj_o; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
		$type_i:=Type:C295($inArray_ptr->)
		$count_i:=Size of array:C274($inArray_ptr->)
		$currentItem_i:=$inArray_ptr->
		$arrayObject_o:=New object:C1471("arrayType"; $type_i; "numElements"; $count_i; "currentItem"; $currentItem_i)
		
		For ($index_i; 0; $count_i)
			
			Case of 
					// This first group is easy, just assign the value
				: ($type_i=Text array:K8:16) | ($type_i=String array:K8:15)\
					 | (($type_i=LongInt array:K8:19) | ($type_i=Integer array:K8:18))\
					 | ($type_i=Real array:K8:17) | ($type_i=Boolean array:K8:21)
					$arrayObject_o[String:C10($index_i)]:=$inArray_ptr->{$index_i}
					
				: ($type_i=Date array:K8:20)
					$arrayObject_o[String:C10($index_i)]:=OTr_uDateToText($inArray_ptr->{$index_i})
					
				: ($type_i=Time array:K8:29)
					$arrayObject_o[String:C10($index_i)]:=OTr_uTimeToText($inArray_ptr->{$index_i})
					
				: ($type_i=Pointer array:K8:23)
					$arrayObject_o[String:C10($index_i)]:=OTr_uPointerToText($inArray_ptr->{$index_i})
					
				: ($type_i=Blob array:K8:30)
					$arrayObject_o[String:C10($index_i)]:=OTr_uBlobToText($inArray_ptr->{$index_i})
					
				: ($type_i=Picture array:K8:22)
					$arrayObject_o[String:C10($index_i)]:=$inArray_ptr->{$index_i}
					
					// Others to be implemented
					
			End case 
			
			
			
		End for 
		
		OB SET:C1220($parent_o; $leafKey_t; $arrayObject_o)
		
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
