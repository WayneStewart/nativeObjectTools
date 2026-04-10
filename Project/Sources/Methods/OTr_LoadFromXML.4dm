//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_LoadFromXML (inXML) --> Longint

// Parses an XML string (written by OTr_SaveToXML) using DOM
// and loads the reconstructed object into a new OTr handle.
// Returns 0 if inXML is empty or cannot be parsed.
//
// Delegates all reconstruction to OTr_zXMLReadObject.
// See OTr_SaveToXML for a description of the XML schema.
//
// Shadow-type keys present in the XML are always restored,
// regardless of the current OTr_IncludeShadowKey setting, so
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

OTr_zAddToCallStack(Current method name)

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
	If (Character code($inXML_t[[1]])=65279)
		$inXML_t:=Substring($inXML_t; 2)
	End if

	$errSave_t:=Method called on error
	ON ERR CALL("OTr_zErrIgnore")
	$domRef_t:=DOM Parse XML variable($inXML_t)
	ON ERR CALL($errSave_t)

	If ($domRef_t#"")

		// Locate the <OTrObject> root element
		$rootRef_t:=DOM Get first child XML element($domRef_t; $attrName_t; $attrValue_t)

		If ($rootRef_t#"")
			$parsed_o:=OTr_zXMLReadObject($rootRef_t)
		End if

		DOM CLOSE XML($domRef_t)

		If ($parsed_o#Null)

			OTr_zLock

			$slot_i:=Find in array(<>OTR_InUse_ab; False)
			If ($slot_i=-1)
				$slot_i:=Size of array(<>OTR_InUse_ab)+1
				INSERT IN ARRAY(<>OTR_InUse_ab; $slot_i)
				INSERT IN ARRAY(<>OTR_Objects_ao; $slot_i)
			End if

			<>OTR_Objects_ao{$slot_i}:=OB Copy($parsed_o)
			<>OTR_InUse_ab{$slot_i}:=True

			OTr_zUnlock

			$handle_i:=$slot_i

		End if

	End if

End if

OTr_zRemoveFromCallStack(Current method name)
