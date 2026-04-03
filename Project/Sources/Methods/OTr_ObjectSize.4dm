//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_ObjectSize ($handle_i : Integer) \
//   --> $size_i : Integer

// Returns an approximation of the total size of an OTr object in bytes.
// The object is serialised to JSON and the character length is returned.
// Native BLOB and Picture sizes are added on top. This is an
// approximation; byte counts will not match the legacy plugin.

// Access: Shared

// Parameters:
//   $handle_i : Integer : A handle to an object

// Returns:
//   $size_i : Integer : Approximate size in bytes, or 0 on error

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($handle_i : Integer)->$size_i : Integer

var $pictureIndex_i; $externalSize_i : Integer
var $storedValueText_t; $thisKey_t : Text
var $theseKeys_c : Collection
var $thisObject_o : Object
var $nativeKeyType_i : Integer

$size_i:=0
$theseKeys_c:=New collection:C1472  // Initialise it

// OTr_zLock // Unnecessary to lock for Read Only access

OTr_zInit

If (OTr_zIsValidHandle($handle_i))
	$thisObject_o:=<>OTR_Objects_ao{$handle_i}  // This is not a copy, just making it easier to work with
	$size_i:=Length:C16(JSON Stringify:C1217(<>OTR_Objects_ao{$handle_i}))  // Get the basic text length
	
	// Get the keys, so we can check for 'external' storage
	$theseKeys_c:=OB Keys:C1719($thisObject_o)
	
	
	For each ($thisKey_t; $theseKeys_c)

		$nativeKeyType_i:=OB Get type:C1230($thisObject_o; $thisKey_t)
		$externalSize_i:=0

		Case of 
			: ($nativeKeyType_i=Is BLOB:K8:12)
				$externalSize_i:=BLOB size:C605(OB Get:C1224($thisObject_o; $thisKey_t; Is BLOB:K8:12))

			: ($nativeKeyType_i=Is picture:K8:10)
				$externalSize_i:=Picture size:C356(OB Get:C1224($thisObject_o; $thisKey_t; Is picture:K8:10))

		End case 

		$size_i:=$size_i+$externalSize_i

	End for each 


Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

// OTr_zUnlock // Unnecessary to lock for Read Only access











