//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutVariable (inObject; inTag; inVarPointer)

// Stores the contents of the variable pointed to by
// $inVarPointer_ptr at the tag path in the object. Every 4D
// variable type except 2D arrays can be stored,
// including arrays and Booleans.
//
// Array types are encoded as sub-objects by delegating
// to OTr_PutArray (which manages the lock internally).
// Scalar types are encoded as "var:typeName:value".
// BLOB and Picture scalars use the binary-ref pool
// and are encoded as "var:blob:blob:N" /
// "var:picture:pic:N".

// **ORIGINAL DOCUMENTATION**
// 
// *OT PutVariable* stores the contents of the variable
// pointed to by *varPtr* into *inObject* at *inTag*.
// 
// Every 4D variable type except 2D arrays can be stored
// with this command, including Boolean variables and
// arrays. Once stored, the data can be retrieved with
// *OT GetVariable* or with the *OT Get<type>* command
// appropriate to the variable's type.
// 
// If *inObject* is not a valid object handle, an error
// is generated and OK is set to zero.
// 
// If no item in the object has the given tag, a new
// item is created.
// 
// If an item with the given tag exists and has a
// matching type, its value is replaced.
// 
// If an item with the given tag exists and has any
// other type, an error is generated and OK is set to
// zero if the _OT VariantItems_ option is not set,
// otherwise the existing item is replaced.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inVarPointer_ptr     : Pointer : Pointer to variable to store

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inVarPointer_ptr : Pointer)

var $parent_o : Object
var $leafKey_t : Text
var $type_i : Integer
var $stored_t : Text
var $unlocked_b : Boolean
var $OK_i : Integer
var $picBlob_blob : Blob
var $picData_t : Text

$unlocked_b:=False:C215

OTr_zLock

$OK_i:=1  // Assume everything will work

If (OTr_zIsValidHandle($inObject_i))
	
	$type_i:=Type:C295($inVarPointer_ptr->)
	
	Case of 
			
		: ($type_i=Real array:K8:17) | ($type_i=Integer array:K8:18) | ($type_i=LongInt array:K8:19) | ($type_i=Date array:K8:20) | ($type_i=Boolean array:K8:21) | ($type_i=Blob array:K8:30) | ($type_i=String array:K8:15) | ($type_i=Is null:K8:31) | ($type_i=Is collection:K8:32) | ($type_i=Is variant:K8:33)
			OTr_zUnlock
			$unlocked_b:=True:C214
			OTr_PutArray($inObject_i; $inTag_t; $inVarPointer_ptr)
			
		: ($type_i=Is longint:K8:6) | ($type_i=Is integer:K8:5)
			$stored_t:="var:longint:"+String:C10($inVarPointer_ptr->)
			
		: ($type_i=Is real:K8:4)
			$stored_t:="var:real:"+String:C10($inVarPointer_ptr->)
			
		: ($type_i=Is text:K8:3) | ($type_i=Is string var:K8:2)
			$stored_t:="var:text:"+String:C10($inVarPointer_ptr->)
			
		: ($type_i=Is boolean:K8:9)
			$stored_t:="var:boolean:"+Choose:C955($inVarPointer_ptr->; "true"; "false")
			
		: ($type_i=Is date:K8:7)
			$stored_t:="var:date:"+OTr_uDateToText($inVarPointer_ptr->)
			
		: ($type_i=Is time:K8:8)
			$stored_t:="var:time:"+OTr_uTimeToText($inVarPointer_ptr->)
			
		: ($type_i=Pointer array:K8:23)
			$stored_t:="var:pointer:"+OTr_uPointerToText($inVarPointer_ptr->)
			
		: ($type_i=Is BLOB:K8:12)
			$stored_t:="var:blob:"+OTr_uBlobToText($inVarPointer_ptr->)
			
		: ($type_i=Is picture:K8:10)
			PICTURE TO BLOB($inVarPointer_ptr->; $picBlob_blob; ".png")
			BASE64 ENCODE($picBlob_blob; $picData_t; *)
			$stored_t:="var:picture:"+$picData_t
			
		Else 
			OTr_zError("Unsupported variable type"; Current method name:C684)
			$OK_i:=0
	End case 
	
	If (Not:C34($unlocked_b) & ($OK_i=1))
		If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
			OB SET:C1220($parent_o; $leafKey_t; $stored_t)
		End if 
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	$OK_i:=0
	
End if 

If (Not:C34($unlocked_b))
	OTr_zUnlock
End if 

OTr_zSetOK($OK_i)