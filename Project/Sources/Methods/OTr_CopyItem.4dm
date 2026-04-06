//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_CopyItem (inSourceObject; inSourceTag; inDestObject; inDestTag)

// Copies the item at $inSourceTag_t to $inDestTag_t. The destination need not
// exist; it will be created. Source and destination handles may be the
// same. Embedded objects are deep-copied via OB Copy.

// Access: Shared

// Parameters:
//   $inSourceObject_i  : Integer : OTr inSourceObject
//   $inSourceTag_t     : Text    : Source item tag (inSourceTag)
//   $inDestObject_i    : Integer : OTr inDestObject
//   $inDestTag_t       : Text    : Destination item tag (inDestTag)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-01
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-04 - Added OTr_zSetOK(1) on success.
// ----------------------------------------------------

#DECLARE($inSourceObject_i : Integer; $inSourceTag_t : Text; \
$inDestObject_i : Integer; $inDestTag_t : Text)

var $srcParent_o : Object
var $srcLeafKey_t : Text
var $destParent_o : Object
var $destLeafKey_t : Text
var $nativeType_i : Integer
var $textVal_t : Text

OTr_zLock

If (OTr_zIsValidHandle($inSourceObject_i)\
 & OTr_zIsValidHandle($inDestObject_i))
	
	If (OTr_zResolvePath(<>OTR_Objects_ao{$inSourceObject_i}; $inSourceTag_t; \
		False:C215; ->$srcParent_o; ->$srcLeafKey_t))
		
		If (OB Is defined:C1231($srcParent_o; $srcLeafKey_t))
			
			If (OTr_zResolvePath(<>OTR_Objects_ao{$inDestObject_i}; \
				$inDestTag_t; True:C214; ->$destParent_o; ->$destLeafKey_t))
				
				$nativeType_i:=OB Get type:C1230($srcParent_o; $srcLeafKey_t)
				
				Case of 
						
					: ($nativeType_i=Is real:K8:4)
						OB SET:C1220($destParent_o; $destLeafKey_t; \
							OB Get:C1224($srcParent_o; $srcLeafKey_t; Is real:K8:4))
						
					: (($nativeType_i=Is longint:K8:6)\
						 | ($nativeType_i=Is integer:K8:5))
						OB SET:C1220($destParent_o; $destLeafKey_t; \
							OB Get:C1224($srcParent_o; $srcLeafKey_t; Is longint:K8:6))
						
					: ($nativeType_i=Is boolean:K8:9)
						OB SET:C1220($destParent_o; $destLeafKey_t; \
							OB Get:C1224($srcParent_o; $srcLeafKey_t; Is boolean:K8:9))
						
					: ($nativeType_i=Is object:K8:27)
						OB SET:C1220($destParent_o; $destLeafKey_t; OB Copy:C1225(OB Get:C1224(\
							$srcParent_o; $srcLeafKey_t; Is object:K8:27)))
						
					: ($nativeType_i=Is collection:K8:32)
						OB SET:C1220($destParent_o; $destLeafKey_t; \
							OB Get:C1224($srcParent_o; $srcLeafKey_t; Is collection:K8:32))
						
					: ($nativeType_i=Is text:K8:3)
							OB SET:C1220($destParent_o; $destLeafKey_t; \
								OB Get:C1224($srcParent_o; $srcLeafKey_t; Is text:K8:3))

						: ($nativeType_i=Is BLOB:K8:12)
							OB SET:C1220($destParent_o; $destLeafKey_t; \
								OB Get:C1224($srcParent_o; $srcLeafKey_t; Is BLOB:K8:12))

						: ($nativeType_i=Is picture:K8:10)
							OB SET:C1220($destParent_o; $destLeafKey_t; \
								OB Get:C1224($srcParent_o; $srcLeafKey_t; Is picture:K8:10))
				End case 
				OTr_zSetOK(1)
			End if 
			
		Else 
			OTr_zError("Source item not found: "+$inSourceTag_t; \
				Current method name:C684)
		End if 
		
	Else 
		OTr_zError("Invalid source path: "+$inSourceTag_t; Current method name:C684)
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
End if 

OTr_zUnlock