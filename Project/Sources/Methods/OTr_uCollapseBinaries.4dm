//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_uCollapseBinaries ($obj_o) -> $collapsed_o

// Walks all properties of $obj_o, recursing into nested
// sub-objects, and replaces self-contained Base64 strings
// with inline binary references into the parallel arrays.
// This is the inverse of OTr_uExpandBinaries.
//
// Conversions performed:
//   "b64blob:<data>"             -> "blob:N"
//   "b64pic:<codec>:<data>"      -> "pic:N"
//   "var:blob:b64blob:<data>"    -> "var:blob:blob:N"
//   "var:picture:b64pic:<codec>:<data>" -> "var:picture:pic:N"
//
// Returns a deep copy of $obj_o with all Base64 strings
// collapsed. The input object is not modified.
// Must be called within the registry lock.

// **ORIGINAL DOCUMENTATION**
// 
// Utility method used by the OTr import pipeline.
// Not part of the public API.

// Access: Private

// Parameters:
//   $obj_o          : Object : Parsed JSON object with expanded Base64 strings
//   Function result : Object : Object with all Base64 strings replaced by binary refs

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($obj_o : Object) -> $collapsed_o : Object

var $keys_c : Collection
var $thisKey_t : Text
var $val_t : Text
var $innerVal_t : Text
var $codec_t : Text
var $base64_t : Text
var $sep1_i : Integer
var $sep2_i : Integer
var $tempBlob_blob : Blob
var $tempPic_pic : Picture
var $nested_o : Object

$collapsed_o:=OB Copy:C1225($obj_o)
$keys_c:=OB Keys:C1719($collapsed_o)

For each ($thisKey_t; $keys_c)
	
	Case of 
			
		: (OB Get type:C1230($collapsed_o; $thisKey_t)=Is text:K8:3)
			$val_t:=OB Get:C1224($collapsed_o; $thisKey_t; Is text:K8:3)
			
			Case of 
					
				: (Substring:C12($val_t; 1; 8)="b64blob:")
					// Decode Base64 BLOB and allocate a binary ref slot
					$base64_t:=Substring:C12($val_t; 9)
					CONVERT FROM TEXT:C1011($base64_t; "US-ASCII"; $tempBlob_blob)
					BASE64 DECODE:C896($tempBlob_blob)
					OB SET:C1220($collapsed_o; $thisKey_t; OTr_uBlobToText($tempBlob_blob))
					
				: (Substring:C12($val_t; 1; 7)="b64pic:")
					// Extract codec from "b64pic:<codec>:<base64data>"
					$innerVal_t:=Substring:C12($val_t; 8)
					$sep1_i:=Position:C15(":"; $innerVal_t)
					$codec_t:=Substring:C12($innerVal_t; 1; $sep1_i-1)
					$base64_t:=Substring:C12($innerVal_t; $sep1_i+1)
					CONVERT FROM TEXT:C1011($base64_t; "US-ASCII"; $tempBlob_blob)
					BASE64 DECODE:C896($tempBlob_blob)
					BLOB TO PICTURE:C682($tempBlob_blob; $tempPic_pic; $codec_t)
					OB SET:C1220($collapsed_o; $thisKey_t; OTr_uPictureToText($tempPic_pic))
					
				: (Substring:C12($val_t; 1; 16)="var:blob:b64blob:")
					// Decode embedded Base64 BLOB in var: string
					$base64_t:=Substring:C12($val_t; 17)
					CONVERT FROM TEXT:C1011($base64_t; "US-ASCII"; $tempBlob_blob)
					BASE64 DECODE:C896($tempBlob_blob)
					OB SET:C1220($collapsed_o; $thisKey_t; "var:blob:"+OTr_uBlobToText($tempBlob_blob))
					
				: (Substring:C12($val_t; 1; 19)="var:picture:b64pic:")
					// Extract codec from "var:picture:b64pic:<codec>:<base64data>"
					$innerVal_t:=Substring:C12($val_t; 20)
					$sep1_i:=Position:C15(":"; $innerVal_t)
					$codec_t:=Substring:C12($innerVal_t; 1; $sep1_i-1)
					$base64_t:=Substring:C12($innerVal_t; $sep1_i+1)
					CONVERT FROM TEXT:C1011($base64_t; "US-ASCII"; $tempBlob_blob)
					BASE64 DECODE:C896($tempBlob_blob)
					BLOB TO PICTURE:C682($tempBlob_blob; $tempPic_pic; $codec_t)
					OB SET:C1220($collapsed_o; $thisKey_t; "var:picture:"+OTr_uPictureToText($tempPic_pic))
					
			End case 
			
		: (OB Get type:C1230($collapsed_o; $thisKey_t)=Is object:K8:27)
			$nested_o:=OB Get:C1224($collapsed_o; $thisKey_t; Is object:K8:27)
			OB SET:C1220($collapsed_o; $thisKey_t; OTr_uCollapseBinaries($nested_o))
			
	End case 
	
End for each 
