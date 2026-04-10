//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_zXMLWriteObject ($domParent_t : Text; $obj_o : Object; $includeShadow_b : Boolean)

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

$keys_c:=OB Keys($obj_o)

For each ($key_t; $keys_c)

	// Decide whether to skip this key
	$skipKey_b:=False
	If (Substring($key_t; 1; 7)="__otr_")
		$skipKey_b:=True
	End if
	If (Not($includeShadow_b) & OTr_zIsShadowKey($key_t))
		$skipKey_b:=True
	End if

	If (Not($skipKey_b))

		$nativeType_i:=OB Get type($obj_o; $key_t)
		$otType_i:=OTr_zMapType($obj_o; $key_t)

		// Create <item key="K" type="T">
		$itemRef_t:=DOM Create XML element($domParent_t; "item"; \
			"key"; $key_t; \
			"type"; String($otType_i))

		Case of

			: ($nativeType_i=Is real)
				DOM SET XML ELEMENT VALUE($itemRef_t; \
					String(OB Get($obj_o; $key_t; Is real)))

			: (($nativeType_i=Is longint) | ($nativeType_i=Is integer))
				DOM SET XML ELEMENT VALUE($itemRef_t; \
					String(OB Get($obj_o; $key_t; Is longint)))

			: ($nativeType_i=Is Boolean)
				DOM SET XML ELEMENT VALUE($itemRef_t; \
					Choose(OB Get($obj_o; $key_t; Is boolean); "true"; "false"))

			: ($nativeType_i=Is date)
				DOM SET XML ELEMENT VALUE($itemRef_t; \
					String(OB Get($obj_o; $key_t; Is date); ISO Date GMT))

			: ($nativeType_i=Is time)
				$secs_i:=OB Get($obj_o; $key_t; Is time)
				DOM SET XML ELEMENT VALUE($itemRef_t; \
					String($secs_i\3600; "00")+":"+\
					String(($secs_i\60) % 60; "00")+":"+\
					String($secs_i % 60; "00"))

			: ($nativeType_i=Is text)
				DOM SET XML ELEMENT VALUE($itemRef_t; \
					OB Get($obj_o; $key_t; Is text))

			: ($nativeType_i=Is BLOB)
				$valBlob_x:=OB Get($obj_o; $key_t; Is BLOB)
				BASE64 ENCODE($valBlob_x)
				DOM SET XML ELEMENT VALUE($itemRef_t; \
					Convert to text($valBlob_x; "US-ASCII"))

			: ($nativeType_i=Is picture)
				PICTURE TO BLOB(OB Get($obj_o; $key_t; Is picture); \
					$valBlob_x; ".png")
				BASE64 ENCODE($valBlob_x)
				DOM SET XML ELEMENT VALUE($itemRef_t; \
					Convert to text($valBlob_x; "US-ASCII"))

			: ($nativeType_i=Is object)
				$subObj_o:=OB Get($obj_o; $key_t; Is object)
				$arrayType_i:=OTr_zArrayType($subObj_o)

				If ($arrayType_i=-1)

					// Embedded object — create <object> child and recurse
					$objRef_t:=DOM Create XML element($itemRef_t; "object")
					OTr_zXMLWriteObject($objRef_t; $subObj_o; $includeShadow_b)

				Else

					// OTr array container — create <array arrayType="N"> with <element> children
					$numElements_i:=OB Get($subObj_o; "numElements"; Is longint)
					$arrayRef_t:=DOM Create XML element($itemRef_t; "array"; \
						"arrayType"; String($arrayType_i))

					$arrIdx_i:=0
					While ($arrIdx_i < $numElements_i)
						$idxKey_t:=String($arrIdx_i)
						$elemRef_t:=DOM Create XML element($arrayRef_t; "element"; \
							"index"; $idxKey_t)
						DOM SET XML ELEMENT VALUE($elemRef_t; \
							String(OB Get($subObj_o; $idxKey_t)))
						$arrIdx_i:=$arrIdx_i+1
					End while

				End if

			: ($nativeType_i=Is collection)
				// Native 4D collection — serialise inline as JSON
				DOM SET XML ELEMENT VALUE($itemRef_t; \
					JSON Stringify(OB Get($obj_o; $key_t; Is collection)))

		End case

	End if  // Not($skipKey_b)

End for each
