//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutVariable (inObject; inTag; inVarPointer)

// Stores the contents of the variable pointed to by $inVarPointer_ptr at the tag path.
// Every 4D variable type except 2D arrays can be stored, including arrays and Booleans.

// **ORIGINAL DOCUMENTATION**

// *OT PutVariable* puts the contents of the variable pointed to by *inVarPointer* into
// *inObject*. Every 4D variable type but 2D arrays can be stored with this command,
// including *Boolean* variables and arrays. Once stored, the data can be retrieved with
// *OT GetVariable* or with the *OT Get<type>* command appropriate to the variable's type.

// If *inObject* is not a valid object handle, an error is generated and *OK* is set to zero.

// If no item in the object has the given tag, a new item is created.

// If an item with the given tag exists and has the type *Type(variablePointer->)*, its
// value is replaced.

// If an item with the given tag exists and has any other type, an error is generated and
// *OK* is set to zero if the *OT VariantItems* option is not set, otherwise the existing
// item is deleted and a new item is created.

// Access: Shared

// Parameters:
//   $inObject_i       : Integer : OTr inObject
//   $inTag_t          : Text    : Tag path (inTag)
//   $inVarPointer_ptr : Pointer : Pointer to variable to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-10 - Revised storage strategy: native
//     OB SET for LongInt/Integer/Real/Text/Boolean/Picture; plain
//     text for Date/Time/Pointer/BLOB. Removed the "var:typename:"
//     sentinel prefix scheme. Corrected the pointer-case constant
//     (was Pointer array K8:23, now Is pointer K8:14).
// Wayne Stewart, 2026-04-10 - BLOB case now honours
//     Storage.OTr.nativeBlobInObject, matching OTr_PutBLOB.
// Wayne Stewart, 2026-04-10 - Date and Time stored natively
//     (was OTr_u_DateToText / OTr_u_TimeToText), matching OTr_PutDate
//     and OTr_PutTime. Pointer and BLOB-fallback paths now write a
//     shadow-type key (leafKey$type) so OTr_z_MapType can
//     distinguish a serialised pointer/blob from ordinary user text.
//     The native-scalar branches explicitly remove any stale shadow
//     left by a previous Put of a different type at the same leaf.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inVarPointer_ptr : Pointer)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $type_i : Integer
var $unlocked_b : Boolean

$unlocked_b:=False:C215

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	
	$type_i:=Type:C295($inVarPointer_ptr->)
	
	Case of 
			
			// Array types: delegate to OTr_PutArray (which re-acquires the lock)
		: ($type_i=Real array:K8:17) | ($type_i=Integer array:K8:18) | ($type_i=LongInt array:K8:19) | ($type_i=Date array:K8:20) | ($type_i=Boolean array:K8:21) | ($type_i=Blob array:K8:30) | ($type_i=String array:K8:15) | ($type_i=Text array:K8:16) | ($type_i=Picture array:K8:22) | ($type_i=Pointer array:K8:23) | ($type_i=Is integer 64 bits:K8:25)
			OTr_z_Unlock
			$unlocked_b:=True:C214
			OTr_PutArray($inObject_i; $inTag_t; $inVarPointer_ptr)
			
			// Native scalar types — store directly. Any lingering
			// shadow from a previous Put of a different type is
			// removed to keep the leaf self-consistent.
		: ($type_i=Is longint:K8:6) | ($type_i=Is integer:K8:5) | ($type_i=Is real:K8:4) | ($type_i=Is text:K8:3) | ($type_i=Is string var:K8:2) | ($type_i=Is boolean:K8:9) | ($type_i=Is picture:K8:10)
			If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
				OB SET:C1220($parent_o; $leafKey_t; $inVarPointer_ptr->)
				OB REMOVE:C1226($parent_o; OTr_z_ShadowKey($leafKey_t))
			End if 
			
			// Date — stored natively (matches OTr_PutDate)
		: ($type_i=Is date:K8:7)
			If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
				OB SET:C1220($parent_o; $leafKey_t; $inVarPointer_ptr->)
				OB REMOVE:C1226($parent_o; OTr_z_ShadowKey($leafKey_t))
			End if 
			
			// Time — stored natively (matches OTr_PutTime)
		: ($type_i=Is time:K8:8)
			If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
				OB SET:C1220($parent_o; $leafKey_t; $inVarPointer_ptr->)
				OB REMOVE:C1226($parent_o; OTr_z_ShadowKey($leafKey_t))
			End if 
			
			// Pointer — stored as plain text via OTr_u_PointerToText
			// and tagged with a shadow-type key so OTr_z_MapType can
			// distinguish a serialised pointer from ordinary user text.
		: ($type_i=Is pointer:K8:14)
			If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
				OB SET:C1220($parent_o; $leafKey_t; OTr_u_PointerToText($inVarPointer_ptr->))
				OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is pointer:K8:14)
			End if 
			
			// BLOB — native OB SET where Storage.OTr.nativeBlobInObject
			// is True (4D v19 R2+); otherwise base64 text fallback via
			// OTr_u_BlobToText. Matches OTr_PutBLOB. Under the fallback
			// path the shadow-type key records that the text property
			// is an encoded BLOB, not ordinary user text.
		: ($type_i=Is BLOB:K8:12)
			If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
				If (Storage:C1525.OTr.nativeBlobInObject)
					OB SET:C1220($parent_o; $leafKey_t; $inVarPointer_ptr->)
					OB REMOVE:C1226($parent_o; OTr_z_ShadowKey($leafKey_t))
				Else 
					OB SET:C1220($parent_o; $leafKey_t; OTr_u_BlobToText($inVarPointer_ptr->))
					OB SET:C1220($parent_o; OTr_z_ShadowKey($leafKey_t); Is BLOB:K8:12)
				End if 
			End if 
			
		Else 
			OTr_z_Error("Unsupported variable type"; Current method name:C684)
			
	End case 
	
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
	
End if 

If (Not:C34($unlocked_b))
	OTr_z_Unlock
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
