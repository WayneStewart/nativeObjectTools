//%attributes = {"invisible":false,"shared":false}
// ----------------------------------------------------
// Project Method: Renamer_DryRun
//
// Scans the Methods folder and reports what a Forward rename WOULD do,
// without modifying any files.
//
// Produces a report showing:
//   - Each OTr_ method found and its proposed new name
//   - The total count of .4dm files that would have their contents changed
//   - Whether folders.json contains entries that would be updated
//   - Whether methodAttributes.json exists (and would be deleted)
//
// No files are written, renamed, or deleted.
//
// Parameters:
//   $methodsFolder_t : Text : Absolute path to Project/Sources/Methods/
//
// Created by Wayne Stewart, 2026-04-09
// ----------------------------------------------------

#DECLARE($methodsFolder_t : Text)

var $fileName_t : Text
var $oldName_t : Text
var $newName_t : Text
var $fileBody_t : Text
var $filePath_t : Text
var $mapping_o : Object
var $keys_ac : Collection
var $i_i : Integer
var $k_i : Integer
var $methodCount_i : Integer
var $contentHitCount_i : Integer
var $separator_t : Text
var $reportText_t : Text
var $hit_b : Boolean
var $anomalyCount_i : Integer

$separator_t:=Folder separator
$mapping_o:=New object

ARRAY TEXT($report_at; 0)
ARRAY TEXT($allFiles_at; 0)
ARRAY TEXT($inspectReport_at; 0)

// Ensure trailing separator
If (Substring($methodsFolder_t; Length($methodsFolder_t); 1)#$separator_t)
	$methodsFolder_t:=$methodsFolder_t+$separator_t
End if 

// ── Build the mapping — excluding OTr_z* and OTr_u* ──────────────────────────

DOCUMENT LIST($methodsFolder_t; $allFiles_at)
SORT ARRAY($allFiles_at; >)

$i_i:=1
While ($i_i<=Size of array($allFiles_at))
	$fileName_t:=$allFiles_at{$i_i}
	If ((Position("OTr_"; $fileName_t)=1) & (Position(".4dm"; $fileName_t)>1))
		$oldName_t:=Substring($fileName_t; 1; Length($fileName_t)-4)
		// Exclude OTr_z* and OTr_u* — private and utility methods
		If ((Position("OTr_z"; $oldName_t)#1) & (Position("OTr_u"; $oldName_t)#1))
			$newName_t:="OT "+Substring($oldName_t; 5)
			OB SET($mapping_o; $oldName_t; $newName_t)
		End if 
	End if 
	$i_i+=1
End while 

$keys_ac:=OB Keys($mapping_o)
$methodCount_i:=$keys_ac.length

If ($methodCount_i=0)
	ALERT("No OTr_ methods found in:"+Char(13)+$methodsFolder_t)
	return 
End if 

// ── Report: proposed renames ──────────────────────────────────────────────────

APPEND TO ARRAY($report_at; "DRY RUN REPORT -- Forward rename ( OTr_  ->  OT )")
APPEND TO ARRAY($report_at; "Methods folder: "+$methodsFolder_t)
APPEND TO ARRAY($report_at; "")
APPEND TO ARRAY($report_at; "Methods that WOULD be renamed ("+String($methodCount_i)+") ---")

$k_i:=0
While ($k_i<$keys_ac.length)
	$oldName_t:=$keys_ac[$k_i]
	$newName_t:=String(OB Get($mapping_o; $oldName_t))
	APPEND TO ARRAY($report_at; $oldName_t+"  -->  "+$newName_t)
	$k_i+=1
End while 

// ── Scan all .4dm files for content hits ─────────────────────────────────────

APPEND TO ARRAY($report_at; "")
APPEND TO ARRAY($report_at; "Files that WOULD have contents updated ---")

$contentHitCount_i:=0
$i_i:=1
While ($i_i<=Size of array($allFiles_at))
	$fileName_t:=$allFiles_at{$i_i}
	If (Position(".4dm"; $fileName_t)>0)
		$filePath_t:=$methodsFolder_t+$fileName_t
		$fileBody_t:=Document to text($filePath_t; "UTF-8")
		
		// Check if any old name appears in this file's body
		$hit_b:=False
		$k_i:=0
		While (($k_i<$keys_ac.length) & (Not($hit_b)))
			If (Position($keys_ac[$k_i]; $fileBody_t)>0)
				$hit_b:=True
			End if 
			$k_i+=1
		End while 
		
		If ($hit_b)
			APPEND TO ARRAY($report_at; $fileName_t)
			$contentHitCount_i+=1
		End if 
	End if 
	$i_i+=1
End while 

APPEND TO ARRAY($report_at; "Total files with content changes: "+String($contentHitCount_i))

// ── Anomaly inspection ────────────────────────────────────────────────────────

$anomalyCount_i:=Renamer_zInspect($methodsFolder_t; "OTr_"; "OTr_z"; "OTr_u"; $mapping_o; ->$inspectReport_at)

$i_i:=1
While ($i_i<=Size of array($inspectReport_at))
	APPEND TO ARRAY($report_at; $inspectReport_at{$i_i})
	$i_i+=1
End while 

// ── Summary ───────────────────────────────────────────────────────────────────

APPEND TO ARRAY($report_at; "")
APPEND TO ARRAY($report_at; "--- Summary ---")
APPEND TO ARRAY($report_at; "  Methods to rename      : "+String($methodCount_i))
APPEND TO ARRAY($report_at; "  Files needing rewrite  : "+String($contentHitCount_i))
APPEND TO ARRAY($report_at; "  Anomalies found        : "+String($anomalyCount_i))
APPEND TO ARRAY($report_at; "")
APPEND TO ARRAY($report_at; "No files were modified. Run Renamer_Forward to execute.")

// ── Display ───────────────────────────────────────────────────────────────────

$reportText_t:=""
$i_i:=1
While ($i_i<=Size of array($report_at))
	$reportText_t:=$reportText_t+$report_at{$i_i}+Char(13)
	$i_i+=1
End while 

ALERT($reportText_t)
SET TEXT TO PASTEBOARD($reportText_t)
