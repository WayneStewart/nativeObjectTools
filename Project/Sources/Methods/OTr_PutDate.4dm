//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutDate (inObject; inTag; inValue)

// Stores a Date value at the specified tag path.

// **ORIGINAL DOCUMENTATION**

// OT PutDate puts *inValue* into *inObject*.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to
// zero. If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type Is Date, its value is replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_d  : Date    : Value to store (inValue)

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Added type-consistency guard: refuses to overwrite an
//   existing item whose stored type differs from Date (OK=0, value unchanged).
// Wayne Stewart, 2026-04-11 - Added If/Else native/text storage guard.
//   OTr_u_NativeDateInObject() probes the current process's "Dates inside objects"
//   setting at call time (per-process, per-call — see that method for rationale).
//   True  → OB SET with native Date value (no shadow key needed; OB Get type → Is date).
//   False → store as "YYYY-MM-DD" text via OTr_u_DateToText, plus a shadow key
//           (leafKey$type := 4) so OTr_z_MapType can identify the stored text as
//           Is date (4) rather than OT Character (112).
// Wayne Stewart, 2026-04-12 - Type guard updated to use OTr_z_MapType (shadow-key-first)
//   instead of OB Get type, ensuring correct rejection of a text-stored Date (shadow key
//   Is date = 4) that would otherwise pass an Is text check. Native path now also writes
//   the shadow key (leafKey$type := Is date = 4) so that OTr_z_MapType is version-independent
//   and so that OTr_GetDate can branch on the shadow key rather than OB Get type alone.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_d : Date)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $existingType_i : Integer

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; \
		->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$existingType_i:=OTr_z_MapType($parent_o; $leafKey_t)
			If ($existingType_i#0) & ($existingType_i#Is date:K8:7)
				OTr_z_Error("Type mismatch"; Current method name:C684)
			Else 
				If (OTr_u_NativeDateInObject)
					OB SET:C1220($parent_o; $leafKey_t; $inValue_d)
					OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is date:K8:7)
				Else 
					OB SET:C1220($parent_o; $leafKey_t; OTr_u_DateToText($inValue_d))
					// Shadow key lets OTr_z_MapType distinguish a text-stored date
					// (OT type 4) from an ordinary text string (OT type 112).
					OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is date:K8:7)
				End if 
			End if 
		Else 
			If (OTr_u_NativeDateInObject)
				OB SET:C1220($parent_o; $leafKey_t; $inValue_d)
				OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is date:K8:7)
			Else 
				OB SET:C1220($parent_o; $leafKey_t; OTr_u_DateToText($inValue_d))
				// Shadow key lets OTr_z_MapType distinguish a text-stored date
				// (Is date = 4) from an ordinary text string (OT Character = 112).
				OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is date:K8:7)
			End if 
		End if 
	End if 
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
