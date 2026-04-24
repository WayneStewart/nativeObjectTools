//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OT SaveToXML (inObject {; inPrettyPrint}) --> Text

// Serialises the stored object as an XML string using DOM output.
// Returns empty text if the handle is invalid.
//
// The XML schema is:
//   <OTrObject>
//     <item key="leafName" type="<OT type constant>">value</item>
//     <item key="embeddedObj" type="114">
//       <object>
//         <item key="..." type="...">...</item>
//       </object>
//     </item>
//     <item key="myArray" type="<element OT type>">
//       <array arrayType="<4D array-type constant>">
//         <element index="0">value</element>
//         ...
//       </array>
//     </item>
//   </OTrObject>
//
// BLOB and Picture values are Base64-encoded in the element body.
// Date values are emitted in ISO 8601 format (YYYY-MM-DD).
// Time values are emitted as HH:MM:SS.
//
// Shadow-type keys (leafKey$type) are included or excluded
// according to OT IncludeShadowKey (default: True).
//
// When inPrettyPrint is True (the default), DOM EXPORT TO VAR
// produces indented output.  Pass False for compact single-line output.
//
// Use OT SaveToXMLFile to write directly to a file.

// Access: Shared

// Parameters:
//   $inObject_i      : Integer : OTr inObject
//   $inPrettyPrint_b : Boolean : True for indented output; default True (optional)

// Returns:
//   $xml_t : Text : XML string, or empty text if handle is invalid

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inPrettyPrint_b : Boolean)->$xml_t : Text

OTr_z_AddToCallStack(Current method name:C684)

var $snapshot_o : Object
var $domRef_t : Text
var $valid_b : Boolean
var $includeShadow_b : Boolean
var $prettyPrint_b : Boolean

If (Count parameters:C259<2)
	$prettyPrint_b:=True:C214
Else 
	$prettyPrint_b:=$inPrettyPrint_b
End if 

$xml_t:=""
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
	
	// Export to text variable
	DOM EXPORT TO VAR:C863($domRef_t; $xml_t)
	
	If (Not:C34($prettyPrint_b))
		// Compact: strip newlines and redundant whitespace between tags
		$xml_t:=Replace string:C233($xml_t; Char:C90(10); "")
		$xml_t:=Replace string:C233($xml_t; Char:C90(9); "")
	End if 
	
	DOM CLOSE XML:C722($domRef_t)
	
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
