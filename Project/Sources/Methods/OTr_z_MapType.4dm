//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_MapType ($parent_o : Object; $key_t : Text) \
//   --> $otType_i : Integer

// Returns the OT type constant for a given property on an object.
// Used by OT ItemType and property-enumeration routines.

// Access: Private

// Parameters:
//   $parent_o : Object : Object that owns the property to inspect
//   $key_t    : Text   : Property key name

// Returns:
//   $otType_i : Integer : OT type constant, or 0 if type is unrecognised

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-10 - Revised for native-storage architecture.
//   Under the new storage model (see OT PutVariable, OT GetVariable),
//   every scalar type that 4D's object model represents natively
//   (LongInt, Integer, Real, Text, Boolean, Picture, Date, Time, and
//   BLOB under Storage.OTr.nativeBlobInObject) is stored via a direct
//   OB SET. Pointer values, and BLOBs on pre-v19 R2, are stored as
//   plain text and accompanied by a sibling shadow-type key
//   (leafKey$type — see OTr_z_ShadowKey) that records the original OT
//   type constant. The legacy "blob:" / "pic:" / "ptr:" / "rec:" /
//   "var:" sentinel prefix scheme has been retired.
//
//   Array sub-objects carry their element type as a first-class
//   "arrayType" property (see OT PutArray) and are detected by
//   descending into Is object properties via OTr_z_ArrayType.
// Wayne Stewart, 2026-04-12 - Is object case extended to check shadow key first.
//   OB Get type reports Is object (38) for Picture and BLOB properties in 4D
//   v19-v21; the shadow key written by OT PutPicture / OT PutBLOB is consulted
//   before descending into array/object detection.
// Wayne Stewart, 2026-04-12 - Full shadow-key-primary architecture. All Put methods
//   now write a shadow key (leafKey$type) for every type. OTr_z_MapType therefore
//   checks the shadow key as the first and authoritative source of type identity,
//   and only falls back to OB Get type when no shadow key is present (legacy objects
//   or objects populated by means other than OTr Put methods). This makes the entire
//   type system independent of OB Get type unreliability across 4D v19-v21.
// ----------------------------------------------------

#DECLARE($parent_o : Object; $key_t : Text)->$otType_i : Integer

var $nativeType_i; $arrayType_i; $shadow_i : Integer
var $subObj_o : Object

$otType_i:=0

// ----------------------------------------------------------------
// Phase 1 — shadow key (authoritative, version-independent).
// Every Put method writes leafKey$type; if it is present, trust it.
// ----------------------------------------------------------------
If (OB Is defined:C1231($parent_o; OTr_z_ShadowKey($key_t)))
	$shadow_i:=OB Get:C1224($parent_o; OTr_z_ShadowKey($key_t); Is longint:K8:6)
	If ($shadow_i#0)
		$otType_i:=$shadow_i
		// Return immediately — shadow key is definitive.
		// (No exit keyword; $otType_i is already set; the Case of below
		//  is skipped because the outer If is the only branch.)
	Else 
		// Shadow key exists but is 0 — treat as absent; fall through
		// to native-type detection.
		$otType_i:=0
	End if 
End if 

If ($otType_i=0)
	// ----------------------------------------------------------------
	// Phase 2 — native OB Get type fallback.
	// Used for legacy objects or properties written outside OTr.
	// ----------------------------------------------------------------
	$nativeType_i:=OB Get type:C1230($parent_o; $key_t)
	
	Case of 
			
		: ($nativeType_i=Is real:K8:4)
			$otType_i:=Is real:K8:4  // default; cannot distinguish from Is longint without shadow key
			
		: (($nativeType_i=Is longint:K8:6) | ($nativeType_i=Is integer:K8:5))
			$otType_i:=Is longint:K8:6
			
		: ($nativeType_i=Is boolean:K8:9)
			$otType_i:=Is boolean:K8:9
			
		: ($nativeType_i=Is date:K8:7)
			$otType_i:=Is date:K8:7
			
		: ($nativeType_i=Is time:K8:8)
			$otType_i:=Is time:K8:8
			
		: ($nativeType_i=Is picture:K8:10)
			$otType_i:=Is picture:K8:10
			
		: ($nativeType_i=Is BLOB:K8:12)
			$otType_i:=Is BLOB:K8:12
			
		: ($nativeType_i=Is collection:K8:32)
			$otType_i:=OT Character array
			
		: ($nativeType_i=Is object:K8:27)
			// May be a Picture or BLOB misreported by 4D v19-v21 (shadow key
			// would have caught that above). Descend to detect OTr array containers.
			$subObj_o:=OB Get:C1224($parent_o; $key_t; Is object:K8:27)
			$arrayType_i:=OTr_z_ArrayType($subObj_o)
			If ($arrayType_i=-1)
				$otType_i:=OT Is Object
			Else 
				// Map the stored 4D array-type constant to the OT
				// array-type constant via OTr_u_MapType (4D -> OT).
				$otType_i:=OTr_u_MapType($arrayType_i; 0)
				If ($otType_i=0)
					// Unknown array type — report as generic object
					$otType_i:=OT Is Object
				End if 
			End if 
			
		: ($nativeType_i=Is text:K8:3)
			// A text property without a shadow key is an ordinary user string.
			$otType_i:=OT Is Character
			
	End case 
End if 
