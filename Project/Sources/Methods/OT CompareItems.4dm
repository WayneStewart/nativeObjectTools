//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT CompareItems (inSourceObject; inSourceTag; inCompareObject; inCompareTag) --> Longint

// Compares two items for equality. Both handles may be the same object.
// Returns 1 if identical, 0 if not, -1 on error.

// **ORIGINAL DOCUMENTATION**

// *OT CompareItems* compares two items for equality. *inSourceObject* and
// *inCompareObject* may be the same object.

// If either object handle is not valid, if either item does not exist, or if the two
// items do not have the same type, an error is generated, *OK* is set to zero, and -1
// is returned.

// Otherwise items are compared according to the rules of equality for equivalent
// variable types in 4D. Arrays are considered identical if they are the same size and
// corresponding elements are equal. *BLOB* and *Picture* items are considered identical
// if they contain the same bytes. Embedded objects are considered identical if each of
// their items are identical.

// Access: Shared

// Parameters:
//   $inSourceObject_i  : Integer : OTr inSourceObject
//   $inSourceTag_t     : Text    : Source item tag (inSourceTag)
//   $inCompareObject_i : Integer : OTr inCompareObject
//   $inCompareTag_t    : Text    : Comparison item tag (inCompareTag)

// Returns:
//   $result_i : Integer : 1 if identical, 0 if not, -1 on error

// Wayne Stewart, 2026-04-01 - Uses helper equality methods for text, object,
//   BLOB, and Picture comparisons.
// Wayne Stewart, 2026-04-01 - Reworked boolean comparison for 4D compiler.
// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inSourceObject_i : Integer; $inSourceTag_t : Text; \
$inCompareObject_i : Integer; $inCompareTag_t : Text)->$result_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $srcParent_o : Object
var $srcLeafKey_t : Text
var $cmpParent_o : Object
var $cmpLeafKey_t : Text
var $srcType_i : Integer
var $cmpType_i : Integer
var $nativeSrcType_i : Integer
var $srcText_t : Text
var $cmpText_t : Text
var $srcBool_b : Boolean
var $cmpBool_b : Boolean

$result_i:=-1

OTr_z_Lock

If (OTr_z_IsValidHandle($inSourceObject_i)\
 & OTr_z_IsValidHandle($inCompareObject_i))
	
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inSourceObject_i}; $inSourceTag_t; \
		False:C215; ->$srcParent_o; ->$srcLeafKey_t)\
		 & OTr_z_ResolvePath(<>OTR_Objects_ao{$inCompareObject_i}; $inCompareTag_t; \
		False:C215; ->$cmpParent_o; ->$cmpLeafKey_t))
		
		If (OB Is defined:C1231($srcParent_o; $srcLeafKey_t)\
			 & OB Is defined:C1231($cmpParent_o; $cmpLeafKey_t))
			
			$srcType_i:=OTr_z_MapType($srcParent_o; $srcLeafKey_t)
			$cmpType_i:=OTr_z_MapType($cmpParent_o; $cmpLeafKey_t)
			
			If ($srcType_i=$cmpType_i)
				
				$nativeSrcType_i:=OB Get type:C1230($srcParent_o; $srcLeafKey_t)
				$result_i:=0
				
				Case of 
						
					: ($nativeSrcType_i=Is real:K8:4)
						If (OB Get:C1224($srcParent_o; $srcLeafKey_t; Is real:K8:4)\
							=OB Get:C1224($cmpParent_o; $cmpLeafKey_t; Is real:K8:4))
							$result_i:=1
						End if 
						
					: (($nativeSrcType_i=Is longint:K8:6)\
						 | ($nativeSrcType_i=Is integer:K8:5))
						If (OB Get:C1224($srcParent_o; $srcLeafKey_t; Is longint:K8:6)\
							=OB Get:C1224($cmpParent_o; $cmpLeafKey_t; Is longint:K8:6))
							$result_i:=1
						End if 
						
					: ($nativeSrcType_i=Is boolean:K8:9)
						$srcBool_b:=OB Get:C1224(\
							$srcParent_o; $srcLeafKey_t; Is boolean:K8:9)
						$cmpBool_b:=OB Get:C1224(\
							$cmpParent_o; $cmpLeafKey_t; Is boolean:K8:9)
						If (($srcBool_b & $cmpBool_b)\
							 | ((Not:C34($srcBool_b)) & (Not:C34($cmpBool_b))))
							$result_i:=1
						End if 
						
					: ($nativeSrcType_i=Is text:K8:3)
						$srcText_t:=OB Get:C1224(\
							$srcParent_o; $srcLeafKey_t; Is text:K8:3)
						$cmpText_t:=OB Get:C1224(\
							$cmpParent_o; $cmpLeafKey_t; Is text:K8:3)
						If (OTr_u_EqualStrings($srcText_t; $cmpText_t))
							$result_i:=1
						End if 
						
					: ($nativeSrcType_i=Is BLOB:K8:12)
						If (OTr_u_EqualBLOBs(OB Get:C1224($srcParent_o; $srcLeafKey_t; Is BLOB:K8:12); \
							OB Get:C1224($cmpParent_o; $cmpLeafKey_t; Is BLOB:K8:12)))
							$result_i:=1
						End if 
						
					: ($nativeSrcType_i=Is picture:K8:10)
						If (OTr_u_EqualPictures(OB Get:C1224($srcParent_o; $srcLeafKey_t; Is picture:K8:10); \
							OB Get:C1224($cmpParent_o; $cmpLeafKey_t; Is picture:K8:10)))
							$result_i:=1
						End if 
						
					: ($nativeSrcType_i=Is object:K8:27)
						If (OTr_u_EqualObjects(OB Get:C1224($srcParent_o; $srcLeafKey_t; Is object:K8:27); OB Get:C1224($cmpParent_o; $cmpLeafKey_t; Is object:K8:27)))
							$result_i:=1
						End if 
						
					: ($nativeSrcType_i=Is collection:K8:32)
						If (JSON Stringify:C1217(OB Get:C1224(\
							$srcParent_o; $srcLeafKey_t; Is collection:K8:32))\
							=JSON Stringify:C1217(OB Get:C1224(\
							$cmpParent_o; $cmpLeafKey_t; Is collection:K8:32)))
							$result_i:=1
						End if 
						
				End case 
				
			Else 
				OTr_z_Error("Type mismatch"; Current method name:C684)
			End if 
			
		Else 
			OTr_z_Error("Item not found"; Current method name:C684)
		End if 
		
	Else 
		OTr_z_Error("Invalid path"; Current method name:C684)
	End if 
	
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
