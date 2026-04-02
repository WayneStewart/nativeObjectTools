//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_CopyItem ($srcHandle_i : Integer; \
//   $srcTag_t : Text; $destHandle_i : Integer; $destTag_t : Text)

// Copies the item at $srcTag_t to $destTag_t. The destination need not
// exist; it will be created. Source and destination handles may be the
// same. Embedded objects are deep-copied via OB Copy. BLOBs and
// Pictures allocate a new slot in the parallel array.

// Access: Shared

// Parameters:
//   $srcHandle_i  : Integer : A handle to the source object
//   $srcTag_t     : Text    : Source item tag
//   $destHandle_i : Integer : A handle to the destination object
//   $destTag_t    : Text    : Destination item tag

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($srcHandle_i : Integer; $srcTag_t : Text; \
$destHandle_i : Integer; $destTag_t : Text)

var $srcParent_o : Object
var $srcLeafKey_t : Text
var $destParent_o : Object
var $destLeafKey_t : Text
var $nativeType_i : Integer
var $textVal_t : Text
var $blobIdx_i : Integer
var $picIdx_i : Integer
var $newBlobIdx_i : Integer
var $newPicIdx_i : Integer

OTr_zLock

If (OTr_zIsValidHandle($srcHandle_i)\
 & OTr_zIsValidHandle($destHandle_i))
	
	If (OTr_zResolvePath(<>OTR_Objects_ao{$srcHandle_i}; $srcTag_t; \
		False:C215; ->$srcParent_o; ->$srcLeafKey_t))
		
		If (OB Is defined:C1231($srcParent_o; $srcLeafKey_t))
			
			If (OTr_zResolvePath(<>OTR_Objects_ao{$destHandle_i}; \
				$destTag_t; True:C214; ->$destParent_o; ->$destLeafKey_t))
				
				$nativeType_i:=OB Get type:C1230($srcParent_o; $srcLeafKey_t)
				
				Case of 
						
					: ($nativeType_i=Is real:K8:4)
						OB SET:C1220($destParent_o; $destLeafKey_t; \
							OB Get:C1224($srcParent_o; $srcLeafKey_t; Is real:K8:4))
						
					: (($nativeType_i=Is longint:K8:6)\
						 | ($nativeType_i=Is integer:K8:5))
						OB SET:C1220($destParent_o; $destLeafKey_t; \
							OB Get:C1224($srcParent_o; $srcLeafKey_t; Is longint:K8:6))
						
					: ($nativeType_i=Is boolean:K8:9)
						OB SET:C1220($destParent_o; $destLeafKey_t; \
							OB Get:C1224($srcParent_o; $srcLeafKey_t; Is boolean:K8:9))
						
					: ($nativeType_i=Is object:K8:27)
						OB SET:C1220($destParent_o; $destLeafKey_t; OB Copy:C1225(OB Get:C1224(\
							$srcParent_o; $srcLeafKey_t; Is object:K8:27)))
						
					: ($nativeType_i=Is collection:K8:32)
						OB SET:C1220($destParent_o; $destLeafKey_t; \
							OB Get:C1224($srcParent_o; $srcLeafKey_t; Is collection:K8:32))
						
					: ($nativeType_i=Is text:K8:3)
						$textVal_t:=OB Get:C1224(\
							$srcParent_o; $srcLeafKey_t; Is text:K8:3)
						
						If (Substring:C12($textVal_t; 1; 5)="blob:")
							$blobIdx_i:=Num:C11(Substring:C12($textVal_t; 6))
							If (($blobIdx_i>0)\
								 & ($blobIdx_i<=Size of array:C274(<>OTR_Blobs_ablob))\
								 & (<>OTR_BlobInUse_ab{$blobIdx_i}))
								$newBlobIdx_i:=Find in array:C230(\
									<>OTR_BlobInUse_ab; False:C215)
								If ($newBlobIdx_i=-1)
									$newBlobIdx_i:=\
										Size of array:C274(<>OTR_Blobs_ablob)+1
									INSERT IN ARRAY:C227(<>OTR_Blobs_ablob; \
										$newBlobIdx_i)
									INSERT IN ARRAY:C227(<>OTR_BlobInUse_ab; \
										$newBlobIdx_i)
								End if 
								<>OTR_Blobs_ablob{$newBlobIdx_i}:=\
									<>OTR_Blobs_ablob{$blobIdx_i}
								<>OTR_BlobInUse_ab{$newBlobIdx_i}:=True:C214
								OB SET:C1220($destParent_o; $destLeafKey_t; \
									"blob:"+String:C10($newBlobIdx_i))
							End if 
							
						Else 
							If (Substring:C12($textVal_t; 1; 4)="pic:")
								$picIdx_i:=Num:C11(Substring:C12($textVal_t; 5))
								If (($picIdx_i>0)\
									 & ($picIdx_i<=\
									Size of array:C274(<>OTR_Pictures_apic))\
									 & (<>OTR_PicInUse_ab{$picIdx_i}))
									$newPicIdx_i:=Find in array:C230(\
										<>OTR_PicInUse_ab; False:C215)
									If ($newPicIdx_i=-1)
										$newPicIdx_i:=\
											Size of array:C274(<>OTR_Pictures_apic)+1
										INSERT IN ARRAY:C227(<>OTR_Pictures_apic; \
											$newPicIdx_i)
										INSERT IN ARRAY:C227(<>OTR_PicInUse_ab; \
											$newPicIdx_i)
									End if 
									<>OTR_Pictures_apic{$newPicIdx_i}:=\
										<>OTR_Pictures_apic{$picIdx_i}
									<>OTR_PicInUse_ab{$newPicIdx_i}:=True:C214
									OB SET:C1220($destParent_o; $destLeafKey_t; \
										"pic:"+String:C10($newPicIdx_i))
								End if 
							Else 
								// Plain text (including encoded types)
								OB SET:C1220($destParent_o; $destLeafKey_t; $textVal_t)
							End if 
						End if 
						
				End case 
				
			Else 
				OTr_zError("Cannot resolve destination: "+$destTag_t; \
					Current method name:C684)
			End if 
			
		Else 
			OTr_zError("Source item not found: "+$srcTag_t; \
				Current method name:C684)
		End if 
		
	Else 
		OTr_zError("Invalid source path: "+$srcTag_t; Current method name:C684)
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

OTr_zUnlock
