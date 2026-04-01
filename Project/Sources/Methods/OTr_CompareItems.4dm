//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_CompareItems ($srcHandle_i : Integer; \
//   $srcTag_t : Text; $cmpHandle_i : Integer; \
//   $cmpTag_t : Text) --> $result_i : Integer

// Compares two items for equality. Both handles may be the same object.
// Returns 1 if items are identical, 0 if not, -1 on error.
// Objects are compared via JSON serialisation. Collections are compared
// element-by-element via JSON serialisation. BLOBs are compared by
// content. Text (including encoded dates, times, pointers) is compared
// with exact string equality.

// Access: Shared

// Parameters:
//   $srcHandle_i : Integer : A handle to the source object
//   $srcTag_t    : Text    : Source item tag
//   $cmpHandle_i : Integer : A handle to the comparison object
//   $cmpTag_t    : Text    : Comparison item tag

// Returns:
//   $result_i : Integer : 1 if identical, 0 if not, -1 on error

// Wayne Stewart, 2026-04-01 - Uses helper equality methods for text, object,
//   BLOB, and Picture comparisons.
// Wayne Stewart, 2026-04-01 - Reworked boolean comparison for 4D compiler.
// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($srcHandle_i : Integer; $srcTag_t : Text; \
$cmpHandle_i : Integer; $cmpTag_t : Text)->$result_i : Integer

var $srcParent_o : Object
var $srcLeafKey_t : Text
var $cmpParent_o : Object
var $cmpLeafKey_t : Text
var $srcType_i : Integer
var $cmpType_i : Integer
var $nativeSrcType_i : Integer
var $srcBlobIdx_i : Integer
var $cmpBlobIdx_i : Integer
var $srcPicIdx_i : Integer
var $cmpPicIdx_i : Integer
var $srcText_t : Text
var $cmpText_t : Text
var $srcBool_b : Boolean
var $cmpBool_b : Boolean

$result_i:=-1

OTr__Lock

If (OTr__IsValidHandle($srcHandle_i)\
 & OTr__IsValidHandle($cmpHandle_i))
	
	If (OTr__ResolvePath(<>OTR_Objects_ao{$srcHandle_i}; $srcTag_t; \
		False:C215; ->$srcParent_o; ->$srcLeafKey_t)\
		 & OTr__ResolvePath(<>OTR_Objects_ao{$cmpHandle_i}; $cmpTag_t; \
		False:C215; ->$cmpParent_o; ->$cmpLeafKey_t))
		
		If (OB Is defined:C1231($srcParent_o; $srcLeafKey_t)\
			 & OB Is defined:C1231($cmpParent_o; $cmpLeafKey_t))
			
			$srcType_i:=OTr__MapType($srcParent_o; $srcLeafKey_t)
			$cmpType_i:=OTr__MapType($cmpParent_o; $cmpLeafKey_t)
			
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
						
						// BLOB items: compare actual binary content
						If (Substring:C12($srcText_t; 1; 5)="blob:")
							$srcBlobIdx_i:=Num:C11(Substring:C12($srcText_t; 6))
							$cmpBlobIdx_i:=Num:C11(Substring:C12($cmpText_t; 6))
							If (($srcBlobIdx_i>0)\
								 & ($cmpBlobIdx_i>0)\
								 & ($srcBlobIdx_i<=\
								Size of array:C274(<>OTR_Blobs_ablob))\
								 & ($cmpBlobIdx_i<=\
								Size of array:C274(<>OTR_Blobs_ablob)))
								If (OTr__EqualBLOBs(<>OTR_Blobs_ablob{$srcBlobIdx_i}; <>OTR_Blobs_ablob{$cmpBlobIdx_i}))
									$result_i:=1
								End if 
							End if 
						Else 
							// Picture items: compare actual picture content
							If (Substring:C12($srcText_t; 1; 4)="pic:")
								$srcPicIdx_i:=Num:C11(Substring:C12($srcText_t; 5))
								$cmpPicIdx_i:=Num:C11(Substring:C12($cmpText_t; 5))
								If (($srcPicIdx_i>0)\
									 & ($cmpPicIdx_i>0)\
									 & ($srcPicIdx_i<=\
									Size of array:C274(<>OTR_Pictures_apic))\
									 & ($cmpPicIdx_i<=\
									Size of array:C274(<>OTR_Pictures_apic)))
									If (OTr__EqualPictures(<>OTR_Pictures_apic{$srcPicIdx_i}; <>OTR_Pictures_apic{$cmpPicIdx_i}))
										$result_i:=1
									End if 
								End if 
							Else 
								// All other text types: helper-based string comparison
								If (Otr__EqualStrings($srcText_t; $cmpText_t))
									$result_i:=1
								End if 
							End if 
						End if 
						
					: ($nativeSrcType_i=Is object:K8:27)
						If (OTr__EqualObjects(OB Get:C1224(\
							$srcParent_o; $srcLeafKey_t; Is object:K8:27); \
							OB Get:C1224(\
							$cmpParent_o; $cmpLeafKey_t; Is object:K8:27)))
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
				OTr__Error("Type mismatch"; Current method name:C684)
			End if 
			
		Else 
			OTr__Error("Item not found"; Current method name:C684)
		End if 
		
	Else 
		OTr__Error("Invalid path"; Current method name:C684)
	End if 
	
Else 
	OTr__Error("Invalid handle"; Current method name:C684)
End if 

OTr__Unlock
