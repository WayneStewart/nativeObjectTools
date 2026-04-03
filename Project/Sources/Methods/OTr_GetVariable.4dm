//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetVariable (inObject; inTag; varPtr)

// Retrieves a value stored at the tag path and writes
// it into the variable pointed to by $varPtr. Scalar
// variable values are stored as "var:typeName:value".
// Array variable values are stored as sub-objects;
// retrieval is delegated to OTr_GetArray.

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
//   $varPtr     : Pointer : Pointer to variable to receive the value

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $varPtr : Pointer)

var $parent_o : Object
var $leafKey_t : Text
var $raw_t : Text
var $rest_t : Text
var $typeName_t : Text
var $serialised_t : Text
var $sep_i : Integer
var $unlocked_b : Boolean
var $picBlob_blob : Blob

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
				
				Case of 
						
					: ($typeName_t="longint")
						$varPtr->:=Num:C11($serialised_t)
						
					: ($typeName_t="real")
						$varPtr->:=Num:C11($serialised_t)
						
					: ($typeName_t="text")
						$varPtr->:=$serialised_t
						
					: ($typeName_t="boolean")
						$varPtr->:=($serialised_t="true")
						
					: ($typeName_t="date")
						$varPtr->:=OTr_uTextToDate($serialised_t)
						
					: ($typeName_t="time")
						$varPtr->:=OTr_uTextToTime($serialised_t)
						
					: ($typeName_t="pointer")
						$varPtr->:=OTr_uTextToPointer($serialised_t)
						
					: ($typeName_t="blob")
						$varPtr->:=OTr_uTextToBlob($serialised_t)
						
					: ($typeName_t="picture")
							BASE64 DECODE($serialised_t; $picBlob_blob)
							BLOB TO PICTURE($picBlob_blob; $varPtr->)
					Else 
						OTr_zError("Unknown variable type in stored value"; Current method name:C684)
						OTr_zSetOK(0)
						
				End case 
				
			Else 
				// Array variable — stored as a sub-object; delegate to OTr_GetArray
				OTr_zUnlock
				$unlocked_b:=True
				OTr_GetArray($inObject_i; $inTag_t; $varPtr)
				
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
