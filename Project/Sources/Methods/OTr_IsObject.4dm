//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_IsObject (inObject) --> Longint

// Returns 1 when a handle is valid and in use, otherwise 0.

// **ORIGINAL DOCUMENTATION**

// To test whether a given *Longint* value is a valid object handle, use *OT IsObject*.
// If inObject points to a valid object, 1 is returned. If inObject* * is zero or points
// to some other type of object, zero is returned.

// While it is possible to construct a BLOB that would fool ObjectTools into thinking it
// was a object, this is extremely unlikely.

// All ObjectTools methods check the validity of the object handle passed in to prevent
// truly nasty things from happening. Unless you are unsure about the contents of a
// variable or field passed to ObjectTools as a object handle, there is no need to call

// OT IsObject first.

// If you try to retrieve an embedded object from another object and it does not exist, a
// null object handle is returned. In that case you would want to test the result as
// shown in the example below.

// The above example assumes that the requested tag is valid and tries to get the
// embedded object before checking the tag’s validity. Another approach would be to check
// the tag first by using *OT ItemExists*.



// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject

// Returns:
//   $isObject_i : Integer : 1 when handle is valid, otherwise 0

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-05 - Inlined handle check rather than calling
//   OTr_z_IsValidHandle, because OTr_IsObject does not set OK and
//   OTr_z_IsValidHandle now sets OK to 0 on failure. The inlined check
//   preserves the pre-call value of OK in all cases.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer)->$isObject_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

OTr_z_Lock

$isObject_i:=0

If ($inObject_i>0)
	If ($inObject_i<=Size of array:C274(<>OTR_InUse_ab))
		If (<>OTR_InUse_ab{$inObject_i})
			$isObject_i:=1
		End if 
	End if 
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
