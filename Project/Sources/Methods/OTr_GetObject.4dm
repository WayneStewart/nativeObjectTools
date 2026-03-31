//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetObject ($handle_i : Integer; $tag_t : Text) \
//   --> $newHandle_i : Integer

// Retrieves an embedded object by tag path, copies it to a new OTr
// handle, and returns that handle.

// Access: Shared

// Parameters:
//   $handle_i : Integer : Source OTr handle
//   $tag_t    : Text    : Tag path to embedded object

// Returns:
//   $newHandle_i : Integer : New handle containing copied object, or 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)->$newHandle_i : Integer

var $parent_o : Object
var $leafKey_t : Text
var $embedded_o : Object

$newHandle_i:=0

OTr__Lock

If (OTr__IsValidHandle($handle_i))
	If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined($parent_o; $leafKey_t))
			$embedded_o:=OB Get($parent_o; $leafKey_t; Is object)
			If ($embedded_o#Null)
				$newHandle_i:=Find in array(<>OTR_InUse_ab; False)
				If ($newHandle_i=-1)
					$newHandle_i:=Size of array(<>OTR_InUse_ab)+1
					INSERT IN ARRAY(<>OTR_InUse_ab; $newHandle_i)
					INSERT IN ARRAY(<>OTR_Objects_ao; $newHandle_i)
				End if

				<>OTR_InUse_ab{$newHandle_i}:=True
				<>OTR_Objects_ao{$newHandle_i}:=OB Copy($embedded_o)
			End if
		End if
	End if
Else
	OTr__Error("Invalid handle"; Current method name)
End if

OTr__Unlock
