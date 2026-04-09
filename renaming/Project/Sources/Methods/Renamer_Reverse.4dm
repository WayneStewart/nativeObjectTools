//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: Renamer_Reverse
//
// Builds the "OT Xxx" --> OTr_Xxx mapping by scanning the Methods folder
// for all files whose names begin with "OT " (OT followed by a space),
// EXCLUDING those that begin with "OT z" or "OT u" (the renamed forms of
// private and utility methods, which were never renamed in a forward pass).
//
// Calls Renamer_zInspect to report anomalies before proceeding.
//
// The transformation rule is:
//   "OT "  -->  OTr_   (the space is replaced by r-underscore)
//
// Examples:
//   OT New            -->  OTr_New
//   OT GetLong        -->  OTr_GetLong
//   OT zInit          -->  NOT reversed (excluded: "OT z" prefix)
//   OT uBlobToText    -->  NOT reversed (excluded: "OT u" prefix)
//
// Parameters:
//   $methodsFolder_t : Text : Absolute path to Project/Sources/Methods/
//   $foldersJSON_t   : Text : Absolute path to Project/Sources/folders.json
//   $derivedData_t   : Text : Absolute path to Project/DerivedData/
//
// Created by Wayne Stewart, 2026-04-09
// ----------------------------------------------------

#DECLARE($methodsFolder_t : Text; $foldersJSON_t : Text; $derivedData_t : Text)

var $fileName_t : Text
var $oldName_t : Text
var $newName_t : Text
var $mapping_o : Object
var $count_i : Integer
var $i_i : Integer
var $msg_t : Text
var $DQ_t : Text
var $anomalyCount_i : Integer
var $reportText_t : Text

// ── Build the mapping by scanning for "OT *.4dm" files ───────────────────────
// Exclude "OT z*" and "OT u*" — these were never renamed in the forward pass

$mapping_o := New object
$count_i   := 0
$DQ_t      := Char(Double quote)

ARRAY TEXT($fileList_at; 0)
ARRAY TEXT($inspectReport_at; 0)
DOCUMENT LIST($methodsFolder_t; $fileList_at)
SORT ARRAY($fileList_at; >)

$i_i := Size of array($fileList_at)
While ($i_i > 0)
	$fileName_t := $fileList_at{$i_i}

	If ((Position("OT "; $fileName_t) = 1) & (Position(".4dm"; $fileName_t) > 1))
		$oldName_t := Substring($fileName_t; 1; Length($fileName_t) - 4)

		// Skip "OT z*" and "OT u*" — these were not renamed in the forward pass
		If ((Position("OT z"; $oldName_t) # 1) & (Position("OT u"; $oldName_t) # 1))
			$newName_t := "OTr_" + Substring($oldName_t; 4)
			OB SET($mapping_o; $oldName_t; $newName_t)
			$count_i += 1
		End if
	End if

	$i_i -= 1
End while

If ($count_i = 0)
	$msg_t := "No " + $DQ_t + "OT " + $DQ_t + " methods found in:" + Char(13) + $methodsFolder_t
	$msg_t := $msg_t + Char(13) + Char(13) + "Nothing was changed." + Char(13)
	$msg_t := $msg_t + "(Has the forward rename been run yet?)"
	ALERT($msg_t)
	return
End if

// ── Anomaly inspection ────────────────────────────────────────────────────────

APPEND TO ARRAY($inspectReport_at; "REVERSE rename inspection: OT   ->  OTr_")
$anomalyCount_i := Renamer_zInspect($methodsFolder_t; "OT "; "OT z"; "OT u"; $mapping_o; ->$inspectReport_at)

If ($anomalyCount_i > 0)
	$reportText_t := ""
	$i_i := 1
	While ($i_i <= Size of array($inspectReport_at))
		$reportText_t := $reportText_t + $inspectReport_at{$i_i} + Char(13)
		$i_i += 1
	End while
	ALERT($reportText_t)
End if

// ── Confirm before proceeding ─────────────────────────────────────────────────

$msg_t := "REVERSE rename: OT   ->  OTr_" + Char(13) + Char(13)
$msg_t := $msg_t + String($count_i) + " methods will be renamed." + Char(13) + Char(13)
$msg_t := $msg_t + "The target project must be CLOSED." + Char(13)
$msg_t := $msg_t + "Proceed?"
CONFIRM($msg_t)
If (OK = 1)
	Renamer_zDoRename($methodsFolder_t; $foldersJSON_t; $derivedData_t; $mapping_o)
Else
	ALERT("Operation cancelled. Nothing was changed.")
End if
