//%attributes = {"invisible":false,"shared":false}
// ----------------------------------------------------
// Project Method: Renamer_Forward
//
// Builds the OTr_Xxx --> "OT Xxx" mapping by scanning the Methods folder
// for all files whose names begin with "OTr_", EXCLUDING those that begin
// with "OTr_z" or "OTr_u" (private and utility methods, not part of the
// public API surface).
//
// Calls Renamer_zInspect to report anomalies before proceeding.
//
// The transformation rule is:
//   OTr_  -->  OT     (the underscore-r is replaced by a space)
//
// Examples:
//   OTr_New            -->  OT New
//   OTr_GetLong        -->  OT GetLong
//   OTr_zInit          -->  NOT renamed (excluded: OTr_z prefix)
//   OTr_uBlobToText    -->  NOT renamed (excluded: OTr_u prefix)
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
var $anomalyCount_i : Integer
var $reportText_t : Text

// ── Build the mapping by scanning for OTr_*.4dm files ────────────────────────
// Exclude OTr_z* and OTr_u* — these are private/utility methods

$mapping_o := New object
$count_i   := 0

ARRAY TEXT($fileList_at; 0)
ARRAY TEXT($inspectReport_at; 0)
DOCUMENT LIST($methodsFolder_t; $fileList_at)
SORT ARRAY($fileList_at; >)

$i_i := Size of array($fileList_at)
While ($i_i > 0)
	$fileName_t := $fileList_at{$i_i}

	If ((Position("OTr_"; $fileName_t) = 1) & (Position(".4dm"; $fileName_t) > 1))
		$oldName_t := Substring($fileName_t; 1; Length($fileName_t) - 4)

		// Skip OTr_z* and OTr_u* — private and utility methods
		If ((Position("OTr_z"; $oldName_t) # 1) & (Position("OTr_u"; $oldName_t) # 1))
			$newName_t := "OT " + Substring($oldName_t; 5)
			OB SET($mapping_o; $oldName_t; $newName_t)
			$count_i += 1
		End if
	End if

	$i_i -= 1
End while

If ($count_i = 0)
	ALERT("No OTr_ methods found in:" + Char(13) + $methodsFolder_t + Char(13) + Char(13) + "Nothing was changed.")
	return
End if

// ── Anomaly inspection ────────────────────────────────────────────────────────

APPEND TO ARRAY($inspectReport_at; "FORWARD rename inspection: OTr_  ->  OT")
$anomalyCount_i := Renamer_zInspect($methodsFolder_t; "OTr_"; "OTr_z"; "OTr_u"; $mapping_o; ->$inspectReport_at)

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

$msg_t := "FORWARD rename: OTr_  ->  OT" + Char(13) + Char(13)
$msg_t := $msg_t + String($count_i) + " methods will be renamed." + Char(13) + Char(13)
$msg_t := $msg_t + "The target project must be CLOSED." + Char(13)
$msg_t := $msg_t + "Proceed?"
CONFIRM($msg_t)
If (OK = 1)
	Renamer_zDoRename($methodsFolder_t; $foldersJSON_t; $derivedData_t; $mapping_o)
Else
	ALERT("Operation cancelled. Nothing was changed.")
End if
