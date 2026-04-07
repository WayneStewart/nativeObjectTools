//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutRecord (inObject; inTag; inTable)

// Serialises all fields of the current record of the
// specified table into a sub-object snapshot stored at
// the tag path. The snapshot includes the table number,
// all scalar fields, dates and times as text, and
// Pictures and BLOBs as base64-encoded text strings.
// Adapted from OBJ_FromRecord by Cannon Smith.

// **ORIGINAL DOCUMENTATION**
// 
// *OT PutRecord* serialises the current record of
// *inTable* into *inObject* at *inTag*.
// 
// If *inObject* is not a valid object handle, an error
// is generated and OK is set to zero.
// 
// If *inTable* is not a valid table number, or there is
// no current record for the table, an error is generated
// and OK is set to zero.
// 
// If no item in the object has the given inTag, a new
// item is created.
// 
// If an item with the given inTag exists and has the type
// *OT Record (115)*, its value is replaced.
// 
// If an item with the given inTag exists and has any other
// type, an error is generated and OK is set to zero if
// the _OT VariantItems_ option is not set, otherwise the
// existing item is deleted and a new item is created.
// 
// Note: OTr stores a complete snapshot of the record,
// not a reference to it. The snapshot is portable and
// does not go stale if the underlying record changes.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inTable_i  : Integer : Table number whose current record to snapshot (inTable)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Guy Algot, 2026-04-03 - Zoom session. Fixed Get last field number
//   call: removed erroneous -> dereference (it takes a pointer, not
//   the table value). Added :Cxxx command codes throughout.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inTable_i : Integer)

OTr_zAddToCallStack(Current method name)

var $parent_o : Object
var $leafKey_t : Text
var $tablePtr_ptr : Pointer
var $snapshot_o : Object
var $fieldPtr_ptr : Pointer
var $fieldName_t : Text
var $fieldType_i : Integer
var $lastField_i : Integer
var $x_i : Integer
var $recordNum_i : Integer
var $tempBlob_blob : Blob

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	
	If (Not:C34(Is table number valid:C999($inTable_i)))
		OTr_zError("Invalid table number"; Current method name:C684)
		OTr_zSetOK(0)
		
	Else 
		
		$tablePtr_ptr:=Table:C252($inTable_i)
		
		$recordNum_i:=Record number:C243($tablePtr_ptr->)
		
		If ($recordNum_i<0)
			OTr_zError("No current record"; Current method name:C684)
			OTr_zSetOK(0)
			
		Else 
			
			$snapshot_o:=New object:C1471
			$snapshot_o.__tableNum:=$inTable_i
			
			$lastField_i:=Get last field number:C255($tablePtr_ptr)
			
			For ($x_i; 1; $lastField_i)
				
				If (Is field number valid:C1000($tablePtr_ptr; $x_i))
					
					$fieldPtr_ptr:=Field:C253($inTable_i; $x_i)
					$fieldName_t:=Field name:C257($fieldPtr_ptr)
					$fieldType_i:=Type:C295($fieldPtr_ptr->)
					
					Case of 
							
						: ($fieldType_i=Is date:K8:7)
							OB SET:C1220($snapshot_o; $fieldName_t; OTr_uDateToText($fieldPtr_ptr->))
							
						: ($fieldType_i=Is time:K8:8)
							OB SET:C1220($snapshot_o; $fieldName_t; OTr_uTimeToText($fieldPtr_ptr->))
							
						: ($fieldType_i=Is picture:K8:10)
							PICTURE TO BLOB:C692($fieldPtr_ptr->; $tempBlob_blob; ".png")
							BASE64 ENCODE:C895($tempBlob_blob)
							OB SET:C1220($snapshot_o; $fieldName_t; Convert to text:C1012($tempBlob_blob; "US-ASCII"))
							
						: ($fieldType_i=Is BLOB:K8:12)
							$tempBlob_blob:=$fieldPtr_ptr->
							BASE64 ENCODE:C895($tempBlob_blob)
							OB SET:C1220($snapshot_o; $fieldName_t; Convert to text:C1012($tempBlob_blob; "US-ASCII"))
							
						Else 
							OB SET:C1220($snapshot_o; $fieldName_t; $fieldPtr_ptr->)
							
					End case 
					
				End if 
				
			End for 
			
			If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True:C214; ->$parent_o; ->$leafKey_t))
				OB SET:C1220($parent_o; $leafKey_t; $snapshot_o)
			End if 
			
		End if 
		
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK(0)
End if 

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
