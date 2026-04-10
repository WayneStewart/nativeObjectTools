//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_zXMLWriteObjectSAX ($docRef_t : Time; $obj_o : Object; $includeShadow_b : Boolean)

// Private recursive helper for OTr_SaveToXMLSAX and OTr_SaveToXMLFileSAX.
// Walks $obj_o and writes one <item> element per property to the open
// SAX document referenced by $docRef_t.  Descends recursively into
// embedded objects and OTr array containers.
//
// The XML schema produced is identical to that of OTr_zXMLWriteObject
// (the DOM equivalent), so files written by either approach are fully
// interchangeable and can be read by OTr_LoadFromXML / OTr_LoadFromXMLFile.
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

		// Open <item key="K" type="T">
		SAX OPEN XML ELEMENT($docRef_t; "item"; "key"; $key_t; "type"; String($otType_i))

		Case of

			: ($nativeType_i=Is real)
				SAX ADD XML ELEMENT VALUE($docRef_t; \
					String(OB Get($obj_o; $key_t; Is real)))
				SAX CLOSE XML ELEMENT($docRef_t)

			: (($nativeType_i=Is longint) | ($nativeType_i=Is integer))
				SAX ADD XML ELEMENT VALUE($docRef_t; \
					String(OB Get($obj_o; $key_t; Is longint)))
				SAX CLOSE XML ELEMENT($docRef_t)

			: ($nativeType_i=Is Boolean)
				SAX ADD XML ELEMENT VALUE($docRef_t; \
					Choose(OB Get($obj_o; $key_t; Is boolean); "true"; "false"))
				SAX CLOSE XML ELEMENT($docRef_t)

			: ($nativeType_i=Is date)
				SAX ADD XML ELEMENT VALUE($docRef_t; \
					String(OB Get($obj_o; $key_t; Is date); ISO Date GMT))
				SAX CLOSE XML ELEMENT($docRef_t)

			: ($nativeType_i=Is time)
				$secs_i:=OB Get($obj_o; $key_t; Is time)
				SAX ADD XML ELEMENT VALUE($docRef_t; \
					String($secs_i\3600; "00")+":"+\
					String(($secs_i\60) % 60; "00")+":"+\
					String($secs_i % 60; "00"))
				SAX CLOSE XML ELEMENT($docRef_t)

			: ($nativeType_i=Is text)
				SAX ADD XML ELEMENT VALUE($docRef_t; \
					OB Get($obj_o; $key_t; Is text))
				SAX CLOSE XML ELEMENT($docRef_t)

			: ($nativeType_i=Is BLOB)
				$valBlob_x:=OB Get($obj_o; $key_t; Is BLOB)
				BASE64 ENCODE($valBlob_x)
				SAX ADD XML ELEMENT VALUE($docRef_t; \
					Convert to text($valBlob_x; "US-ASCII"))
				SAX CLOSE XML ELEMENT($docRef_t)

			: ($nativeType_i=Is picture)
				PICTURE TO BLOB(OB Get($obj_o; $key_t; Is picture); \
					$valBlob_x; ".png")
				BASE64 ENCODE($valBlob_x)
				SAX ADD XML ELEMENT VALUE($docRef_t; \
					Convert to text($valBlob_x; "US-ASCII"))
				SAX CLOSE XML ELEMENT($docRef_t)

			: ($nativeType_i=Is object)
				$subObj_o:=OB Get($obj_o; $key_t; Is object)
				$arrayType_i:=OTr_zArrayType($subObj_o)

				If ($arrayType_i=-1)

					// Embedded object — open <object>, recurse, close </object>, close </item>
					SAX OPEN XML ELEMENT($docRef_t; "object")
					OTr_zXMLWriteObjectSAX($docRef_t; $subObj_o; $includeShadow_b)
					SAX CLOSE XML ELEMENT($docRef_t)  // </object>
					SAX CLOSE XML ELEMENT($docRef_t)  // </item>

				Else

					// OTr array container — open <array arrayType="N">, write <element> children
					$numElements_i:=OB Get($subObj_o; "numElements"; Is longint)

					SAX OPEN XML ELEMENT($docRef_t; "array"; \
						"arrayType"; String($arrayType_i))

					$arrIdx_i:=0
					While ($arrIdx_i < $numElements_i)
						$idxKey_t:=String($arrIdx_i)
						SAX OPEN XML ELEMENT($docRef_t; "element"; \
							"index"; $idxKey_t)
						SAX ADD XML ELEMENT VALUE($docRef_t; \
							String(OB Get($subObj_o; $idxKey_t)))
						SAX CLOSE XML ELEMENT($docRef_t)  // </element>
						$arrIdx_i:=$arrIdx_i+1
					End while

					SAX CLOSE XML ELEMENT($docRef_t)  // </array>
					SAX CLOSE XML ELEMENT($docRef_t)  // </item>

				End if

			: ($nativeType_i=Is collection)
				// Native 4D collection — serialise inline as JSON
				SAX ADD XML ELEMENT VALUE($docRef_t; \
					JSON Stringify(OB Get($obj_o; $key_t; Is collection)))
				SAX CLOSE XML ELEMENT($docRef_t)

			Else
				// Unhandled type — emit empty element body
				SAX CLOSE XML ELEMENT($docRef_t)

		End case

	End if  // Not($skipKey_b)

End for each
