//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_zSortValidatePair ($params_o : Object) --> Boolean

// Validates one tag/direction pair for OTr_SortArrays.
// The caller passes an object with the fields:
//   handle  : Integer : OTr handle
//   tag     : Text    : Array tag path
//   dir     : Text    : Direction code

// On success the following are added to $params_o:
//   arrayObj    : Object  : Resolved OTr array object
//   arrayType   : Integer : OTr array type constant
//   numElements : Integer : Stored numElements value

// Validates that the tag references a sortable array
// type (Text, String, LongInt, Integer, Real, Date,
// Time, or Boolean) and a recognised direction code
// (">", "<", or "*"). BLOB, Picture, and Pointer are
// not sortable. Returns False and reports an error for
// any failure; OTr_zResolvePath reports its own errors.

// Access: Private

// Parameters:
//   $params_o : Object : see above

// Returns:
//   Boolean : True if the pair is valid

// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-11 - OB Get now uses Is object type argument
//     to prevent crash when tag holds a scalar rather than an array.
// ----------------------------------------------------

#DECLARE($params_o : Object)->$ok_b : Boolean

var $parent_o : Object
var $arrayObj_o : Object
var $leafKey_t : Text
var $handle_i : Integer
var $tag_t; $dir_t : Text
var $type_i : Integer
var $isSortable_b : Boolean

$ok_b:=False:C215
$handle_i:=$params_o.handle
$tag_t:=$params_o.tag
$dir_t:=$params_o.dir

If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; \
$tag_t; False:C215; ->$parent_o; ->$leafKey_t))
	If (OB Is defined:C1231($parent_o; $leafKey_t))
		$arrayObj_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
		$type_i:=OTr_zArrayType($arrayObj_o)
		
		$isSortable_b:=(($type_i=Text array:K8:16) | ($type_i=String array:K8:15))
		$isSortable_b:=$isSortable_b | (($type_i=LongInt array:K8:19) | ($type_i=Integer array:K8:18))
		$isSortable_b:=$isSortable_b | (($type_i=Real array:K8:17) | ($type_i=Date array:K8:20))
		$isSortable_b:=$isSortable_b | (($type_i=Time array:K8:29) | ($type_i=Boolean array:K8:21))
		
		If ($isSortable_b)
			If (($dir_t=">") | ($dir_t="<") | ($dir_t="*"))
				$params_o.arrayObj:=$arrayObj_o
				$params_o.arrayType:=$type_i
				$params_o.numElements:=$arrayObj_o.numElements
				$ok_b:=True:C214
			Else 
				OTr_zError("Invalid direction code: "+$dir_t; \
					Current method name:C684)
				OTr_zSetOK(0)
			End if 
		Else 
			OTr_zError("Array not sortable: "+$tag_t; \
				Current method name:C684)
			OTr_zSetOK(0)
		End if 
	Else 
		OTr_zError("Tag not found: "+$tag_t; \
			Current method name:C684)
		OTr_zSetOK(0)
	End if 
End if 
