//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToXMLSAX (inObject {; inPrettyPrint}) --> Text

// Serialises the stored object as an XML string using SAX output.
// Returns empty text if the handle is invalid.
//
// Because SAX writes directly to a file (there is no in-memory SAX
// equivalent to DOM EXPORT TO VAR), this method:
//   1. Writes the XML to a temporary file via OTr_SaveToXMLFileSAX.
//   2. Reads the file back as UTF-8 text.
//   3. Deletes the temporary file.
//
// The XML schema produced is identical to that of OTr_SaveToXML (the DOM
// equivalent), so the output of both methods is fully interchangeable and
// can be parsed by OTr_LoadFromXML / OTr_LoadFromXMLFile without distinction.
//
// NOTE: SAX always produces compact (non-indented) output — 4D's SAX engine
// provides no built-in indentation facility.  The inPrettyPrint parameter
// is accepted for API symmetry with OTr_SaveToXML but has no effect on the
// text returned.
//
// Shadow-type keys (leafKey$type) are included or excluded according to
// OTr_IncludeShadowKey (default: True).
//
// Use OTr_SaveToXMLFileSAX to write directly to a named file without the
// temporary-file round-trip.

// Access: Shared

// Parameters:
//   $inObject_i      : Integer : OTr handle
//   $inPrettyPrint_b : Boolean : True for indented output; default True (optional)

// Returns:
//   $xml_t : Text : XML string, or empty text if handle is invalid

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inPrettyPrint_b : Boolean)->$xml_t : Text

OTr_zAddToCallStack(Current method name)

var $tmpPath_t : Text
var $valid_b : Boolean

If (Count parameters < 2)
	$inPrettyPrint_b:=True
End if

$xml_t:=""
$valid_b:=False

// Quick validity check before allocating a temp file
OTr_zLock
$valid_b:=OTr_zIsValidHandle($inObject_i)
OTr_zUnlock

If ($valid_b)

	// Build a unique temporary file path in the system temp folder
	$tmpPath_t:=Temporary folder+"OTr_SAX_"+String(Milliseconds)+".xml"

	// Delegate all SAX serialisation to OTr_SaveToXMLFileSAX.
	// SAX always produces compact output; inPrettyPrint has no effect.
	OTr_SaveToXMLFileSAX($inObject_i; $tmpPath_t)

	If (Test path name($tmpPath_t)=Is a document)
		$xml_t:=Document to text($tmpPath_t; "UTF-8")
		DELETE DOCUMENT($tmpPath_t)
	End if

End if

OTr_zRemoveFromCallStack(Current method name)
