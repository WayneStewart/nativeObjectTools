//%attributes = {"invisible":true,"shared":false}
  // ----------------------------------------------------
  // Project Method: OTr_uMapType ($nativeType_i : Integer {; $direction_i : Integer}) --> $result_i : Integer

  // Bidirectional mapping between native 4D type constants
  // and legacy OT plugin type constants.
  // 
  // Direction 0 (default): 4D → OT. Returns the OT type
  // constant that corresponds to the given 4D constant.
  // 
  // Direction 1: OT → 4D. Returns the 4D type constant
  // that corresponds to the given OT constant. OT Record
  // (115) and OT Variable (24) have no direct 4D equivalent
  // and both map to Is text (2).
  // 
  // Returns 0 for any type with no known mapping.
  // 
  // Note: This method handles structural type mapping only.
  // It does not inspect stored values. For value-level
  // discrimination of text properties that encode a date or
  // time (the only surviving text-encoded scalars under the
  // native-storage architecture) see OTr_zMapType.

  // Access: Private

  // Parameters:
  //   $nativeType_i : Integer : A type constant (4D native or OT legacy)
  //   $direction_i  : Integer : 0 = 4D→OT (default), 1 = OT→4D (optional)

  // Returns:
  //   $result_i : Integer : The mapped type constant, or 0 if no mapping

  // Created by Wayne Stewart, 2026-04-03
  // Based on work by himself, Rob Laveaux, and Cannon Smith.
  // Wayne Stewart, 2026-04-10 - Added array-type mappings (4D → OT).
  //   Under the legacy plugin, OT ItemType returns the element type
  //   (1, 4, 5, 6, 11, 3, 30, 23) for non-character arrays, and 113
  //   for String/Text arrays. Used by OTr_zMapType when descending
  //   into an OTr array-container sub-object.
  // ----------------------------------------------------

#DECLARE($nativeType_i : Integer; $direction_i : Integer)->$result_i : Integer

var $dir_i : Integer

$dir_i := Choose(Count parameters < 2; 0; $direction_i)
$result_i := 0

If ($dir_i = 0)

	// 4D → OT
	Case of

		: (($nativeType_i = Is longint) | ($nativeType_i = Is integer))
			$result_i := 5  // OT Longint

		: ($nativeType_i = Is real)
			$result_i := 1  // OT Real

		: ($nativeType_i = Is text)
			$result_i := 112  // OT Character

		: ($nativeType_i = Is date)
			$result_i := 4  // OT Date

		: ($nativeType_i = Is time)
			$result_i := 11  // OT Time

		: ($nativeType_i = Is Boolean)
			$result_i := 6  // OT Boolean

		: ($nativeType_i = Is BLOB)
			$result_i := 30  // OT BLOB

		: ($nativeType_i = Is picture)
			$result_i := 3  // OT Picture

		: ($nativeType_i = Is pointer)
			$result_i := 23  // OT Pointer

		: ($nativeType_i = Is object)
			$result_i := 114  // OT Object

		: ($nativeType_i = Is collection)
			$result_i := 113  // OT Array Character

			// Array element types: under ObjectTools 5, OT ItemType
			// reports the element type for non-character arrays, and
			// 113 (OT Character array) for String / Text arrays.
		: ($nativeType_i = String array) | ($nativeType_i = Text array)
			$result_i := 113  // OT Character array

		: ($nativeType_i = Real array)
			$result_i := 1  // OT Real

		: ($nativeType_i = Integer array) | ($nativeType_i = LongInt array)
			$result_i := 5  // OT Longint

		: ($nativeType_i = Date array)
			$result_i := 4  // OT Date

		: ($nativeType_i = Time array)
			$result_i := 11  // OT Time

		: ($nativeType_i = Boolean array)
			$result_i := 6  // OT Boolean

		: ($nativeType_i = Picture array)
			$result_i := 3  // OT Picture

		: ($nativeType_i = Blob array)
			$result_i := 30  // OT BLOB

		: ($nativeType_i = Pointer array)
			$result_i := 23  // OT Pointer

	End case

Else

	// OT → 4D
	Case of

		: ($nativeType_i = 5)
			// OT Longint
			$result_i := Is longint

		: ($nativeType_i = 1)
			// OT Real
			$result_i := Is real

		: ($nativeType_i = 112)
			// OT Character
			$result_i := Is text

		: ($nativeType_i = 4)
			// OT Date
			$result_i := Is date

		: ($nativeType_i = 11)
			// OT Time
			$result_i := Is time

		: ($nativeType_i = 6)
			// OT Boolean
			$result_i := Is Boolean

		: ($nativeType_i = 30)
			// OT BLOB
			$result_i := Is BLOB

		: ($nativeType_i = 3)
			// OT Picture
			$result_i := Is picture

		: ($nativeType_i = 23)
			// OT Pointer
			$result_i := Is pointer

		: ($nativeType_i = 114)
			// OT Object
			$result_i := Is object

		: ($nativeType_i = 113)
			// OT Array Character
			$result_i := Is collection

		: (($nativeType_i = 115) | ($nativeType_i = 24))
			// OT Record (115), OT Variable (24) → stored as text; map to Is text
			$result_i := Is text

	End case

End if
