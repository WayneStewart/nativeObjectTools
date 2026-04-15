//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetRecord (inObject; inTag; inTable)

// Writes field values from the record snapshot sub-object
// at the tag path into the current record of the specified
// table. Field matching is by name; unrecognised properties
// are silently ignored and unmatched fields are untouched.
// Date and time fields are restored from text via
// OTr_u_TextToDate and OTr_u_TextToTime. Picture and BLOB
// fields are decoded from base64.
// Adapted from OBJ_ToRecord by Cannon Smith.

// **WARNING: Changed Behaviour**

// OTr_GetRecord restores the snapshot previously stored by OTr_PutRecord.
// It does not read live field values from the database object originally
// used to create the stored item.

// **ORIGINAL DOCUMENTATION**

// *OT GetRecord* sets the current record of a table from the packed record data in
// the item referenced by *inTag*. The contents of the item must have been set with OT
// *PutRecord*. The table used to store the packed record is the table which will have
// its current record set.

// If object is not a valid object handle, an error is generated and *OK* is set to zero.
// If no item in object has the given tag, nothing happens.

// If an item with the given tag exists and has the type *OT Is Record*, the current
// record of the item’s original table is set.

// If there is no current record for the item’s table or the current record is locked, an
// error is generated and *OK* is set to zero.

// Warning: Once a record is stored with *OT PutRecord*, it must be retrieved into the
// same table. Otherwise the results are undefined (and potentially disastrous). You can
// use the OT *GetRecordTable* command to find the source table for a stored record.

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inTable_i  : Integer : Table number whose current record to populate (inTable)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-03
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment.
// Wayne Stewart, 2026-04-11 - Applied dual-path Date/Time retrieval to match
//   OTr_PutRecord. When the stored property type is Is date / Is time (native
//   path), OB Get is used directly. When it is Is text (text path, or legacy
//   snapshot), OTr_u_TextToDate / OTr_u_TextToTime are used. This prevents
//   silent data corruption when Storage.OTr.nativeDateInObject is True.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inTable_i : Integer)

OTr_z_AddToCallStack(Current method name:C684)

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
var $storedPropType_i : Integer

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	
	
	
	If (Not:C34(Is table number valid:C999($inTable_i)))
		OTr_z_Error("Invalid table number"; Current method name:C684)
		OTr_z_SetOK(0)
		
	Else 
		
		$tablePtr_ptr:=Table:C252($inTable_i)
		
		
		If (OTr_z_ResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False:C215; ->$parent_o; ->$leafKey_t))
			
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
										// Dual-path: inspect stored property type to handle both
										// native (Is date) and text-serialised ("YYYY-MM-DD") snapshots.
										$storedPropType_i:=OB Get:C1224($snapshot_o; $fieldName_t)
										If ($storedPropType_i=Is date:K8:7)
											$fieldPtr_ptr->:=OB Get:C1224($snapshot_o; $fieldName_t; Is date:K8:7)
										Else 
											$fieldPtr_ptr->:=OTr_u_TextToDate(OB Get:C1224($snapshot_o; $fieldName_t; Is text:K8:3))
										End if 
										
									: ($fieldType_i=Is time:K8:8)
										// Dual-path: inspect stored property type to handle both
										// native (Is time) and text-serialised ("HH:MM:SS") snapshots.
										$storedPropType_i:=OB Get:C1224($snapshot_o; $fieldName_t)
										If ($storedPropType_i=Is time:K8:8)
											$fieldPtr_ptr->:=OB Get:C1224($snapshot_o; $fieldName_t; Is time:K8:8)
										Else 
											$fieldPtr_ptr->:=OTr_u_TextToTime(OB Get:C1224($snapshot_o; $fieldName_t; Is text:K8:3))
										End if 
										
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
					OTr_z_Error("Tag is not a record snapshot"; Current method name:C684)
					OTr_z_SetOK(0)
				End if 
				
			End if 
			
		End if 
		
	End if 
	
Else 
	OTr_z_Error("Invalid handle"; Current method name:C684)
	OTr_z_SetOK(0)
End if 

OTr_z_Unlock

OTr_z_RemoveFromCallStack(Current method name:C684)
