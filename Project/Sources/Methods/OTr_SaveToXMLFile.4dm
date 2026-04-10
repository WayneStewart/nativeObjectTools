//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToXMLFile (inObject; inFilePath {; inPrettyPrint})

// Serialises the stored object to a UTF-8 XML file on disk
// using DOM output.  Existing files are overwritten without warning.
//
// Delegates all serialisation to OTr_zXMLWriteObject.
// See OTr_SaveToXML for a description of the XML schema.
//
// Shadow-type keys (leafKey$type) are included or excluded
// according to OTr_IncludeShadowKey (default: True).
//
// Use OTr_SaveToXML to obtain the XML as a Text value instead.

// Access: Shared

// Parameters:
//   $inObject_i      : Integer : OTr inObject
//   $inFilePath_t    : Text    : Full path of the target file
//   $inPrettyPrint_b : Boolean : True for indented output; default True (optional)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inFilePath_t : Text; $inPrettyPrint_b : Boolean)

OTr_zAddToCallStack(Current method name)

var $snapshot_o : Object
var $domRef_t : Text
var $valid_b : Boolean
var $includeShadow_b : Boolean
var $xml_t : Text

If (Count parameters < 3)
	$inPrettyPrint_b:=True
End if

$valid_b:=False

OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
	$snapshot_o:=OB Copy(<>OTR_Objects_ao{$inObject_i})
	$valid_b:=True
End if

OTr_zUnlock

If ($valid_b)

	$includeShadow_b:=OTr_IncludeShadowKey  // read current setting

	// Build DOM tree.
	// DOM Create XML Ref returns a reference to the root element directly.
	$domRef_t:=DOM Create XML Ref("OTrObject")

	OTr_zXMLWriteObject($domRef_t; $snapshot_o; $includeShadow_b)

	If ($inPrettyPrint_b)
		// Export with indentation directly to file
		DOM EXPORT TO FILE($domRef_t; $inFilePath_t)
	Else
		// Export compact: serialise to var then strip whitespace, write via SET DOCUMENT TEXT
		DOM EXPORT TO VAR($domRef_t; $xml_t)
		$xml_t:=Replace string($xml_t; Char(10); "")
		$xml_t:=Replace string($xml_t; Char(9); "")
		$xml_t:=Replace string($xml_t; ">  <"; "><"; *)
		TEXT TO DOCUMENT($inFilePath_t; $xml_t; "UTF-8")
	End if

	DOM CLOSE XML($domRef_t)

End if

OTr_zRemoveFromCallStack(Current method name)
