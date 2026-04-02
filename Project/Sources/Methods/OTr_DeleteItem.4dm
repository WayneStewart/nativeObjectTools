//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_DeleteItem ($handle_i : Integer; $tag_t : Text)

// Deletes the item referenced by $tag_t. Embedded objects are deleted
// recursively. BLOB and Picture parallel array slots referenced by
// the deleted item (or any sub-items) are released.

// Access: Shared

// Parameters:
//   $handle_i : Integer : A handle to an object
//   $tag_t    : Text    : Tag of the item to delete

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text)

var $parent_o : Object
var $leafKey_t : Text
var $nativeType_i : Integer
var $textVal_t : Text
var $embedded_o : Object

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	
	If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			
			$nativeType_i:=OB Get type:C1230($parent_o; $leafKey_t)
			
			Case of 
					
				: ($nativeType_i=Is text:K8:3)
					$textVal_t:=OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3)
					OTr_zReleaseBinaryRef($textVal_t)
					
				: ($nativeType_i=Is object:K8:27)
					$embedded_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
					OTr_zReleaseObjBinaries($embedded_o)
					
			End case 
			
			OB REMOVE:C1226($parent_o; $leafKey_t)
			
		Else 
			OTr_zError("Item not found: "+$tag_t; Current method name:C684)
		End if 
		
	Else 
		OTr_zError("Invalid path: "+$tag_t; Current method name:C684)
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

OTr_zUnlock
