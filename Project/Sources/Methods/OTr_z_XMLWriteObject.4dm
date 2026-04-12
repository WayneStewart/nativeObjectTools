//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_XMLWriteObject ($domParent_t : Text; $obj_o : Object; $includeShadow_b : Boolean)

// Private recursive helper for OTr_SaveToXML and OTr_SaveToXMLFile.
// Walks $obj_o and appends one <item> child element per property to
// the DOM element referenced by $domParent_t.  Descends recursively
// into embedded objects and OTr array containers.
//
// Each <item> carries:
//   key="<leafKey>"   — property name
//   type="<otType>"   — OT type constant as decimal integer
//   (element body)    — the serialised scalar value, or child elements
//                       for embedded objects and arrays.
//
// BLOBs are emitted as Base64 text.  Pictures are converted to PNG
// and then Base64-encoded.  Date values are emitted in ISO 8601 format
// (YYYY-MM-DD).  Time values are emitted as HH:MM:SS.
//
// Shadow-type keys (leafKey$type) are included or excluded according
// to $includeShadow_b.
//
// Pretty-printing is handled automatically by DOM EXPORT TO VAR / FILE.

// Access: Private

// Parameters:
//   $domParent_t     : Text    : DOM reference of the parent element
//   $obj_o           : Object  : Object whose properties to emit
//   $includeShadow_b : Boolean : True to include shadow-type keys

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($domParent_t : Text; $obj_o : Object; $includeShadow_b : Boolean)

var $keys_c : Collection
var $key_t : Text
var $nativeType_i : Integer
var $otType_i : Integer
var $arrayType_i : Integer
var $numElements_i : Integer
var $subObj_o : Object
var $arrIdx_i : Integer
var $idxKey_t : Text
var $valBlob_x : Blob
var $secs_i : Integer
var $skipKey_b : Boolean
var $itemRef_t : Text
var $objRef_t : Text
var $arrayRef_t : Text
var $elemRef_t : Text

$keys_c:=OB Keys:C1719($obj_o)

For each ($key_t; $keys_c)
	
	// Decide whether to skip this key
	$skipKey_b:=False:C215
	If (Substring:C12($key_t; 1; 7)="__otr_")
		$skipKey_b:=True:C214
	End if 
	If (Not:C34($includeShadow_b) & OTr_z_IsShadowKey($key_t))
		$skipKey_b:=True:C214
	End if 
	
	If (Not:C34($skipKey_b))
		
		$nativeType_i:=OB Get type:C1230($obj_o; $key_t)
		$otType_i:=OTr_z_MapType($obj_o; $key_t)
		
		// Create <item key="K" type="T">
		$itemRef_t:=DOM Create XML element:C865($domParent_t; "item"; \
			"key"; $key_t; \
			"type"; String:C10($otType_i))
		
		Case of 
				
			: ($nativeType_i=Is real:K8:4)
				DOM SET XML ELEMENT VALUE:C868($itemRef_t; \
					String:C10(OB Get:C1224($obj_o; $key_t; Is real:K8:4)))
				
			: (($nativeType_i=Is longint:K8:6) | ($nativeType_i=Is integer:K8:5))
				DOM SET XML ELEMENT VALUE:C868($itemRef_t; \
					String:C10(OB Get:C1224($obj_o; $key_t; Is longint:K8:6)))
				
			: ($nativeType_i=Is boolean:K8:9)
				DOM SET XML ELEMENT VALUE:C868($itemRef_t; \
					Choose:C955(OB Get:C1224($obj_o; $key_t; Is boolean:K8:9); "true"; "false"))
				
			: ($nativeType_i=Is date:K8:7)
				DOM SET XML ELEMENT VALUE:C868($itemRef_t; \
					String:C10(OB Get:C1224($obj_o; $key_t; Is date:K8:7); ISO date GMT:K1:10))
				
			: ($nativeType_i=Is time:K8:8)
				$secs_i:=OB Get:C1224($obj_o; $key_t; Is time:K8:8)
				DOM SET XML ELEMENT VALUE:C868($itemRef_t; \
					String:C10($secs_i\3600; "00")+":"+\
					String:C10(($secs_i\60)%60; "00")+":"+\
					String:C10($secs_i%60; "00"))
				
			: ($nativeType_i=Is text:K8:3)
				DOM SET XML ELEMENT VALUE:C868($itemRef_t; \
					OB Get:C1224($obj_o; $key_t; Is text:K8:3))
				
			: ($nativeType_i=Is BLOB:K8:12)
				$valBlob_x:=OB Get:C1224($obj_o; $key_t; Is BLOB:K8:12)
				BASE64 ENCODE:C895($valBlob_x)
				DOM SET XML ELEMENT VALUE:C868($itemRef_t; \
					Convert to text:C1012($valBlob_x; "US-ASCII"))
				
			: ($nativeType_i=Is picture:K8:10)
				PICTURE TO BLOB:C692(OB Get:C1224($obj_o; $key_t; Is picture:K8:10); \
					$valBlob_x; ".png")
				BASE64 ENCODE:C895($valBlob_x)
				DOM SET XML ELEMENT VALUE:C868($itemRef_t; \
					Convert to text:C1012($valBlob_x; "US-ASCII"))
				
			: ($nativeType_i=Is object:K8:27)
				$subObj_o:=OB Get:C1224($obj_o; $key_t; Is object:K8:27)
				$arrayType_i:=OTr_z_ArrayType($subObj_o)
				
				If ($arrayType_i=-1)
					
					// Embedded object — create <object> child and recurse
					$objRef_t:=DOM Create XML element:C865($itemRef_t; "object")
					OTr_z_XMLWriteObject($objRef_t; $subObj_o; $includeShadow_b)
					
				Else 
					
					// OTr array container — create <array arrayType="N"> with <element> children
					$numElements_i:=OB Get:C1224($subObj_o; "numElements"; Is longint:K8:6)
					$arrayRef_t:=DOM Create XML element:C865($itemRef_t; "array"; \
						"arrayType"; String:C10($arrayType_i))
					
					$arrIdx_i:=0
					While ($arrIdx_i<$numElements_i)
						$idxKey_t:=String:C10($arrIdx_i)
						$elemRef_t:=DOM Create XML element:C865($arrayRef_t; "element"; \
							"index"; $idxKey_t)
						DOM SET XML ELEMENT VALUE:C868($elemRef_t; \
							String:C10(OB Get:C1224($subObj_o; $idxKey_t)))
						$arrIdx_i:=$arrIdx_i+1
					End while 
					
				End if 
				
			: ($nativeType_i=Is collection:K8:32)
				// Native 4D collection — serialise inline as JSON
				DOM SET XML ELEMENT VALUE:C868($itemRef_t; \
					JSON Stringify:C1217(OB Get:C1224($obj_o; $key_t; Is collection:K8:32)))
				
		End case 
		
	End if   // Not($skipKey_b)
	
End for each 
