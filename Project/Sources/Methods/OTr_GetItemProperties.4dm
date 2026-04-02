//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetItemProperties ($handle_i : Integer; \
//   $index_i : Integer; $outName_ptr : Pointer \
//   {; $outType_ptr : Pointer \
//   {; $outItemSize_ptr : Pointer \
//   {; $outDataSize_ptr : Pointer}}})

// Returns properties of the item at 1-based index $index_i. Items are
// enumerated from OB Keys; internal __otr_ properties are excluded.
// Kept for backwards compatibility — item order is indeterminate and
// the index is therefore unreliable. Prefer OTr_GetNamedProperties.

// Access: Shared

// Parameters:
//   $handle_i      : Integer : A handle to an object
//   $index_i       : Integer : 1-based index of the item
//   $outName_ptr   : Pointer : Receives the item name (Text)
//   $outType_ptr   : Pointer : Receives OT type constant (Longint)
//                              (optional)
//   $outItemSize_ptr : Pointer : Receives item size in bytes (Longint)
//                              (optional)
//   $outDataSize_ptr : Pointer : Receives data size in bytes (Longint)
//                              (optional)

// Returns: Nothing

// Wayne Stewart, 2026-04-01 - Updated OB Keys usage for collection return.
// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $index_i : Integer; \
$outName_ptr : Pointer; $outType_ptr : Pointer; \
$outItemSize_ptr : Pointer; $outDataSize_ptr : Pointer)

var $k_i : Integer
var $validIdx_i : Integer
var $nativeType_i : Integer
var $dataSize_i : Integer
var $itemSize_i : Integer
var $blobIdx_i : Integer
var $valText_t : Text
var $valObj_o : Object
var $valCol_c : Collection
var $needType_b : Boolean
var $needItemSize_b : Boolean
var $needDataSize_b : Boolean
var $allKeys_c : Collection
var $thisKey_t : Text

ARRAY TEXT:C222($keys_at; 0)

$allKeys_c:=New collection:C1472

$needType_b:=(Count parameters:C259>=4)
$needItemSize_b:=(Count parameters:C259>=5)
$needDataSize_b:=(Count parameters:C259>=6)

OTr_zLock

If (OTr_zIsValidHandle($handle_i))
	
	$allKeys_c:=OB Keys:C1719(<>OTR_Objects_ao{$handle_i})
	
	// Filter out __otr_ internal properties
	For each ($thisKey_t; $allKeys_c)
		If (Substring:C12($thisKey_t; 1; 7)#"__otr_")
			APPEND TO ARRAY:C911($keys_at; $thisKey_t)
		End if 
	End for each 
	
	If (($index_i>=1) & ($index_i<=Size of array:C274($keys_at)))
		
		$outName_ptr->:=$keys_at{$index_i}
		
		If ($needType_b | $needItemSize_b | $needDataSize_b)
			
			$nativeType_i:=OB Get type:C1230(\
				<>OTR_Objects_ao{$handle_i}; $keys_at{$index_i})
			$dataSize_i:=0
			
			Case of 
					
				: ($nativeType_i=Is real:K8:4)
					$dataSize_i:=8
					
				: (($nativeType_i=Is longint:K8:6) | ($nativeType_i=Is integer:K8:5))
					$dataSize_i:=4
					
				: ($nativeType_i=Is boolean:K8:9)
					$dataSize_i:=1
					
				: ($nativeType_i=Is object:K8:27)
					$valObj_o:=OB Get:C1224(\
						<>OTR_Objects_ao{$handle_i}; \
						$keys_at{$index_i}; Is object:K8:27)
					$dataSize_i:=Length:C16(JSON Stringify:C1217($valObj_o))
					
				: ($nativeType_i=Is collection:K8:32)
					$valCol_c:=OB Get:C1224(\
						<>OTR_Objects_ao{$handle_i}; \
						$keys_at{$index_i}; Is collection:K8:32)
					$dataSize_i:=Length:C16(JSON Stringify:C1217($valCol_c))
					
				: ($nativeType_i=Is text:K8:3)
					$valText_t:=OB Get:C1224(\
						<>OTR_Objects_ao{$handle_i}; \
						$keys_at{$index_i}; Is text:K8:3)
					If (Substring:C12($valText_t; 1; 5)="blob:")
						$blobIdx_i:=Num:C11(Substring:C12($valText_t; 6))
						If (($blobIdx_i>0)\
							 & ($blobIdx_i<=Size of array:C274(<>OTR_Blobs_ablob))\
							 & (<>OTR_BlobInUse_ab{$blobIdx_i}))
							$dataSize_i:=BLOB size:C605(\
								<>OTR_Blobs_ablob{$blobIdx_i})
						End if 
					Else 
						$dataSize_i:=Length:C16($valText_t)
					End if 
					
			End case 
			
			$itemSize_i:=$dataSize_i+Length:C16($keys_at{$index_i})
			
			If ($needType_b)
				$outType_ptr->:=OTr_zMapType(\
					<>OTR_Objects_ao{$handle_i}; $keys_at{$index_i})
			End if 
			If ($needItemSize_b)
				$outItemSize_ptr->:=$itemSize_i
			End if 
			If ($needDataSize_b)
				$outDataSize_ptr->:=$dataSize_i
			End if 
			
		End if 
		
	Else 
		OTr_zError("Index out of range: "+String:C10($index_i); \
			Current method name:C684)
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

OTr_zUnlock
