//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetAllNamedProperties ($handle_i : Integer; \
//   $tag_t : Text; $outNames_ptr : Pointer \
//   {; $outTypes_ptr : Pointer \
//   {; $outItemSizes_ptr : Pointer \
//   {; $outDataSizes_ptr : Pointer}}})

// Returns information about all items in the object (or embedded object).
// $outNames_ptr must point to a Text array; the optional pointer params
// must point to Longint arrays. Internal __otr_ properties are excluded.
// Item names are returned in indeterminate order.

// Access: Shared

// Parameters:
//   $handle_i       : Integer : A handle to an object
//   $tag_t          : Text    : Tag of an embedded object (empty for root)
//   $outNames_ptr   : Pointer : Receives item names (Text array)
//   $outTypes_ptr   : Pointer : Receives OT type constants (Longint array)
//                               (optional)
//   $outItemSizes_ptr : Pointer : Receives item sizes in bytes
//                               (Longint array) (optional)
//   $outDataSizes_ptr : Pointer : Receives data sizes in bytes
//                               (Longint array) (optional)

// Returns: Nothing

// Wayne Stewart, 2026-04-01 - Updated OB Keys usage for collection return.
// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer; $tag_t : Text; $outNames_ptr : Pointer; \
$outTypes_ptr : Pointer; $outItemSizes_ptr : Pointer; \
$outDataSizes_ptr : Pointer)

var $target_o : Object
var $parent_o : Object
var $leafKey_t : Text
var $k_i : Integer
var $needTypes_b : Boolean
var $needItemSizes_b : Boolean
var $needDataSizes_b : Boolean
var $nativeType_i : Integer
var $dataSize_i : Integer
var $itemSize_i : Integer
var $blobIdx_i : Integer
var $valText_t : Text
var $valObj_o : Object
var $valCol_c : Collection
var $keys_c : Collection
var $thisKey_t : Text

$keys_c:=New collection:C1472

$needTypes_b:=(Count parameters:C259>=4)
$needItemSizes_b:=(Count parameters:C259>=5)
$needDataSizes_b:=(Count parameters:C259>=6)

OTr__Lock

If (OTr__IsValidHandle($handle_i))
	
	// Determine the target object
	If ($tag_t="")
		$target_o:=<>OTR_Objects_ao{$handle_i}
	Else 
		If (OTr__ResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False:C215; \
			->$parent_o; ->$leafKey_t))
			If (OB Is defined:C1231($parent_o; $leafKey_t))
				$target_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
				If ($target_o=Null:C1517)
					OTr__Error(\
						"Tag does not reference an embedded object"; \
						Current method name:C684)
				End if 
			Else 
				OTr__Error("Item not found: "+$tag_t; Current method name:C684)
			End if 
		Else 
			OTr__Error("Invalid path: "+$tag_t; Current method name:C684)
		End if 
	End if 
	
	If ($target_o#Null:C1517)
		
		// Collect property names, excluding __otr_ internal properties
		$keys_c:=OB Keys:C1719($target_o)
		ARRAY TEXT:C222($outNames_ptr->; 0)
		
		If ($needTypes_b)
			ARRAY LONGINT:C221($outTypes_ptr->; 0)
		End if 
		If ($needItemSizes_b)
			ARRAY LONGINT:C221($outItemSizes_ptr->; 0)
		End if 
		If ($needDataSizes_b)
			ARRAY LONGINT:C221($outDataSizes_ptr->; 0)
		End if 
		
		For each ($thisKey_t; $keys_c)
			
			If (Substring:C12($thisKey_t; 1; 7)#"__otr_")
				
				APPEND TO ARRAY:C911($outNames_ptr->; $thisKey_t)
				
				If ($needTypes_b)
					APPEND TO ARRAY:C911($outTypes_ptr->; \
						OTr__MapType($target_o; $thisKey_t))
				End if 
				
				If ($needItemSizes_b | $needDataSizes_b)
					
					$nativeType_i:=OB Get type:C1230($target_o; $thisKey_t)
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
							$valObj_o:=OB Get:C1224(\
								$target_o; $thisKey_t; Is object:K8:27)
							$dataSize_i:=Length:C16(JSON Stringify:C1217($valObj_o))
							
						: ($nativeType_i=Is collection:K8:32)
							$valCol_c:=OB Get:C1224(\
								$target_o; $thisKey_t; Is collection:K8:32)
							$dataSize_i:=Length:C16(JSON Stringify:C1217($valCol_c))
							
						: ($nativeType_i=Is text:K8:3)
							$valText_t:=OB Get:C1224(\
								$target_o; $thisKey_t; Is text:K8:3)
							If (Substring:C12($valText_t; 1; 5)="blob:")
								$blobIdx_i:=Num:C11(Substring:C12($valText_t; 6))
								If (($blobIdx_i>0)\
									 & ($blobIdx_i<=\
									Size of array:C274(<>OTR_Blobs_ablob))\
									 & (<>OTR_BlobInUse_ab{$blobIdx_i}))
									$dataSize_i:=BLOB size:C605(\
										<>OTR_Blobs_ablob{$blobIdx_i})
								End if 
							Else 
								$dataSize_i:=Length:C16($valText_t)
							End if 
							
					End case 
					
					$itemSize_i:=$dataSize_i+Length:C16($thisKey_t)
					
					If ($needItemSizes_b)
						APPEND TO ARRAY:C911($outItemSizes_ptr->; $itemSize_i)
					End if 
					If ($needDataSizes_b)
						APPEND TO ARRAY:C911($outDataSizes_ptr->; $dataSize_i)
					End if 
					
				End if 
				
			End if 
			
		End for each 
		
	Else 
		// Clear outputs on error
		ARRAY TEXT:C222($outNames_ptr->; 0)
		If ($needTypes_b)
			ARRAY LONGINT:C221($outTypes_ptr->; 0)
		End if 
		If ($needItemSizes_b)
			ARRAY LONGINT:C221($outItemSizes_ptr->; 0)
		End if 
		If ($needDataSizes_b)
			ARRAY LONGINT:C221($outDataSizes_ptr->; 0)
		End if 
		
	End if 
	
Else 
	OTr__Error("Invalid handle"; Current method name:C684)
	ARRAY TEXT:C222($outNames_ptr->; 0)
End if 

OTr__Unlock
