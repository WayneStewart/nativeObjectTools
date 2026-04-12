//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zXMLReadObject ($elemRef_t : Text) --> Object

// Private recursive helper for OTr_LoadFromXML and OTr_LoadFromXMLFile.
// Walks the child <item> elements of $elemRef_t (which points to an
// <OTrObject> or <object> DOM node) and reconstructs the 4D object
// that was written by OTr_zXMLWriteObject.
//
// Each <item key="K" type="T"> element carries:
//   key  — the leaf property name
//   type — the OT type constant (decimal integer)
//   body — the serialised value (may be absent for embedded objects)
//
// Type reconstruction:
//   Is real:K8:4          — String→Num
//   Is picture:K8:10      — Base64 body → BLOB → Picture
//   Is date:K8:7          — ISO 8601 string → Date
//   Is longint:K8:6       — String→Num
//   Is Boolean:K8:9       — "true"/"false" → Boolean
//   Is time:K8:8          — HH:MM:SS body → Time
//   Is pointer:K8:14      — plain text body; shadow key restored
//   Is BLOB:K8:12         — Base64 body → BLOB; native or shadow
//     (native if Storage.OTr.nativeBlobInObject, else text+shadow)
//   OT Is Character (112) — body as-is
//   OT Character array (113) — <array> child reconstructed
//   OT Is Object (114)    — <object> child, recursive call
//   All other array types — <array> child reconstructed

// Access: Private

// Parameters:
//   $elemRef_t : Text : DOM element reference of <OTrObject> or <object>

// Returns:
//   $result_o : Object : Reconstructed 4D object

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($elemRef_t : Text)->$result_o : Object

var $itemRef_t : Text
var $arrayRef_t : Text
var $elemChildRef_t : Text
var $objectChildRef_t : Text
var $key_t : Text
var $otType_i : Integer
var $body_t : Text
var $idxKey_t : Text
var $numElements_i : Integer
var $idx_i : Integer
var $arrayType_i : Integer
var $valReal_r : Real
var $valLong_i : Integer
var $valBool_b : Boolean
var $valDate_d : Date
var $valBlob_x : Blob
var $subObj_o : Object
var $attrValue_t : Text
var $attrName_t : Text
var $errSave_t : Text
var $hh_i; $mm_i; $ss_i : Integer

$result_o:=New object:C1471

// Walk child <item> elements
$itemRef_t:=DOM Get first child XML element:C723($elemRef_t; $attrName_t; $attrValue_t)

While ($itemRef_t#"")
	
	// Read key attribute
	DOM GET XML ATTRIBUTE BY NAME:C728($itemRef_t; "key"; $key_t)
	
	// Read type attribute
	DOM GET XML ATTRIBUTE BY NAME:C728($itemRef_t; "type"; $attrValue_t)
	$otType_i:=Num:C11($attrValue_t)
	
	// Read element body text
	DOM GET XML ELEMENT VALUE:C731($itemRef_t; $body_t)
	
	Case of 
			
		: ($otType_i=Is real:K8:4)
			OB SET:C1220($result_o; $key_t; Num:C11($body_t))
			OB SET:C1220($result_o; OTr_zShadowKey($key_t); Is real:K8:4)
			
		: ($otType_i=Is longint:K8:6)
			OB SET:C1220($result_o; $key_t; Num:C11($body_t))
			OB SET:C1220($result_o; OTr_zShadowKey($key_t); Is longint:K8:6)
			
		: ($otType_i=Is boolean:K8:9)
			OB SET:C1220($result_o; $key_t; ($body_t="true"))
			OB SET:C1220($result_o; OTr_zShadowKey($key_t); Is boolean:K8:9)
			
		: ($otType_i=Is date:K8:7)
			// ISO 8601 body
			$errSave_t:=Method called on error:C704
			ON ERR CALL:C155("OTr_zErrIgnore")
			$valDate_d:=Date:C102($body_t)
			ON ERR CALL:C155($errSave_t)
			OB SET:C1220($result_o; $key_t; $valDate_d)
			OB SET:C1220($result_o; OTr_zShadowKey($key_t); Is date:K8:7)
			
		: ($otType_i=Is time:K8:8)
			// HH:MM:SS body
			$hh_i:=Num:C11(Substring:C12($body_t; 1; 2))
			$mm_i:=Num:C11(Substring:C12($body_t; 4; 2))
			$ss_i:=Num:C11(Substring:C12($body_t; 7; 2))
			OB SET:C1220($result_o; $key_t; ?00:00:00?+($hh_i*3600+$mm_i*60+$ss_i))
			OB SET:C1220($result_o; OTr_zShadowKey($key_t); Is time:K8:8)
			
		: ($otType_i=OT Is Character)
			// Text — body as-is
			OB SET:C1220($result_o; $key_t; $body_t)
			OB SET:C1220($result_o; OTr_zShadowKey($key_t); OT Is Character)
			
		: ($otType_i=Is pointer:K8:14)
			// Body is the text-encoded pointer; restore shadow key
			OB SET:C1220($result_o; $key_t; $body_t)
			OB SET:C1220($result_o; OTr_zShadowKey($key_t); Is pointer:K8:14)
			
		: ($otType_i=Is BLOB:K8:12)
			// Base64 body; storage path depends on version flag
			CONVERT FROM TEXT:C1011($body_t; "US-ASCII"; $valBlob_x)
			BASE64 DECODE:C896($valBlob_x)
			If (Storage:C1525.OTr.nativeBlobInObject)
				OB SET:C1220($result_o; $key_t; $valBlob_x)
				OB SET:C1220($result_o; OTr_zShadowKey($key_t); Is BLOB:K8:12)
			Else 
				// Re-encode as text for pre-v19 R2 storage and restore shadow
				BASE64 ENCODE:C895($valBlob_x)
				OB SET:C1220($result_o; $key_t; Convert to text:C1012($valBlob_x; "US-ASCII"))
				OB SET:C1220($result_o; OTr_zShadowKey($key_t); Is BLOB:K8:12)
			End if 
			
		: ($otType_i=Is picture:K8:10)
			// Base64 PNG body
			CONVERT FROM TEXT:C1011($body_t; "US-ASCII"; $valBlob_x)
			BASE64 DECODE:C896($valBlob_x)
			BLOB TO PICTURE:C682($valBlob_x; $result_o[$key_t])
			OB SET:C1220($result_o; OTr_zShadowKey($key_t); Is picture:K8:10)
			
		: ($otType_i=OT Is Object)
			// Find the <object> child and recurse
			$objectChildRef_t:=DOM Find XML element:C864($itemRef_t; "object")
			If ($objectChildRef_t#"")
				$subObj_o:=OTr_zXMLReadObject($objectChildRef_t)
				OB SET:C1220($result_o; $key_t; $subObj_o)
			Else 
				OB SET:C1220($result_o; $key_t; New object:C1471)
			End if 
			OB SET:C1220($result_o; OTr_zShadowKey($key_t); OT Is Object)
			
		Else 
			// OTr array types — find the <array> child
			$arrayRef_t:=DOM Find XML element:C864($itemRef_t; "array")
			If ($arrayRef_t#"")
				
				DOM GET XML ATTRIBUTE BY NAME:C728($arrayRef_t; "arrayType"; $attrValue_t)
				$arrayType_i:=Num:C11($attrValue_t)
				
				$subObj_o:=New object:C1471("arrayType"; $arrayType_i; \
					"numElements"; 0; "currentItem"; 0)
				
				// Walk <element> children
				$elemChildRef_t:=DOM Get first child XML element:C723($arrayRef_t; \
					$attrName_t; $attrValue_t)
				$numElements_i:=0
				
				While ($elemChildRef_t#"")
					DOM GET XML ATTRIBUTE BY NAME:C728($elemChildRef_t; "index"; $idxKey_t)
					DOM GET XML ELEMENT VALUE:C731($elemChildRef_t; $attrValue_t)
					OB SET:C1220($subObj_o; $idxKey_t; $attrValue_t)
					$numElements_i:=$numElements_i+1
					$elemChildRef_t:=DOM Get next sibling XML element:C724($elemChildRef_t; \
						$attrName_t; $attrValue_t)
				End while 
				
				OB SET:C1220($subObj_o; "numElements"; $numElements_i)
				OB SET:C1220($result_o; $key_t; $subObj_o)
				
			End if 
			
	End case 
	
	// Advance to next <item> sibling
	$itemRef_t:=DOM Get next sibling XML element:C724($itemRef_t; $attrName_t; $attrValue_t)
	
End while 
