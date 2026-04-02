//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ObjectSize ($handle_i : Integer) \
//   --> $size_i : Integer

// Returns an approximation of the total size of an OTr object in bytes.
// The object is serialised to JSON and the character length is returned.
// BLOB sizes from the parallel array are added for referenced blobs.
// This is an approximation; byte counts will not match the legacy plugin.

// Access: Shared

// Parameters:
//   $handle_i : Integer : A handle to an object

// Returns:
//   $size_i : Integer : Approximate size in bytes, or 0 on error

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer)->$size_i : Integer

var $blobIndex_i; $pictureIndex_i; $externalSize_i : Integer
var $storedValueText_t; $thisKey_t : Text
var $theseKeys_c : Collection
var $thisObject_o : Object

$size_i:=0
$theseKeys_c:=New collection:C1472  // Initialise it

// OTr_zLock // Unnecessary to lock for Read Only access

OTr_zInit

If (OTr_zIsValidHandle($handle_i))
	$thisObject_o:=<>OTR_Objects_ao{$handle_i}  // This is not a copy, just making it easier to work with
	$size_i:=Length:C16(JSON Stringify:C1217(<>OTR_Objects_ao{$handle_i}))  // Get the basic text length
	
	// Get the keys, so we can check for 'external' storage
	$theseKeys_c:=OB Keys:C1719($thisObject_o)
	
	
	For each ($thisKey_t; $theseKeys_c)
		
		
		If (OB Get type:C1230($thisObject_o; $thisKey_t)=Is text:K8:3)
			$storedValueText_t:=$thisObject_o[$thisKey_t]
			Case of 
				: ($storedValueText_t="blob:@")
					$blobIndex_i:=Num:C11(Substring:C12($storedValueText_t; 6))
					If (($blobIndex_i>0)\
						 & ($blobIndex_i<=Size of array:C274(<>OTR_Blobs_ablob))\
						 & (<>OTR_BlobInUse_ab{$blobIndex_i}))
						$externalSize_i:=BLOB size:C605(<>OTR_Blobs_ablob{$blobIndex_i})
					End if 
					
				: ($storedValueText_t="pic:@")
					$pictureIndex_i:=Num:C11(Substring:C12($storedValueText_t; 5))
					If (($pictureIndex_i>0)\
						 & ($pictureIndex_i<=Size of array:C274(<>OTR_Pictures_apic))\
						 & (<>OTR_PicInUse_ab{$pictureIndex_i}))
						$externalSize_i:=Picture size:C356(<>OTR_Pictures_apic{$pictureIndex_i})
					End if 
					
				Else 
					$externalSize_i:=0
					
			End case 
			
			$size_i:=$size_i+$externalSize_i
			
		End if 
		
	End for each 
	
	
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

// OTr_zUnlock // Unnecessary to lock for Read Only access











