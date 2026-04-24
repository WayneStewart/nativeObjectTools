//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT LoadFromXML (inXML) --> Longint

// Parses an XML string (written by OT SaveToXML) using DOM
// and loads the reconstructed object into a new OTr handle.
// Returns 0 if inXML is empty or cannot be parsed.
//
// Delegates all reconstruction to OTr_z_XMLReadObject.
// See OT SaveToXML for a description of the XML schema.
//
// Shadow-type keys present in the XML are always restored,
// regardless of the current OT IncludeShadowKey setting, so
// that round-trip fidelity is preserved for files that were
// written with shadow keys included.

// Access: Shared

// Parameters:
//   $inXML_t : Text : XML string to parse

// Returns:
//   $handle_i : Integer : New OTr handle, or 0 if parsing failed

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inXML_t : Text)->$handle_i : Integer

OTr_z_AddToCallStack(Current method name:C684)

var $domRef_t : Text
var $rootRef_t : Text
var $attrName_t : Text
var $attrValue_t : Text
var $parsed_o : Object
var $slot_i : Integer
var $errSave_t : Text

$handle_i:=0

If ($inXML_t#"")
	
	// Strip UTF-8 BOM if present
	If (Character code:C91($inXML_t[[1]])=65279)
		$inXML_t:=Substring:C12($inXML_t; 2)
	End if 
	
	$errSave_t:=Method called on error:C704
	ON ERR CALL:C155("OTr_z_ErrIgnore")
	$domRef_t:=DOM Parse XML variable:C720($inXML_t)
	ON ERR CALL:C155($errSave_t)
	
	If ($domRef_t#"")
		
		// Locate the <OTrObject> root element
		$rootRef_t:=DOM Get first child XML element:C723($domRef_t; $attrName_t; $attrValue_t)
		
		If ($rootRef_t#"")
			$parsed_o:=OTr_z_XMLReadObject($rootRef_t)
		End if 
		
		DOM CLOSE XML:C722($domRef_t)
		
		If ($parsed_o#Null:C1517)
			
			OTr_z_Lock
			
			$slot_i:=Find in array:C230(<>OTR_InUse_ab; False:C215)
			If ($slot_i=-1)
				$slot_i:=Size of array:C274(<>OTR_InUse_ab)+1
				INSERT IN ARRAY:C227(<>OTR_InUse_ab; $slot_i)
				INSERT IN ARRAY:C227(<>OTR_Objects_ao; $slot_i)
			End if 
			
			<>OTR_Objects_ao{$slot_i}:=OB Copy:C1225($parsed_o)
			<>OTR_InUse_ab{$slot_i}:=True:C214
			
			OTr_z_Unlock
			
			$handle_i:=$slot_i
			
		End if 
		
	End if 
	
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
