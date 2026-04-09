//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetVariable (inObject; inTag; outVarPointer)

// Retrieves a value stored at the tag path and writes
// it into the variable pointed to by $outVarPointer_ptr. Scalar
// variable values are stored as "var:typeName:value".
// Array variable values are stored as sub-objects;
// retrieval is delegated to OT GetArray.

// **ORIGINAL DOCUMENTATION**
// 
// *OT GetVariable* retrieves a value from *inObject*
// at *inTag* into the variable pointed to by *varPtr*.
// 
// Every 4D variable type except 2D arrays can be
// retrieved with this command.
// 
// If *inObject* is not a valid object handle, an error
// is generated and OK is set to zero.
// 
// If no item in the object has the given tag, nothing
// happens.
// 
// If an item with the given tag exists and the stored
// type matches the type of the destination variable,
// the variable's data is replaced with the stored data.
// 
// If the stored type does not match the type of the
// destination variable, an error is generated and OK
// is set to zero.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $outVarPointer_ptr     : Pointer : Pointer to variable to receive the value

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-04 - Fixed: BLOB TO PICTURE missing ".png" codec in Picture case.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $outVarPointer_ptr : Pointer)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $raw_t : Text
var $rest_t : Text
var $typeName_t : Text
var $serialised_t : Text
var $sep_i : Integer
var $unlocked_b : Boolean
var $picBlob_blob : Blob
var $destType_i : Integer

$unlocked_b:=False

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; ->$parent_o; ->$leafKey_t))
		
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			
			$raw_t:=OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3)
			
			If (Substring:C12($raw_t; 1; 4)="var:")
				
				$rest_t:=Substring:C12($raw_t; 5)
				$sep_i:=Position:C15(":"; $rest_t)
				$typeName_t:=Substring:C12($rest_t; 1; $sep_i-1)
				$serialised_t:=Substring:C12($rest_t; $sep_i+1)
				$destType_i:=Type:C295($outVarPointer_ptr->)
				
				Case of 
						
					: ($typeName_t="longint")
						If (($destType_i=Is longint:K8:6) | ($destType_i=Is integer:K8:5))
							$outVarPointer_ptr->:=Num:C11($serialised_t)
						Else 
							OTr_zError("Variable type mismatch"; Current method name:C684)
							OTr_zSetOK(0)
						End if 
						
					: ($typeName_t="real")
						If ($destType_i=Is real:K8:4)
							$outVarPointer_ptr->:=Num:C11($serialised_t)
						Else 
							OTr_zError("Variable type mismatch"; Current method name:C684)
							OTr_zSetOK(0)
						End if 
						
					: ($typeName_t="text")
						If (($destType_i=Is text:K8:3) | ($destType_i=Is string var:K8:2))
							$outVarPointer_ptr->:=$serialised_t
						Else 
							OTr_zError("Variable type mismatch"; Current method name:C684)
							OTr_zSetOK(0)
						End if 
						
					: ($typeName_t="boolean")
						If ($destType_i=Is boolean:K8:9)
							$outVarPointer_ptr->:=($serialised_t="true")
						Else 
							OTr_zError("Variable type mismatch"; Current method name:C684)
							OTr_zSetOK(0)
						End if 
						
					: ($typeName_t="date")
						If ($destType_i=Is date:K8:7)
							$outVarPointer_ptr->:=OTr_uTextToDate($serialised_t)
						Else 
							OTr_zError("Variable type mismatch"; Current method name:C684)
							OTr_zSetOK(0)
						End if 
						
					: ($typeName_t="time")
						If ($destType_i=Is time:K8:8)
							$outVarPointer_ptr->:=OTr_uTextToTime($serialised_t)
						Else 
							OTr_zError("Variable type mismatch"; Current method name:C684)
							OTr_zSetOK(0)
						End if 
						
					: ($typeName_t="pointer")
						If ($destType_i=Is pointer:K8:11)
							$outVarPointer_ptr->:=OTr_uTextToPointer($serialised_t)
						Else 
							OTr_zError("Variable type mismatch"; Current method name:C684)
							OTr_zSetOK(0)
						End if 
						
					: ($typeName_t="blob")
						If ($destType_i=Is BLOB:K8:12)
							$outVarPointer_ptr->:=OTr_uTextToBlob($serialised_t)
						Else 
							OTr_zError("Variable type mismatch"; Current method name:C684)
							OTr_zSetOK(0)
						End if 
						
					: ($typeName_t="picture")
						If ($destType_i=Is picture:K8:10)
							BASE64 DECODE($serialised_t; $picBlob_blob)
							BLOB TO PICTURE:C682($picBlob_blob; $outVarPointer_ptr->; ".png")
						Else 
							OTr_zError("Variable type mismatch"; Current method name:C684)
							OTr_zSetOK(0)
						End if 
					Else 
						OTr_zError("Unknown variable type in stored value"; Current method name:C684)
						OTr_zSetOK(0)
						
				End case 
				
			Else 
				// Array variable — stored as a sub-object; delegate to OT GetArray
				OTr_zUnlock
				$unlocked_b:=True
				OT GetArray($inObject_i; $inTag_t; $outVarPointer_ptr)
				
			End if 
			
		End if 
		
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK(0)
	
End if 

If (Not($unlocked_b))
	OTr_zUnlock
End if

OTr_zRemoveFromCallStack(Current method name)
