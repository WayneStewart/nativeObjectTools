//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_uExpandBinaries ($obj_o) -> $expanded_o
// 
// Walks all properties of $obj_o, recursing into nested
// sub-objects, and replaces inline binary references with
// self-contained Base64 strings suitable for JSON export.
//
// Conversions performed:
//   "blob:N"            -> "b64blob:<base64data>"
//   "pic:N"             -> "b64pic:.png:<base64data>"
//   "var:blob:blob:N"   -> "var:blob:b64blob:<base64data>"
//   "var:picture:pic:N" -> "var:picture:b64pic:.png:<base64data>"
//
// Returns a deep copy of $obj_o with all binary refs
// expanded. The input object is not modified.
// Must be called within the registry lock.
// 
// **ORIGINAL DOCUMENTATION**
// 
// Utility method used by the OTr export pipeline.
// Not part of the public API.
// 
// Access: Private
// 
// Parameters:
//   $obj_o          : Object : Snapshot copy of an OTr object
//   Function result : Object : Object with all binary refs expanded
// 
// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($obj_o : Object)->$expanded_o : Object

var $keys_c : Collection
var $thisKey_t : Text
var $val_t : Text
var $innerRef_t : Text
var $slot_i : Integer
var $tempBlob_blob : Blob
var $tempPic_pic : Picture
var $nested_o : Object

$expanded_o:=OB Copy($obj_o)
$keys_c:=OB Keys($expanded_o)

For each ($thisKey_t; $keys_c)
	
	Case of 
			
		: (OB Get type($expanded_o; $thisKey_t)=Is text)
			$val_t:=OB Get($expanded_o; $thisKey_t; Is text)
			
			Case of 
					
				: (Substring($val_t; 1; 5)="blob:")
					$slot_i:=Num(Substring($val_t; 6))
					If (($slot_i>0) & ($slot_i<=Size of array(<>OTR_Blobs_ablob)) & (<>OTR_BlobInUse_ab{$slot_i}))
						$tempBlob_blob:=<>OTR_Blobs_ablob{$slot_i}
						BASE64 ENCODE($tempBlob_blob)
						OB SET($expanded_o; $thisKey_t; "b64blob:"+Convert to text($tempBlob_blob; "US-ASCII"))
					End if 
					
				: (Substring($val_t; 1; 4)="pic:")
					$slot_i:=Num(Substring($val_t; 5))
					If (($slot_i>0) & ($slot_i<=Size of array(<>OTR_Pictures_apic)) & (<>OTR_PicInUse_ab{$slot_i}))
						PICTURE TO BLOB(<>OTR_Pictures_apic{$slot_i}; $tempBlob_blob; ".png")
						BASE64 ENCODE($tempBlob_blob)
						OB SET($expanded_o; $thisKey_t; "b64pic:.png:"+Convert to text($tempBlob_blob; "US-ASCII"))
					End if 
					
				: (Substring($val_t; 1; 9)="var:blob:")
					$innerRef_t:=Substring($val_t; 10)
					$slot_i:=Num(Substring($innerRef_t; 6))
					If (($slot_i>0) & ($slot_i<=Size of array(<>OTR_Blobs_ablob)) & (<>OTR_BlobInUse_ab{$slot_i}))
						$tempBlob_blob:=<>OTR_Blobs_ablob{$slot_i}
						BASE64 ENCODE($tempBlob_blob)
						OB SET($expanded_o; $thisKey_t; "var:blob:b64blob:"+Convert to text($tempBlob_blob; "US-ASCII"))
					End if 
					
				: (Substring($val_t; 1; 12)="var:picture:")
					$innerRef_t:=Substring($val_t; 13)
					$slot_i:=Num(Substring($innerRef_t; 5))
					If (($slot_i>0) & ($slot_i<=Size of array(<>OTR_Pictures_apic)) & (<>OTR_PicInUse_ab{$slot_i}))
						PICTURE TO BLOB(<>OTR_Pictures_apic{$slot_i}; $tempBlob_blob; ".png")
						BASE64 ENCODE($tempBlob_blob)
						OB SET($expanded_o; $thisKey_t; "var:picture:b64pic:.png:"+Convert to text($tempBlob_blob; "US-ASCII"))
					End if 
					
			End case 
			
		: (OB Get type($expanded_o; $thisKey_t)=Is object)
			$nested_o:=OB Get($expanded_o; $thisKey_t; Is object)
			OB SET($expanded_o; $thisKey_t; OTr_uExpandBinaries($nested_o))
			
	End case 
	
End for each 
