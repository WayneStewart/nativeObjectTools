//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_XMLWriteObjectSAX ($docRef_t : Time; $obj_o : Object; $includeShadow_b : Boolean)

// Private recursive helper for OT SaveToXMLSAX and OT SaveToXMLFileSAX.
// Walks $obj_o and writes one <item> element per property to the open
// SAX document referenced by $docRef_t.  Descends recursively into
// embedded objects and OTr array containers.
//
// The XML schema produced is identical to that of OTr_z_XMLWriteObject
// (the DOM equivalent), so files written by either approach are fully
// interchangeable and can be read by OT LoadFromXML / OT LoadFromXMLFile.
//
// Each <item> carries:
//   key="<leafKey>"   — property name
//   type="<otType>"   — OT type constant as decimal integer
//   (element body)    — the serialised scalar value, or child elements
//                       for embedded objects and arrays.
//
// BLOBs are emitted as Base64 text.  Pictures are converted to PNG and
// then Base64-encoded.  Date values are emitted in ISO 8601 format
// (YYYY-MM-DD).  Time values are emitted as HH:MM:SS.
//
// Shadow-type keys (leafKey$type) are included or excluded according
// to $includeShadow_b.
//
// SAX produces output directly to the open document file — there is no
// intermediate in-memory tree.  Each call to SAX OPEN XML ELEMENT must
// be matched by a corresponding SAX CLOSE XML ELEMENT at the correct
// depth; this method manages that discipline internally.

// Access: Private

// Parameters:
//   $docRef_t        : Time    : SAX document reference (from Create document)
//   $obj_o           : Object  : Object whose properties to emit
//   $includeShadow_b : Boolean : True to include shadow-type keys

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($docRef_t : Time; $obj_o : Object; $includeShadow_b : Boolean)

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
var $valText_t : Text

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
		
		// Open <item key="K" type="T">
		SAX OPEN XML ELEMENT:C853($docRef_t; "item"; "key"; $key_t; "type"; String:C10($otType_i))
		
		Case of 
				
			: ($nativeType_i=Is real:K8:4)
				SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
					String:C10(OB Get:C1224($obj_o; $key_t; Is real:K8:4)))
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
			: (($nativeType_i=Is longint:K8:6) | ($nativeType_i=Is integer:K8:5))
				SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
					String:C10(OB Get:C1224($obj_o; $key_t; Is longint:K8:6)))
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
			: ($nativeType_i=Is boolean:K8:9)
				SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
					Choose:C955(OB Get:C1224($obj_o; $key_t; Is boolean:K8:9); "true"; "false"))
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
			: ($nativeType_i=Is date:K8:7)
				SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
					String:C10(OB Get:C1224($obj_o; $key_t; Is date:K8:7); ISO date GMT:K1:10))
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
			: ($nativeType_i=Is time:K8:8)
				$secs_i:=OB Get:C1224($obj_o; $key_t; Is time:K8:8)
				SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
					String:C10($secs_i\3600; "00")+":"+\
					String:C10(($secs_i\60)%60; "00")+":"+\
					String:C10($secs_i%60; "00"))
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
			: ($nativeType_i=Is text:K8:3)
				SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
					OB Get:C1224($obj_o; $key_t; Is text:K8:3))
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
			: ($nativeType_i=Is BLOB:K8:12)
				$valBlob_x:=OB Get:C1224($obj_o; $key_t; Is BLOB:K8:12)
				BASE64 ENCODE:C895($valBlob_x)
				SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
					Convert to text:C1012($valBlob_x; "US-ASCII"))
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
			: ($nativeType_i=Is picture:K8:10)
				PICTURE TO BLOB:C692(OB Get:C1224($obj_o; $key_t; Is picture:K8:10); \
					$valBlob_x; ".png")
				BASE64 ENCODE:C895($valBlob_x)
				SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
					Convert to text:C1012($valBlob_x; "US-ASCII"))
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
			: ($nativeType_i=Is object:K8:27)
				$subObj_o:=OB Get:C1224($obj_o; $key_t; Is object:K8:27)
				$arrayType_i:=OTr_z_ArrayType($subObj_o)
				
				If ($arrayType_i=-1)
					
					// Embedded object — open <object>, recurse, close </object>, close </item>
					SAX OPEN XML ELEMENT:C853($docRef_t; "object")
					OTr_z_XMLWriteObjectSAX($docRef_t; $subObj_o; $includeShadow_b)
					SAX CLOSE XML ELEMENT:C854($docRef_t)  // </object>
					SAX CLOSE XML ELEMENT:C854($docRef_t)  // </item>
					
				Else 
					
					// OTr array container — open <array arrayType="N">, write <element> children
					$numElements_i:=OB Get:C1224($subObj_o; "numElements"; Is longint:K8:6)
					
					SAX OPEN XML ELEMENT:C853($docRef_t; "array"; \
						"arrayType"; String:C10($arrayType_i))
					
					$arrIdx_i:=0
					While ($arrIdx_i<$numElements_i)
						$idxKey_t:=String:C10($arrIdx_i)
						SAX OPEN XML ELEMENT:C853($docRef_t; "element"; \
							"index"; $idxKey_t)
						SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
							String:C10(OB Get:C1224($subObj_o; $idxKey_t)))
						SAX CLOSE XML ELEMENT:C854($docRef_t)  // </element>
						$arrIdx_i:=$arrIdx_i+1
					End while 
					
					SAX CLOSE XML ELEMENT:C854($docRef_t)  // </array>
					SAX CLOSE XML ELEMENT:C854($docRef_t)  // </item>
					
				End if 
				
			: ($nativeType_i=Is collection:K8:32)
				// Native 4D collection — serialise inline as JSON
				SAX ADD XML ELEMENT VALUE:C855($docRef_t; \
					JSON Stringify:C1217(OB Get:C1224($obj_o; $key_t; Is collection:K8:32)))
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
			Else 
				// Unhandled type — emit empty element body
				SAX CLOSE XML ELEMENT:C854($docRef_t)
				
		End case 
		
	End if   // Not($skipKey_b)
	
End for each 
