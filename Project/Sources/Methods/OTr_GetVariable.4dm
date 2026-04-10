//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetVariable (inObject; inTag; outVarPointer)

// Retrieves a value stored at the tag path and writes it
// into the variable pointed to by $outVarPointer_ptr. The
// *destination type* (via Value type of the dereferenced
// output pointer) drives the dispatch: the caller's declared
// variable type tells the method how to render the stored
// value into the caller's variable.
//
// Retrieval strategy (revised 2026-04-10):
//   - Native scalar types (LongInt, Integer, Real, Text, Boolean,
//     Picture) are read directly from the object property via
//     the appropriate OB Get form.
//   - Date, Time, Pointer are read as text and parsed via the
//     OTr_uTextTo* helpers, matching the storage format used
//     by OTr_PutVariable and the typed put-methods.
//   - BLOB is read as base64 text and decoded via OTr_uTextToBlob.
//   - Array types are delegated to OTr_GetArray.
//   - If a value was stored as a date, time, or BLOB but the
//     caller requests it as text, the method returns the stored
//     text form directly. Text is the universal fallback; any
//     value rendered as text remains a valid response.

// **ORIGINAL DOCUMENTATION**
//
// *OTr_GetVariable* retrieves a value from *inObject*
// at *inTag* into the variable pointed to by *varPtr*.
//
// Every 4D variable type except 2D arrays can be
// retrieved with this command.
//
// If *inObject* is not a valid object handle, an error
// is generated and OK is set to zero.
//
// If no item in the object has the given tag, nothing
// happens (the destination variable is left unchanged).
//
// If an item with the given tag exists and the stored
// type matches (or can be coerced to) the type of the
// destination variable, the variable's data is replaced.
//
// If the stored type cannot be rendered into the
// destination type, an error is generated and OK
// is set to zero.
//
// **Divergence from OT — type coercion on mismatch:**
// When 4D can coerce the stored value to the destination
// type (e.g. a stored LongInt retrieved into a Text
// variable), OTr writes the coerced value into the
// destination variable and sets OK=0. OT, by contrast,
// leaves the destination variable empty/unchanged and
// sets OK=0. Code that relies on an empty result as a
// sentinel for a type mismatch will behave differently
// under OTr.

// Access: Shared

// Parameters:
//   $inObject_i        : Integer : OTr inObject
//   $inTag_t           : Text    : Tag path (inTag)
//   $outVarPointer_ptr : Pointer : Pointer to variable to receive the value

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Revised retrieval strategy: dispatch
//     on Value type of the destination; native OB Get for native
//     scalar types; OTr_uTextTo* helpers for Date/Time/Pointer/BLOB.
//     Removed the "var:typename:" sentinel parser. Corrected the
//     pointer-case constant (was K8:11, now Is pointer K8:14).
// Wayne Stewart, 2026-04-10 - BLOB case now honours
//     Storage.OTr.nativeBlobInObject, matching OTr_GetBLOB/GetNewBLOB.
// Wayne Stewart, 2026-04-10 - Date and Time destinations now read
//     natively via OB Get (was OTr_uTextToDate / OTr_uTextToTime),
//     matching the native-write side in OTr_PutVariable.
// Wayne Stewart, 2026-04-11 - Documented coercion-on-mismatch
//     divergence from OT (coerced value returned; OK=0 preserved).
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $outVarPointer_ptr : Pointer)

OTr_zAddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $destType_i : Integer
var $unlocked_b : Boolean

$unlocked_b:=False:C215

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))

	$destType_i:=Value type:C1509($outVarPointer_ptr->)

	Case of

			// Array destinations: delegate to OTr_GetArray
		: ($destType_i=Is collection:K8:32)
			// Collections are handled by OTr_GetArray via the collection path
			OTr_zUnlock
			$unlocked_b:=True:C214
			OTr_GetArray($inObject_i; $inTag_t; $outVarPointer_ptr)

		: (Type:C295($outVarPointer_ptr->)=Real array:K8:17)\
			 | (Type:C295($outVarPointer_ptr->)=Integer array:K8:18)\
			 | (Type:C295($outVarPointer_ptr->)=LongInt array:K8:19)\
			 | (Type:C295($outVarPointer_ptr->)=Date array:K8:20)\
			 | (Type:C295($outVarPointer_ptr->)=Boolean array:K8:21)\
			 | (Type:C295($outVarPointer_ptr->)=Blob array:K8:30)\
			 | (Type:C295($outVarPointer_ptr->)=String array:K8:15)\
			 | (Type:C295($outVarPointer_ptr->)=Text array:K8:16)\
			 | (Type:C295($outVarPointer_ptr->)=Picture array:K8:22)\
			 | (Type:C295($outVarPointer_ptr->)=Pointer array:K8:23)\
			 | (Type:C295($outVarPointer_ptr->)=Time array:K8:25)
			OTr_zUnlock
			$unlocked_b:=True:C214
			OTr_GetArray($inObject_i; $inTag_t; $outVarPointer_ptr)

		Else
			// Scalar destinations — resolve the path and dispatch on type
			If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))

				If (OB Is defined:C1231($parent_o; $leafKey_t))

					Case of

						: ($destType_i=Is real:K8:4)
							$outVarPointer_ptr->:=OB Get:C1224($parent_o; $leafKey_t; Is real:K8:4)

						: ($destType_i=Is longint:K8:6) | ($destType_i=Is integer:K8:5)
							$outVarPointer_ptr->:=OB Get:C1224($parent_o; $leafKey_t; Is longint:K8:6)

						: ($destType_i=Is text:K8:3) | ($destType_i=Is string var:K8:2)
							$outVarPointer_ptr->:=OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3)

						: ($destType_i=Is boolean:K8:9)
							$outVarPointer_ptr->:=OB Get:C1224($parent_o; $leafKey_t; Is boolean:K8:9)

						: ($destType_i=Is picture:K8:10)
							$outVarPointer_ptr->:=OB Get:C1224($parent_o; $leafKey_t; Is picture:K8:10)

						: ($destType_i=Is date:K8:7)
							$outVarPointer_ptr->:=OB Get:C1224($parent_o; $leafKey_t; Is date:K8:7)

						: ($destType_i=Is time:K8:8)
							$outVarPointer_ptr->:=OB Get:C1224($parent_o; $leafKey_t; Is time:K8:8)

						: ($destType_i=Is pointer:K8:14)
							$outVarPointer_ptr->:=OTr_uTextToPointer(OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3))

						: ($destType_i=Is BLOB:K8:12)
							If (Storage:C1525.OTr.nativeBlobInObject)
								$outVarPointer_ptr->:=OB Get:C1224($parent_o; $leafKey_t; Is BLOB:K8:12)
							Else
								$outVarPointer_ptr->:=OTr_uTextToBlob(OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3))
							End if

						Else
							OTr_zError("Unsupported destination variable type"; Current method name:C684)

					End case

				End if

			End if

	End case

Else
	OTr_zError("Invalid handle"; Current method name:C684)

End if

If (Not:C34($unlocked_b))
	OTr_zUnlock
End if

OTr_zRemoveFromCallStack(Current method name:C684)
