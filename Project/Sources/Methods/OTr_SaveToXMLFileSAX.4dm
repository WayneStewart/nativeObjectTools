//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToXMLFileSAX (inObject; inFilePath {; inPrettyPrint})

// Serialises the stored object to a UTF-8 XML file on disk using SAX output.
// Existing files are overwritten without warning.
//
// SAX creates the file itself (via Create document) and writes the XML
// structure sequentially from top to bottom using:
//   SAX SET XML DECLARATION — UTF-8 encoding and standalone declaration
//   SAX OPEN XML ELEMENT    — begin tag (with optional attributes)
//   SAX ADD XML ELEMENT VALUE — element body text
//   SAX CLOSE XML ELEMENT   — end tag
//
// All recursive serialisation is delegated to OTr_zXMLWriteObjectSAX,
// which mirrors the structure produced by OTr_zXMLWriteObject (the DOM
// equivalent).  The resulting file is therefore fully interchangeable
// with files written by OTr_SaveToXMLFile and can be parsed by
// OTr_LoadFromXML / OTr_LoadFromXMLFile without distinction.
//
// NOTE: Unlike the DOM equivalent, SAX always produces compact (non-indented)
// output — 4D's SAX engine provides no built-in indentation facility.
// The inPrettyPrint parameter is therefore accepted for API symmetry only
// and has no effect on the file produced.
//
// Shadow-type keys (leafKey$type) are included or excluded according to
// OTr_IncludeShadowKey (default: True).
//
// Use OTr_SaveToXMLSAX to obtain the XML as a Text value instead.

// Access: Shared

// Parameters:
//   $inObject_i      : Integer : OTr handle
//   $inFilePath_t    : Text    : Full path of the target file
//   $inPrettyPrint_b : Boolean : True for indented output; default True (optional)

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inFilePath_t : Text; $inPrettyPrint_b : Boolean)

OTr_zAddToCallStack(Current method name)

var $snapshot_o : Object
var $docRef_t : Time
var $valid_b : Boolean
var $includeShadow_b : Boolean

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

	// Create (or overwrite) the destination file.
	// SAX requires the document to be opened for writing — read-write mode
	// is appropriate here since we are the sole writer.
	$docRef_t:=Create document($inFilePath_t)

	If (OK=1)

		// Write the XML declaration: encoding UTF-8, standalone = False.
		// SAX SET XML DECLARATION does not control indentation — SAX output
		// is always compact regardless of the inPrettyPrint parameter.
		SAX SET XML DECLARATION($docRef_t; "UTF-8"; False)

		// Write the root element <OTrObject>
		SAX OPEN XML ELEMENT($docRef_t; "OTrObject")

		// Recursively write all properties
		OTr_zXMLWriteObjectSAX($docRef_t; $snapshot_o; $includeShadow_b)

		// Close </OTrObject>
		SAX CLOSE XML ELEMENT($docRef_t)

		CLOSE DOCUMENT($docRef_t)

	End if

End if

OTr_zRemoveFromCallStack(Current method name)
