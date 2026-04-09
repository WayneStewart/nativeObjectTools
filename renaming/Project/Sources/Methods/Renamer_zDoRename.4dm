//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: Renamer_zDoRename
//
// Private worker called by Renamer_Forward and Renamer_Reverse.
// Performs the three-pass rename operation:
//
//   Pass 1 : Update the CONTENTS of every .4dm file in the Methods folder,
//            replacing every occurrence of each old method name with its
//            new name.  All .4dm files are processed (not just the renamed
//            ones) so that call-site references in non-renamed methods are
//            also updated.
//
//   Pass 2 : Rename the .4dm FILES themselves using the mapping.
//
//   Pass 3 : Update folders.json, replacing every occurrence of each old
//            method name string with the new name.
//
//   Cleanup: Delete methodAttributes.json from the DerivedData folder.
//            4D will regenerate it correctly on next project launch.
//
// IMPORTANT: The target project must be CLOSED before this method runs.
//
// Parameters:
//   $methodsFolder_t : Text   : Absolute path to Project/Sources/Methods/
//                               Must end with a path separator.
//   $foldersJSON_t   : Text   : Absolute path to Project/Sources/folders.json
//   $derivedData_t   : Text   : Absolute path to Project/DerivedData/
//   $mapping_o       : Object : Keys = old names, values = new names
//
// Created by Wayne Stewart, 2026-04-09
// ----------------------------------------------------

#DECLARE($methodsFolder_t : Text; $foldersJSON_t : Text; $derivedData_t : Text; $mapping_o : Object)

var $fileName_t : Text
var $filePath_t : Text
var $fileBody_t : Text
var $originalBody_t : Text
var $oldName_t : Text
var $newName_t : Text
var $oldPath_t : Text
var $newPath_t : Text
var $foldersBody_t : Text
var $originalFolders_t : Text
var $attrPath_t : Text
var $logText_t : Text
var $i_i : Integer
var $pass1_count_i : Integer
var $pass2_count_i : Integer
var $pass3_count_i : Integer
var $keys_ac : Collection
var $k_i : Integer
var $separator_t : Text
var $hit_b : Boolean

// ── Initialise ────────────────────────────────────────────────────────────────

$pass1_count_i := 0
$pass2_count_i := 0
$pass3_count_i := 0
$separator_t := Folder separator  // "/" on Mac, "\" on Windows

ARRAY TEXT($log_at; 0)

// Ensure the methods folder path ends with a separator
If (Substring($methodsFolder_t; Length($methodsFolder_t); 1) # $separator_t)
	$methodsFolder_t := $methodsFolder_t + $separator_t
End if

$keys_ac := OB Keys($mapping_o)

// ── Sanity check ─────────────────────────────────────────────────────────────

If ($keys_ac.length = 0)
	ALERT("Mapping object is empty. Nothing to do.")
	return
End if

If (Test path name($methodsFolder_t) # Is a folder)
	ALERT("Methods folder not found:" + Char(13) + $methodsFolder_t)
	return
End if

If (Test path name($foldersJSON_t) # Is a document)
	ALERT("folders.json not found:" + Char(13) + $foldersJSON_t)
	return
End if

// ═════════════════════════════════════════════════════════════════════════════
// PASS 1 — Update file CONTENTS
// Process every .4dm file in the methods folder, replacing old names with new.
// We do this BEFORE renaming any files so that our file list remains stable.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "=== PASS 1: Updating file contents ===")

ARRAY TEXT($allFiles_at; 0)
DOCUMENT LIST($methodsFolder_t; $allFiles_at)

$i_i := 1
While ($i_i <= Size of array($allFiles_at))
	$fileName_t := $allFiles_at{$i_i}

	// Only process .4dm files
	If (Position(".4dm"; $fileName_t) > 0)
		$filePath_t := $methodsFolder_t + $fileName_t

		// Read the entire file as UTF-8 text
		$fileBody_t := Document to text($filePath_t; "UTF-8")
		$originalBody_t := $fileBody_t

		// Apply every substitution in the mapping
		$k_i := 0
		While ($k_i < $keys_ac.length)
			$oldName_t := $keys_ac[$k_i]
			$newName_t := String(OB Get($mapping_o; $oldName_t))
			$fileBody_t := Replace string($fileBody_t; $oldName_t; $newName_t; 0)
			$k_i += 1
		End while

		// Only rewrite if something actually changed
		If ($fileBody_t # $originalBody_t)
			TEXT TO DOCUMENT($filePath_t; $fileBody_t; "UTF-8")
			$pass1_count_i += 1
			APPEND TO ARRAY($log_at; "  [PASS 1] Updated: " + $fileName_t)
		End if
	End if

	$i_i += 1
End while

// ═════════════════════════════════════════════════════════════════════════════
// PASS 2 — Rename FILES
// Now rename the .4dm files whose names appear as keys in the mapping.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== PASS 2: Renaming files ===")

$k_i := 0
While ($k_i < $keys_ac.length)
	$oldName_t := $keys_ac[$k_i]
	$newName_t := String(OB Get($mapping_o; $oldName_t))

	$oldPath_t := $methodsFolder_t + $oldName_t + ".4dm"
	$newPath_t := $methodsFolder_t + $newName_t + ".4dm"

	If (Test path name($oldPath_t) = Is a document)
		MOVE DOCUMENT($oldPath_t; $newPath_t)
		If (OK = 1)
			$pass2_count_i += 1
			APPEND TO ARRAY($log_at; "  [PASS 2] Renamed: " + $oldName_t + ".4dm  -->  " + $newName_t + ".4dm")
		Else
			APPEND TO ARRAY($log_at; "  [ERROR ] Could not rename: " + $oldPath_t + "  -->  " + $newPath_t)
		End if
	Else
		// File does not exist under the old name — possibly already renamed,
		// or the mapping contains a name not present in this project.
		APPEND TO ARRAY($log_at; "  [SKIP  ] Not found (already renamed?): " + $oldPath_t)
	End if

	$k_i += 1
End while

// ═════════════════════════════════════════════════════════════════════════════
// PASS 3 — Update folders.json
// Read the JSON as plain text and apply the same substitutions.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== PASS 3: Updating folders.json ===")

$foldersBody_t := Document to text($foldersJSON_t; "UTF-8")
$originalFolders_t := $foldersBody_t

$k_i := 0
While ($k_i < $keys_ac.length)
	$oldName_t := $keys_ac[$k_i]
	$newName_t := String(OB Get($mapping_o; $oldName_t))
	$foldersBody_t := Replace string($foldersBody_t; $oldName_t; $newName_t; 0)
	$k_i += 1
End while

If ($foldersBody_t # $originalFolders_t)
	TEXT TO DOCUMENT($foldersJSON_t; $foldersBody_t; "UTF-8")
	$pass3_count_i := 1
	APPEND TO ARRAY($log_at; "  [PASS 3] folders.json updated.")
Else
	APPEND TO ARRAY($log_at; "  [PASS 3] No changes needed in folders.json.")
End if

// ═════════════════════════════════════════════════════════════════════════════
// CLEANUP — Delete methodAttributes.json
// 4D will regenerate this from the //%attributes headers on next launch.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== CLEANUP: methodAttributes.json ===")

If (Substring($derivedData_t; Length($derivedData_t); 1) # $separator_t)
	$derivedData_t := $derivedData_t + $separator_t
End if

$attrPath_t := $derivedData_t + "methodAttributes.json"

If (Test path name($attrPath_t) = Is a document)
	DELETE DOCUMENT($attrPath_t)
	If (OK = 1)
		APPEND TO ARRAY($log_at; "  [CLEANUP] Deleted methodAttributes.json (4D will regenerate on next launch).")
	Else
		APPEND TO ARRAY($log_at; "  [WARNING] Could not delete methodAttributes.json. Delete it manually before relaunching.")
	End if
Else
	APPEND TO ARRAY($log_at; "  [CLEANUP] methodAttributes.json not found (already absent -- that is fine).")
End if

// ═════════════════════════════════════════════════════════════════════════════
// SUMMARY
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== SUMMARY ===")
APPEND TO ARRAY($log_at; "  Files with updated content : " + String($pass1_count_i))
APPEND TO ARRAY($log_at; "  Files renamed              : " + String($pass2_count_i))
APPEND TO ARRAY($log_at; "  folders.json updated       : " + String($pass3_count_i))
APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "Operation complete.")

// Display the log
$logText_t := ""
$i_i := 1
While ($i_i <= Size of array($log_at))
	$logText_t := $logText_t + $log_at{$i_i} + Char(13)
	$i_i += 1
End while

ALERT($logText_t)
