//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT SaveToXMLFile (inObject; inFilePath {; inPrettyPrint})

// Serialises the stored object to a UTF-8 XML file on disk
// using DOM output.  Existing files are overwritten without warning.
//
// Delegates all serialisation to OTr_z_XMLWriteObject.
// See OT SaveToXML for a description of the XML schema.
//
// Shadow-type keys (leafKey$type) are included or excluded
// according to OT IncludeShadowKey (default: True).
//
// Use OT SaveToXML to obtain the XML as a Text value instead.

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

OTr_z_AddToCallStack(Current method name:C684)

var $snapshot_o : Object
var $domRef_t : Text
var $valid_b : Boolean
var $includeShadow_b : Boolean
var $xml_t : Text
var $prettyPrint_b : Boolean

If (Count parameters:C259<3)
	$prettyPrint_b:=True:C214
Else 
	$prettyPrint_b:=$inPrettyPrint_b
End if 

$valid_b:=False:C215

OTr_z_Lock

If (OTr_z_IsValidHandle($inObject_i))
	$snapshot_o:=OB Copy:C1225(<>OTR_Objects_ao{$inObject_i})
	$valid_b:=True:C214
End if 

OTr_z_Unlock

If ($valid_b)
	
	$includeShadow_b:=OT IncludeShadowKey  // read current setting
	
	// Build DOM tree.
	// DOM Create XML Ref returns a reference to the root element directly.
	$domRef_t:=DOM Create XML Ref:C861("OTrObject")
	
	OTr_z_XMLWriteObject($domRef_t; $snapshot_o; $includeShadow_b)
	
	If ($prettyPrint_b)
		// Export with indentation directly to file
		DOM EXPORT TO FILE:C862($domRef_t; $inFilePath_t)
	Else 
		// Export compact: serialise to var then strip whitespace, write via SET DOCUMENT TEXT
		DOM EXPORT TO VAR:C863($domRef_t; $xml_t)
		$xml_t:=Replace string:C233($xml_t; Char:C90(10); "")
		$xml_t:=Replace string:C233($xml_t; Char:C90(9); "")
		$xml_t:=Replace string:C233($xml_t; ">  <"; "><"; *)
		TEXT TO DOCUMENT:C1237($inFilePath_t; $xml_t; "UTF-8")
	End if 
	
	DOM CLOSE XML:C722($domRef_t)
	
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
