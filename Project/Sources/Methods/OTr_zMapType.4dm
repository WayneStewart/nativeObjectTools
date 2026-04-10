//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_zMapType ($parent_o : Object; $key_t : Text) \
//   --> $otType_i : Integer

// Returns the OT type constant for a given property on an object.
// Used by OTr_ItemType and property-enumeration routines.

// Access: Private

// Parameters:
//   $parent_o : Object : Object that owns the property to inspect
//   $key_t    : Text   : Property key name

// Returns:
//   $otType_i : Integer : OT type constant, or 0 if type is unrecognised

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-10 - Revised for native-storage architecture.
//   Under the new storage model (see OTr_PutVariable, OTr_GetVariable),
//   every scalar type that 4D's object model represents natively
//   (LongInt, Integer, Real, Text, Boolean, Picture, Date, Time, and
//   BLOB under Storage.OTr.nativeBlobInObject) is stored via a direct
//   OB SET. Pointer values, and BLOBs on pre-v19 R2, are stored as
//   plain text and accompanied by a sibling shadow-type key
//   (leafKey$type — see OTr_zShadowKey) that records the original OT
//   type constant. The legacy "blob:" / "pic:" / "ptr:" / "rec:" /
//   "var:" sentinel prefix scheme has been retired.
//
//   Array sub-objects carry their element type as a first-class
//   "arrayType" property (see OTr_PutArray) and are detected by
//   descending into Is object properties via OTr_zArrayType.
// ----------------------------------------------------

#DECLARE($parent_o : Object; $key_t : Text)->$otType_i : Integer

var $nativeType_i; $arrayType_i; $shadow_i : Integer
var $subObj_o : Object

$otType_i:=0
$nativeType_i:=OB Get type($parent_o; $key_t)

Case of

	: ($nativeType_i=Is real)
		$otType_i:=1  // OT Real

	: (($nativeType_i=Is longint) | ($nativeType_i=Is integer))
		$otType_i:=5  // OT Longint

	: ($nativeType_i=Is Boolean)
		$otType_i:=6  // OT Boolean

	: ($nativeType_i=Is date)
		$otType_i:=4  // OT Date

	: ($nativeType_i=Is time)
		$otType_i:=11  // OT Time

	: ($nativeType_i=Is picture)
		$otType_i:=3  // OT Picture

	: ($nativeType_i=Is BLOB)
		$otType_i:=30  // OT BLOB

	: ($nativeType_i=Is collection)
		$otType_i:=113  // OT Array Character

	: ($nativeType_i=Is object)
		// The sub-object may be an OTr array container (which
		// carries its 4D arrayType as a first-class property) or
		// a user-supplied object. Descend and inspect.
		$subObj_o:=OB Get($parent_o; $key_t; Is object)
		$arrayType_i:=OTr_zArrayType($subObj_o)
		If ($arrayType_i=-1)
			$otType_i:=114  // OT Object
		Else
			// Map the stored 4D array-type constant to the OT
			// array-type constant via OTr_uMapType (4D -> OT).
			$otType_i:=OTr_uMapType($arrayType_i; 0)
			If ($otType_i=0)
				// Unknown array type — report as generic object
				$otType_i:=114  // OT Object
			End if
		End if

	: ($nativeType_i=Is text)
		// A text property is either (a) a genuine user string, or
		// (b) an encoded Pointer / BLOB accompanied by a shadow-type
		// key that records the original OT type. Consult the shadow
		// first; if absent, the value is ordinary text.
		If (OB Is defined($parent_o; OTr_zShadowKey($key_t)))
			$shadow_i:=OB Get($parent_o; OTr_zShadowKey($key_t); Is longint)
			If ($shadow_i#0)
				$otType_i:=$shadow_i
			Else
				$otType_i:=112  // OT Character
			End if
		Else
			$otType_i:=112  // OT Character
		End if

End case
