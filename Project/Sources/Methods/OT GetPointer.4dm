//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetPointer (inObject; inTag; outPointer)

// Retrieves a Pointer value from the specified tag path
// into the outPointer parameter. The stored text is
// deserialised via OTr_uTextToPointer. Returns a Null
// pointer on any error or missing tag.

// **VERY IMPORTANT NOTE**
// This command must *NOT* be used with pointers to local variables.

// Because 4D methods receive all parameters by value, the output
// parameter ($outPointer_ptr) must be passed using the pointer-to-
// pointer syntax — i.e. ->myVar — so that the method can write the
// result back to the caller's variable via dereference ($outPointer_ptr->:=).

// Passing a plain Pointer variable without -> gives the method only a
// local copy; the caller's variable is never updated.
//
// This differs from OT GetPointer, which as a compiled plugin command
// can write directly to its output parameter via C-level memory access
// and therefore accepts a plain variable without ->.
//
// Correct usage:
// ```
//   var myPtr : Pointer
//   OT GetPointer(handle; "tag"; ->myPtr)
//   // use ->myPtr, not myPtr
//   If (OK=1) & (myPtr#Null)
//     // use myPtr->
//   End if
// ```

// **ORIGINAL DOCUMENTATION**
// 
// *OT GetPointer* retrieves a Pointer value from *inObject*.
// 
// If *inObject* is not a valid object handle, an error
// is generated, OK is set to zero, and a Null pointer
// is returned.
// 
// If no item in the object has the given inTag, a Null
// pointer is returned. If the FailOnItemNotFound option
// is set, an error is generated and OK is set to zero.
// 
// If an item with the given inTag exists and has the type
// *Is Pointer*, the value of the requested element is
// returned.
// 
// If an item with the given inTag exists and has any other
// type, an error is generated, OK is set to zero, and a
// Null pointer is returned.
// 
// Warning: Under no circumstances should you attempt to
// store a pointer to a local or process variable in a
// compiled database and then try to retrieve that pointer
// in another process.

// Access: Shared

// Parameters:
//   $inObject_i     : Integer : OTr inObject
//   $inTag_t        : Text    : Tag path (inTag)
//   $outPointer_ptr : Pointer : Receives the retrieved pointer (outPointer)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $outPointer_ptr : Pointer)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
		If (OB Is defined:C1231($parent_o; $leafKey_t))
			$outPointer_ptr->:=OTr_uTextToPointer(OB Get:C1224($parent_o; $leafKey_t; Is text:K8:3))
		End if 
	End if 
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK(0)
End if 

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
