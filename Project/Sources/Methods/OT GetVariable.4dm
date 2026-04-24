//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetVariable (inObject; inTag; outVarPointer)

// Retrieves a value stored at the tag path and writes it into the variable pointed to
// by $outVarPointer_ptr. The caller's declared variable type determines how the stored
// value is rendered. Every 4D variable type except 2D arrays can be retrieved.

// **Divergence from OT — type coercion on mismatch**
// OTr coerces the stored value when 4D can do so (e.g. LongInt into Text), writing the
// coerced value and setting OK=0. OT leaves the destination unchanged and sets OK=0.
// Code that relies on an empty result as a type-mismatch sentinel will behave differently.

// **ORIGINAL DOCUMENTATION**

// *OT GetVariable* retrieves a value from *inObject* at *inTag* into the variable
// pointed to by *varPtr*.

// Every 4D variable type except 2D arrays can be retrieved with this command.

// If *inObject* is not a valid object handle, an error is generated and OK is set to zero.

// If no item in the object has the given tag, nothing happens (the destination variable
// is left unchanged).

// If an item with the given tag exists and the stored type matches (or can be coerced to)
// the type of the destination variable, the variable's data is replaced.

// If the stored type cannot be rendered into the destination type, an error is generated
// and OK is set to zero.

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
//     scalar types; OTr_u_TextTo* helpers for Date/Time/Pointer/BLOB.
//     Removed the "var:typename:" sentinel parser. Corrected the
//     pointer-case constant (was K8:11, now Is pointer K8:14).
// Wayne Stewart, 2026-04-10 - BLOB case now honours
//     Storage.OTr.nativeBlobInObject, matching OT GetBLOB/GetNewBLOB.
// Wayne Stewart, 2026-04-10 - Date and Time destinations now read
//     natively via OB Get (was OTr_u_TextToDate / OTr_u_TextToTime),
//     matching the native-write side in OT PutVariable.
// Wayne Stewart, 2026-04-11 - Documented coercion-on-mismatch
//     divergence from OT (coerced value returned; OK=0 preserved).
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $outVarPointer_ptr : Pointer)

OTr_z_AddToCallStack(Current method name:C684)

var $parent_o : Object
var $leafKey_t : Text
var $destType_i : Integer
var $unlocked_b : Boolean

$unlocked_b:=False:C215

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	
	$destType_i:=Value type:C1509($outVarPointer_ptr->)
	
	Case of 
			
			// Array destinations: delegate to OT GetArray
		: ($destType_i=Is collection:K8:32)
			// Collections are handled by OT GetArray via the collection path
			OTr_z_Unlock
			$unlocked_b:=True:C214
			OT GetArray($inObject_i; $inTag_t; $outVarPointer_ptr)
			
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
			 | (Type:C295($outVarPointer_ptr->)=Is integer 64 bits:K8:25)
			OTr_z_Unlock
			$unlocked_b:=True:C214
			OT GetArray($inObject_i; $inTag_t; $outVarPointer_ptr)
			
		Else 
			// Scalar destinations — resolve the path and dispatch on type
			If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
				
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
							$outVarPointer_ptr->:=OTr_u_TextToPointer(OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3))
							
						: ($destType_i=Is BLOB:K8:12)
							If (Storage:C1525.OTr.nativeBlobInObject)
								$outVarPointer_ptr->:=OB Get:C1224($parent_o; $leafKey_t; Is BLOB:K8:12)
							Else 
								$outVarPointer_ptr->:=OTr_u_TextToBlob(OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3))
							End if 
							
						Else 
							OTr_z_Error("Unsupported destination variable type"; Current method name:C684)
							
					End case 
					
				End if 
				
			End if 
			
	End case 
	
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
	
End if 

If (Not:C34($unlocked_b))
	OTr_z_Unlock
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
