//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr__ReleaseObjBinaries ($obj_o : Object)

// Walks an object's properties, releasing any BLOB and Picture parallel
// array slots referenced by blob:N and pic:N values. Recurses into
// nested embedded objects. Called within a held registry lock.

// Access: Private

// Parameters:
//   $obj_o : Object : Object to scan and clean up

// Returns: Nothing

// Wayne Stewart, 2026-04-01 - Updated OB Keys usage for collection return.
// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($obj_o : Object)

var $k_i : Integer
var $nativeType_i : Integer
var $valText_t : Text
var $blobIdx_i : Integer
var $picIdx_i : Integer
var $thisKey_t : Text
var $keys_c : Collection
var $nested_o : Object

$keys_c:=New collection:C1472

If ($obj_o#Null:C1517)
	
	$keys_c:=OB Keys:C1719($obj_o)
	
	For each ($thisKey_t; $keys_c)
		
		$nativeType_i:=OB Get type:C1230($obj_o; $thisKey_t)
		
		Case of 
				
			: ($nativeType_i=Is text:K8:3)
				$valText_t:=OB Get:C1224($obj_o; $thisKey_t; Is text:K8:3)
				
				If (Substring:C12($valText_t; 1; 5)="blob:")
					$blobIdx_i:=Num:C11(Substring:C12($valText_t; 6))
					If (($blobIdx_i>0)\
						 & ($blobIdx_i<=Size of array:C274(<>OTR_Blobs_ablob))\
						 & (<>OTR_BlobInUse_ab{$blobIdx_i}))
						CLEAR VARIABLE:C89(<>OTR_Blobs_ablob{$blobIdx_i})
						<>OTR_BlobInUse_ab{$blobIdx_i}:=False:C215
					End if 
					
				Else 
					If (Substring:C12($valText_t; 1; 4)="pic:")
						$picIdx_i:=Num:C11(Substring:C12($valText_t; 5))
						If (($picIdx_i>0)\
							 & ($picIdx_i<=Size of array:C274(<>OTR_Pictures_apic))\
							 & (<>OTR_PicInUse_ab{$picIdx_i}))
							<>OTR_PicInUse_ab{$picIdx_i}:=False:C215
						End if 
					End if 
				End if 
				
			: ($nativeType_i=Is object:K8:27)
				$nested_o:=OB Get:C1224($obj_o; $thisKey_t; Is object:K8:27)
				OTr__ReleaseObjBinaries($nested_o)
				
		End case 
		
	End for each 
	
End if 
