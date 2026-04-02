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
// ----------------------------------------------------

#DECLARE($parent_o : Object; $key_t : Text)->$otType_i : Integer

var $nativeType_i : Integer
var $textVal_t : Text

$otType_i:=0
$nativeType_i:=OB Get type($parent_o; $key_t)

Case of

	: ($nativeType_i=Is real)
		$otType_i:=1  // OT Real

	: (($nativeType_i=Is longint) | ($nativeType_i=Is integer))
		$otType_i:=5  // OT Longint

	: ($nativeType_i=Is Boolean)
		$otType_i:=6  // OT Boolean

	: ($nativeType_i=Is object)
		$otType_i:=114  // OT Object

	: ($nativeType_i=Is collection)
		$otType_i:=113  // OT Array Character

	: ($nativeType_i=Is text)
		$textVal_t:=OB Get($parent_o; $key_t; Is text)

		Case of

			: (Substring($textVal_t; 1; 5)="blob:")
				$otType_i:=30   // OT BLOB

			: (Substring($textVal_t; 1; 4)="pic:")
				$otType_i:=3    // OT Picture

			: (Substring($textVal_t; 1; 4)="ptr:")
				$otType_i:=23   // OT Pointer

			: (Substring($textVal_t; 1; 4)="rec:")
				$otType_i:=115  // OT Record

			: (Substring($textVal_t; 1; 4)="var:")
				$otType_i:=24   // OT Variable

			Else
				// Check for encoded date: YYYY-MM-DD (length 10)
				If ((Length($textVal_t)=10) \
					& (Substring($textVal_t; 5; 1)="-") \
					& (Substring($textVal_t; 8; 1)="-"))
					$otType_i:=4  // OT Date

				Else
					// Check for encoded time: HH:MM:SS (length 8)
					If ((Length($textVal_t)=8) \
						& (Substring($textVal_t; 3; 1)=":") \
						& (Substring($textVal_t; 6; 1)=":"))
						$otType_i:=11  // OT Time

					Else
						$otType_i:=112  // OT Character

					End if

				End if

		End case

End case
