//%attributes = {}
// ----------------------------------------------------
// Project Method: Renamer_Run
//
// Entry point for the OTr_ <-> "OT " API method renamer.
//
// Usage:
//   Run this method to select a mode and execute the rename.
//   It presents a dialog offering three choices:
//     1 - Forward  : OTr_Xxx  -->  OT Xxx   (pre-publication rename)
//     2 - Reverse  : OT Xxx   -->  OTr_Xxx  (rollback)
//     3 - Dry Run  : report only, no files are modified
//
// Prerequisites:
//   - The target 4D project must be CLOSED before running this tool.
//   - Set the constant kTargetMethodsFolder (below) to the absolute
//     path of the target project's  Project/Sources/Methods/  folder.
//   - Set kTargetFoldersJSON to the absolute path of
//     Project/Sources/folders.json  in the same project.
//   - Set kTargetDerivedData to the absolute path of
//     Project/DerivedData/  in the same project.
//     The tool will delete methodAttributes.json from that folder;
//     4D will regenerate it on next launch.
//
// Reversibility:
//   Run Renamer_Reverse (or choose option 2) to undo a forward rename.
//   The logic is strictly symmetrical.
//
// Created by Wayne Stewart, 2026-04-09
// ----------------------------------------------------



// ── Configuration ────────────────────────────────────────────────────────────
// Adjust these three paths to point at the TARGET project (not this project).

var $methodsFolder_t : Text
var $foldersJSON_t : Text
var $derivedData_t : Text

var $path; $projectPath_t : Text

$projectPath_t:=Replace string(Get 4D folder(Database folder); "renaming"; "Project")  // This swaps the location to the project folder on native object tools

//$methodsFolder_t:="PASTE_TARGET_PROJECT_PATH_HERE/Project/Sources/Methods/"
//$foldersJSON_t:="PASTE_TARGET_PROJECT_PATH_HERE/Project/Sources/folders.json"
//$derivedData_t:="PASTE_TARGET_PROJECT_PATH_HERE/Project/DerivedData/"

$methodsFolder_t:=$projectPath_t+"Sources"+Folder separator+"Methods"+Folder separator
$foldersJSON_t:=$projectPath_t+"Sources"+Folder separator+"folders.json"
$derivedData_t:=$projectPath_t+"DerivedData"+Folder separator

var $m; $f; $d : Integer
$m:=Test path name($methodsFolder_t)  //  Is a folder = 0
$f:=Test path name($foldersJSON_t)  // Is a Document =1
$d:=Test path name($derivedData_t)  // Is a folder = 0

// ── Git status check ─────────────────────────────────────────────────────────
// The git repo root is the parent of $projectPath_t (which points at …/Project/).
// We use git status --porcelain: empty output = clean, any output = uncommitted changes.
// If uncommitted changes exist, Forward and Reverse are blocked — Dry Run only.

var $gitRoot_t : Text
var $gitCmd_t : Text
var $gitOut_t : Text
var $gitWorker : 4D.SystemWorker
var $isDirty_b : Boolean

$gitRoot_t := Substring($projectPath_t; 1; Length($projectPath_t) - 1)  // strip trailing separator
$gitRoot_t := Substring($gitRoot_t; 1; Length($gitRoot_t) - Length("Project"))  // go up one level
$gitRoot_t := Convert path system to POSIX($gitRoot_t)  // git requires a POSIX path

$gitCmd_t := "git -C \"" + $gitRoot_t + "\" status --porcelain"
$gitWorker := 4D.SystemWorker.new($gitCmd_t)
$gitOut_t := $gitWorker.wait(5).response  // 5-second timeout; porcelain output is near-instant

$isDirty_b := (Length(Trim($gitOut_t)) > 0)

If ($isDirty_b)
	ALERT("Uncommitted changes detected in the target repository." + Char(13) + Char(13) + "Forward and Reverse renames are blocked until the project is committed." + Char(13) + "Dry Run is still available.")
End if

// ── Mode selection ────────────────────────────────────────────────────────────

var $choice_i : Integer
var $choice_t : Text
var $prompt_t : Text

If ($isDirty_b)
	$prompt_t := "OTr Renamer  [UNCOMMITTED CHANGES DETECTED]" + Char(13) + Char(13)
	$prompt_t := $prompt_t + "Only Dry Run is available until the project is committed." + Char(13) + Char(13)
	$prompt_t := $prompt_t + "  3  =  Dry Run   ( report only, no changes )" + Char(13) + Char(13)
	$prompt_t := $prompt_t + "Enter 3 (or Cancel to abort):"
	$choice_t := Request($prompt_t; "3")
	If (Num($choice_t) # 3)
		ALERT("Operation cancelled.")
		return
	End if
	$choice_i := 3
Else
	$prompt_t := "OTr Renamer" + Char(13) + Char(13)
	$prompt_t := $prompt_t + "Choose an operation:" + Char(13)
	$prompt_t := $prompt_t + "  1  =  Forward   ( OTr_Xxx  ->  OT Xxx )" + Char(13)
	$prompt_t := $prompt_t + "  2  =  Reverse   ( OT Xxx   ->  OTr_Xxx )" + Char(13)
	$prompt_t := $prompt_t + "  3  =  Dry Run   ( report only, no changes )" + Char(13) + Char(13)
	$prompt_t := $prompt_t + "Enter 1, 2, or 3:"
	$choice_t := Request($prompt_t; "3")
	$choice_i := Num($choice_t)
End if

Case of
	: ($choice_i = 1)
		Renamer_Forward($methodsFolder_t; $foldersJSON_t; $derivedData_t)

	: ($choice_i = 2)
		Renamer_Reverse($methodsFolder_t; $foldersJSON_t; $derivedData_t)

	: ($choice_i = 3)
		Renamer_DryRun($methodsFolder_t)

	Else
		ALERT("No valid choice made. Nothing was changed.")
End case
