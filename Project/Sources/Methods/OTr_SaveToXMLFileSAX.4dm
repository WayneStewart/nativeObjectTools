//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_SaveToXMLFileSAX (inObject; inFilePath {; inPrettyPrint})

// Serialises the OTr object to a UTF-8 XML file on disk using SAX output.
// Existing files are overwritten without warning.

// NOTE: SAX always produces compact (non-indented) output regardless of the
// inPrettyPrint parameter, which is accepted for API symmetry only. The
// resulting file is fully interchangeable with files written by OTr_SaveToXMLFile.

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

OTr_z_AddToCallStack(Current method name:C684)

var $snapshot_o : Object
var $docRef_t : Time
var $valid_b : Boolean
var $includeShadow_b : Boolean
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
	
	$includeShadow_b:=OTr_IncludeShadowKey  // read current setting
	
	// Create (or overwrite) the destination file.
	// SAX requires the document to be opened for writing — read-write mode
	// is appropriate here since we are the sole writer.
	$docRef_t:=Create document:C266($inFilePath_t)
	
	If (OK=1)
		
		// Write the XML declaration: encoding UTF-8, standalone = False.
		// SAX SET XML DECLARATION does not control indentation — SAX output
		// is always compact regardless of the inPrettyPrint parameter.
		SAX SET XML DECLARATION:C858($docRef_t; "UTF-8"; False:C215)
		
		// Write the root element <OTrObject>
		SAX OPEN XML ELEMENT:C853($docRef_t; "OTrObject")
		
		// Recursively write all properties
		OTr_z_XMLWriteObjectSAX($docRef_t; $snapshot_o; $includeShadow_b)
		
		// Close </OTrObject>
		SAX CLOSE XML ELEMENT:C854($docRef_t)
		
		CLOSE DOCUMENT:C267($docRef_t)
		
	End if 
	
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
