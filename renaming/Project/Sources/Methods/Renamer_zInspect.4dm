//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: Renamer_zInspect
//
// Inspects every .4dm file in the methods folder, detects anomalies in
// the //%attributes shared flag, reports them into the provided array,
// and — if anomalies are found — offers an interactive fix for each one.
//
// Two categories of anomaly are detected:
//
//   A - SHARED but NOT in rename set
//       A file does not match the rename prefix (e.g. does not start
//       with OTr_ in a forward pass), yet its //%attributes header
//       declares "shared":true.  This means a shared method exists
//       that will not be renamed -- likely an oversight.
//
//   B - EXCLUDED prefix but marked SHARED
//       A file starts with OTr_z or OTr_u (forward), or OT z / OT u
//       (reverse), and its header declares "shared":true.
//       These are intended as private/internal methods; being marked
//       shared is almost certainly unintentional.
//
// After reporting, if any anomalies exist the user is offered the choice
// to fix them interactively, one at a time:
//   Make Private  -- sets "shared":false in the //%attributes header
//   Make Shared   -- sets "shared":true  in the //%attributes header
//   Skip          -- leaves the file unchanged
//
// Parameters:
//   $methodsFolder_t  : Text    : Absolute path to Methods folder (with trailing separator)
//   $renamePrefix_t   : Text    : The prefix being renamed FROM e.g. "OTr_" or "OT "
//   $excludePrefix1_t : Text    : First excluded sub-prefix  e.g. "OTr_z" or "OT z"
//   $excludePrefix2_t : Text    : Second excluded sub-prefix e.g. "OTr_u" or "OT u"
//   $mapping_o        : Object  : Mapping object (keys = old names in rename set)
//   $report_at        : Pointer : Pointer to a Text array for appending results
//   $headless_b       : Boolean : When True, suppress all dialogs (CI use)
//
// Returns:
//   $anomalyCount_i   : Integer : Total number of anomalies found
//
// Created by Wayne Stewart, 2026-04-09
// Wayne Stewart, 2026-04-22 - Added $headless_b parameter to suppress interactive fix dialog in CI.
// ----------------------------------------------------

#DECLARE($methodsFolder_t : Text; $renamePrefix_t : Text; $excludePrefix1_t : Text; $excludePrefix2_t : Text; $mapping_o : Object; $report_at : Pointer; $headless_b : Boolean)->$anomalyCount_i : Integer

var $fileName_t : Text
var $methodName_t : Text
var $firstLine_t : Text
var $filePath_t : Text
var $fileBody_t : Text
var $isShared_b : Boolean
var $inRenameSet_b : Boolean
var $isExcluded_b : Boolean
var $excl1_b : Boolean
var $excl2_b : Boolean
var $i_i : Integer
var $anomalyA_i : Integer
var $anomalyB_i : Integer
var $crPos_i : Integer
var $anomalyType_t : Text
var $fixChoice_t : Text
var $fixBody_t : Text
var $prompt_t : Text

$anomalyCount_i:=0
$anomalyA_i:=0
$anomalyB_i:=0

// Arrays to hold anomalies for the interactive fix pass
ARRAY TEXT($inspectFiles_at; 0)
ARRAY TEXT($anomalyPaths_at; 0)
ARRAY TEXT($anomalyNames_at; 0)
ARRAY TEXT($anomalyTypes_at; 0)

DOCUMENT LIST($methodsFolder_t; $inspectFiles_at)
SORT ARRAY($inspectFiles_at; >)

APPEND TO ARRAY($report_at->; "")
APPEND TO ARRAY($report_at->; "--- Anomaly inspection ---")

// ── Scan pass ─────────────────────────────────────────────────────────────────

$i_i:=1
While ($i_i<=Size of array($inspectFiles_at))
	$fileName_t:=$inspectFiles_at{$i_i}
	
	If (Position(".4dm"; $fileName_t)>0)
		$methodName_t:=Substring($fileName_t; 1; Length($fileName_t)-4)
		$filePath_t:=$methodsFolder_t+$fileName_t
		
		// Read the file and extract only the first line
		$fileBody_t:=Document to text($filePath_t; "UTF-8")
		$firstLine_t:=$fileBody_t
		$crPos_i:=Position(Char(13); $firstLine_t)
		If ($crPos_i=0)
			$crPos_i:=Position(Char(10); $firstLine_t)
		End if 
		If ($crPos_i>0)
			$firstLine_t:=Substring($firstLine_t; 1; $crPos_i-1)
		End if 
		
		// Is this method marked shared?
		$isShared_b:=(Position("\"shared\":true"; $firstLine_t)>0)
		
		If ($isShared_b)
			$inRenameSet_b:=(Position($renamePrefix_t; $methodName_t)=1)
			$excl1_b:=(Position($excludePrefix1_t; $methodName_t)=1)
			$excl2_b:=(Position($excludePrefix2_t; $methodName_t)=1)
			$isExcluded_b:=($excl1_b | $excl2_b)
			
			// Anomaly A: shared but not in rename set and not an excluded prefix
			If (Not($inRenameSet_b) & Not($isExcluded_b))
				$anomalyType_t:="A"
				APPEND TO ARRAY($report_at->; "  [ANOMALY A] Shared but NOT in rename set: "+$methodName_t)
				APPEND TO ARRAY($anomalyPaths_at; $filePath_t)
				APPEND TO ARRAY($anomalyNames_at; $methodName_t)
				APPEND TO ARRAY($anomalyTypes_at; $anomalyType_t)
				$anomalyA_i+=1
				$anomalyCount_i+=1
			End if 
			
			// Anomaly B: excluded prefix but incorrectly marked shared
			If ($isExcluded_b)
				$anomalyType_t:="B"
				APPEND TO ARRAY($report_at->; "  [ANOMALY B] Excluded prefix but marked shared: "+$methodName_t)
				APPEND TO ARRAY($anomalyPaths_at; $filePath_t)
				APPEND TO ARRAY($anomalyNames_at; $methodName_t)
				APPEND TO ARRAY($anomalyTypes_at; $anomalyType_t)
				$anomalyB_i+=1
				$anomalyCount_i+=1
			End if 
		End if 
	End if 
	
	$i_i+=1
End while 

If ($anomalyCount_i=0)
	APPEND TO ARRAY($report_at->; "  No anomalies found.")
Else 
	APPEND TO ARRAY($report_at->; "  Anomaly A (shared, not in rename set): "+String($anomalyA_i))
	APPEND TO ARRAY($report_at->; "  Anomaly B (excluded prefix but shared): "+String($anomalyB_i))
End if 

// ── Interactive fix pass ──────────────────────────────────────────────────────
// Only offered if anomalies were found and not running headless

If ($anomalyCount_i>0) & (Not($headless_b))
	CONFIRM("Anomalies were found ("+String($anomalyCount_i)+")."+Char(13)+Char(13)+"Would you like to fix them now, one by one?")
	If (OK=1)
		
		$i_i:=1
		While ($i_i<=Size of array($anomalyNames_at))
			$prompt_t:="Anomaly "+$anomalyTypes_at{$i_i}+": "+$anomalyNames_at{$i_i}+Char(13)+Char(13)
			$prompt_t:=$prompt_t+"This method is currently marked SHARED."+Char(13)
			$prompt_t:=$prompt_t+"Enter:"+Char(13)
			$prompt_t:=$prompt_t+"  1 = Make Private  (set shared:false)"+Char(13)
			$prompt_t:=$prompt_t+"  2 = Make Shared   (leave as shared:true)"+Char(13)
			$prompt_t:=$prompt_t+"  3 = Skip          (no change)"
			
			$fixChoice_t:=Request($prompt_t; "3")
			
			Case of 
				: (Num($fixChoice_t)=1)
					// Make Private: replace "shared":true with "shared":false in the file
					$fixBody_t:=Document to text($anomalyPaths_at{$i_i}; "UTF-8")
					$fixBody_t:=Replace string($fixBody_t; "\"shared\":true"; "\"shared\":false")
					TEXT TO DOCUMENT($anomalyPaths_at{$i_i}; $fixBody_t; "UTF-8")
					APPEND TO ARRAY($report_at->; "  [FIXED  ] Made private: "+$anomalyNames_at{$i_i})
					
				: (Num($fixChoice_t)=2)
					// Make Shared: already shared, no change needed
					APPEND TO ARRAY($report_at->; "  [KEPT   ] Remains shared: "+$anomalyNames_at{$i_i})
					
				Else 
					// Skip
					APPEND TO ARRAY($report_at->; "  [SKIPPED] No change: "+$anomalyNames_at{$i_i})
			End case 
			
			$i_i+=1
		End while 
		
	End if 
End if 
