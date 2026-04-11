//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetArrayDate (inObject; inTag; inIndex) --> Date

// Retrieves a single element from a Date array item.
// Returns !00/00/00! on any error or out-of-range index.
// OK is unchanged on success; set to 0 on any failure.

// Retrieval is transparent to storage path: the stored variant
// type is inspected directly.
//   Is text → parsed via OTr_uTextToDate ("YYYY-MM-DD")
//   Is date → retrieved as native Date
// This handles both the text-storage path (nativeDateInObject=False)
// and the native-storage path (nativeDateInObject=True), and correctly
// reads any legacy data stored as text before this guard was added.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)

// Returns:
//   $result_d : Date : Element value, or !00/00/00! on any failure

// Created by Wayne Stewart, 2026-04-05
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-11 - Added If/Else native/text retrieval guard
//   via stored-type inspection. See OTr_GetDate for strategy details.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_d : Date

OTr_zAddToCallStack(Current method name:C684)

var $raw_v : Variant

$raw_v:=OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; Date array:K8:20)
If (Value type:C1509($raw_v)#Is undefined:K8:13)
	If (Value type:C1509($raw_v)=Is text:K8:3)
		$result_d:=OTr_uTextToDate($raw_v)
	Else
		$result_d:=$raw_v
	End if
End if

OTr_zRemoveFromCallStack(Current method name:C684)
