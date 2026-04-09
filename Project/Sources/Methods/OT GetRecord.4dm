//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT GetRecord (inObject; inTag; inTable)

// Writes field values from the record snapshot sub-object
// at the tag path into the current record of the specified
// table. Field matching is by name; unrecognised properties
// are silently ignored and unmatched fields are untouched.
// Date and time fields are restored from text via
// OTr_uTextToDate and OTr_uTextToTime. Picture and BLOB
// fields are decoded from base64.
// Adapted from OBJ_ToRecord by Cannon Smith.

// **ORIGINAL DOCUMENTATION**
// 
// *OT GetRecord* writes field values from the snapshot
// stored at *inTag* into the current record of *inTable*.
// 
// It is up to the caller to ensure a record is loaded in
// read/write mode before calling this method, and to save
// the record afterwards.
// 
// If *inObject* is not a valid object handle, an error
// is generated and OK is set to zero.
// 
// If *inTable* is not a valid table number, an error is
// generated and OK is set to zero.
// 
// If no item in the object has the given inTag, or the
// item is not a record snapshot sub-object, an error is
// generated and OK is set to zero.
// 
// Note: Unlike the legacy OT GetRecord, this method writes
// snapshot values into whatever record is currently loaded.
// No database read is performed.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inTable_i  : Integer : Table number whose current record to populate (inTable)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
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
var $tempBlob_blob : Blob

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	
	
	
	If (Not:C34(Is table number valid:C999($inTable_i)))
		OTr_zError("Invalid table number"; Current method name:C684)
		OTr_zSetOK(0)
		
	Else 
		
		$tablePtr_ptr:=Table:C252($inTable_i)
		
		
		If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
			
			If (OB Is defined:C1231($parent_o; $leafKey_t))
				
				$snapshot_o:=OB Get:C1224($parent_o; $leafKey_t; Is object:K8:27)
				
				If (OB Is defined:C1231($snapshot_o; "__tableNum"))
					
					$lastField_i:=Get last field number:C255($tablePtr_ptr)
					
					For ($x_i; 1; $lastField_i)
						
						If (Is field number valid:C1000($tablePtr_ptr; $x_i))
							
							$fieldPtr_ptr:=Field:C253($inTable_i; $x_i)
							$fieldName_t:=Field name:C257($fieldPtr_ptr)
							
							If (OB Is defined:C1231($snapshot_o; $fieldName_t))
								
								$fieldType_i:=Type:C295($fieldPtr_ptr->)
								
								Case of 
										
									: ($fieldType_i=Is date:K8:7)
										$fieldPtr_ptr->:=OTr_uTextToDate(OB Get:C1224($snapshot_o; $fieldName_t; Is text:K8:3))
										
									: ($fieldType_i=Is time:K8:8)
										$fieldPtr_ptr->:=OTr_uTextToTime(OB Get:C1224($snapshot_o; $fieldName_t; Is text:K8:3))
										
									: ($fieldType_i=Is picture:K8:10)
										CONVERT FROM TEXT:C1011(OB Get:C1224($snapshot_o; $fieldName_t; Is text:K8:3); "US-ASCII"; $tempBlob_blob)
										BASE64 DECODE:C896($tempBlob_blob)
										BLOB TO PICTURE:C682($tempBlob_blob; $fieldPtr_ptr->; ".png")
										
									: ($fieldType_i=Is BLOB:K8:12)
										CONVERT FROM TEXT:C1011(OB Get:C1224($snapshot_o; $fieldName_t; Is text:K8:3); "US-ASCII"; $tempBlob_blob)
										BASE64 DECODE:C896($tempBlob_blob)
										$fieldPtr_ptr->:=$tempBlob_blob
										
									: ($fieldType_i=Is text:K8:3) | ($fieldType_i=Is alpha field:K8:1) | ($fieldType_i=Is string var:K8:2)
										$fieldPtr_ptr->:=OB Get:C1224($snapshot_o; $fieldName_t; Is text:K8:3)
										
									: ($fieldType_i=Is real:K8:4)
										$fieldPtr_ptr->:=OB Get:C1224($snapshot_o; $fieldName_t; Is real:K8:4)
										
									: ($fieldType_i=Is longint:K8:6) | ($fieldType_i=Is integer:K8:5)
										$fieldPtr_ptr->:=OB Get:C1224($snapshot_o; $fieldName_t; Is longint:K8:6)
										
									: ($fieldType_i=Is boolean:K8:9)
										$fieldPtr_ptr->:=OB Get:C1224($snapshot_o; $fieldName_t; Is boolean:K8:9)
										
									Else 
										$fieldPtr_ptr->:=OB Get:C1224($snapshot_o; $fieldName_t)
										
								End case 
								
							End if 
							
						End if 
						
					End for 
					
				Else 
					OTr_zError("Tag is not a record snapshot"; Current method name:C684)
					OTr_zSetOK(0)
				End if 
				
			End if 
			
		End if 
		
	End if 
	
Else 
	OTr_zError("Invalid handle"; Current method name:C684)
	OTr_zSetOK(0)
End if 

OTr_zUnlock

OTr_zRemoveFromCallStack(Current method name)
