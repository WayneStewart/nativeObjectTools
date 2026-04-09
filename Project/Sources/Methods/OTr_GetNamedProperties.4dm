//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetNamedProperties (inObject; inTag; outType {; outItemSize {; outDataSize {; outIndex}}})

// Returns properties of the item identified by $inTag_t. $outIndex_ptr
// is always set to 0 (reserved for backwards compatibility).

// Access: Shared

// Parameters:
//   $inObject_i        : Integer : OTr inObject
//   $inTag_t           : Text    : Tag of the item to query (inTag)
//   $outType_ptr     : Pointer : Receives OT type constant (Longint)
//   $outItemSize_ptr : Pointer : Receives item size including tag
//                                (Longint) (optional)
//   $outDataSize_ptr : Pointer : Receives item data size (Longint)
//                                (optional)
//   $outIndex_ptr    : Pointer : Always set to 0 (Longint) (optional)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $outType_ptr : Pointer; \
$outItemSize_ptr : Pointer; $outDataSize_ptr : Pointer; \
$outIndex_ptr : Pointer)

OTr_zAddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $nativeType_i : Integer
var $dataSize_i : Integer
var $itemSize_i : Integer
var $valText_t : Text
var $valObj_o : Object
var $valCol_c : Collection
var $needItemSize_b : Boolean
var $needDataSize_b : Boolean
var $needIndex_b : Boolean

$needItemSize_b:=(Count parameters:C259>=4)
$needDataSize_b:=(Count parameters:C259>=5)
$needIndex_b:=(Count parameters:C259>=6)

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			
			$outType_ptr->:=OTr_zMapType($parent_o; $leafKey_t)
			
			If ($needItemSize_b | $needDataSize_b)
				
				$nativeType_i:=OB Get type:C1230($parent_o; $leafKey_t)
				$dataSize_i:=0
				
				Case of 
						
					: ($nativeType_i=Is real:K8:4)
						$dataSize_i:=8
						
					: (($nativeType_i=Is longint:K8:6)\
						 | ($nativeType_i=Is integer:K8:5))
						$dataSize_i:=4
						
					: ($nativeType_i=Is boolean:K8:9)
						$dataSize_i:=1
						
					: ($nativeType_i=Is object:K8:27)
						$valObj_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
						$dataSize_i:=Length:C16(JSON Stringify:C1217($valObj_o))
						
					: ($nativeType_i=Is collection:K8:32)
						$valCol_c:=OB Get:C1224(\
							$parent_o; $leafKey_t; Is collection:K8:32)
						$dataSize_i:=Length:C16(JSON Stringify:C1217($valCol_c))
						
					: ($nativeType_i=Is text:K8:3)
						$dataSize_i:=Length:C16(OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3))
						
					: ($nativeType_i=Is BLOB:K8:12)
						$dataSize_i:=BLOB size:C605(OB Get:C1224($parent_o; $leafKey_t; Is BLOB:K8:12))
						
					: ($nativeType_i=Is picture:K8:10)
						$dataSize_i:=Picture size:C356(OB Get:C1224($parent_o; $leafKey_t; Is picture:K8:10))
						
				End case 
				
				$itemSize_i:=$dataSize_i+Length:C16($leafKey_t)
				
				If ($needItemSize_b)
					$outItemSize_ptr->:=$itemSize_i
				End if 
				If ($needDataSize_b)
					$outDataSize_ptr->:=$dataSize_i
				End if 
				
			End if 
			
			If ($needIndex_b)
				$outIndex_ptr->:=0  // Always 0 — legacy compatibility
			End if 
			
		Else 
			OTr_zError("Item not found: "+$inTag_t; Current method name:C684)
		End if 
	Else 
		OTr_zError("Invalid path: "+$inTag_t; Current method name:C684)
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name:C684)
