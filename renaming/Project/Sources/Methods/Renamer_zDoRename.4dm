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
//            Special handling for Compiler_ methods:
//            After substitution, any C_ declaration line whose first argument
//            is now a renamed method name (contains a space, i.e. "OT xxx")
//            is stripped out entirely.  Those declarations are redundant
//            because all renamed methods use #DECLARE, and having a space in
//            the method-name argument is a syntax error.
//
//            Also processes the DatabaseMethods folder (content only --
//            no files are renamed there).
//
//            Also updates the "// Project Method: OldName" comment header
//            in each renamed file to reflect the new name.
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
var $dbMethodsFolder_t : Text
var $sourcesFolder_t : Text
var $isCompiler_b : Boolean
var $cleanedBody_t : Text
var $lines_ac : Collection
var $line_t : Text
var $l_i : Integer
var $keepLine_b : Boolean
var $newNameCheck_t : Text
var $cDeclPrefix_t : Text
var $parenPos_i : Integer

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

// Derive the DatabaseMethods folder path from the Methods folder path:
//   …/Project/Sources/Methods/  ->  …/Project/Sources/DatabaseMethods/
// Strip the trailing separator, strip "Methods", append "DatabaseMethods"
$sourcesFolder_t := Substring($methodsFolder_t; 1; Length($methodsFolder_t) - 1)  // remove trailing sep
$sourcesFolder_t := Substring($sourcesFolder_t; 1; Length($sourcesFolder_t) - Length("Methods"))  // remove "Methods"
$dbMethodsFolder_t := $sourcesFolder_t + "DatabaseMethods" + $separator_t

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
// PASS 1a — Update file CONTENTS (Methods folder)
// Process every .4dm file in the Methods folder, replacing old names with new.
// We do this BEFORE renaming any files so that our file list remains stable.
//
// For Compiler_ files: after the standard substitution pass, strip every line
// whose first argument is a renamed method (detectable because the method name
// now contains a space, i.e. begins with "OT ").  These C_ declarations are
// redundant (renamed methods use #DECLARE) and syntactically invalid.
//
// For all renamed files: update the "// Project Method: OldName" header line.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "=== PASS 1a: Updating file contents (Methods) ===")

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

		// ── Standard substitution pass ────────────────────────────────────────
		$k_i := 0
		While ($k_i < $keys_ac.length)
			$oldName_t := $keys_ac[$k_i]
			$newName_t := String(OB Get($mapping_o; $oldName_t))
			$fileBody_t := Replace string($fileBody_t; $oldName_t; $newName_t; 0)
			$k_i += 1
		End while

		// ── Comment header update ─────────────────────────────────────────────
		// Update "// Project Method: OldName" to "// Project Method: NewName"
		// in the renamed file itself (only applies if this file is being renamed).
		$oldName_t := Substring($fileName_t; 1; Length($fileName_t) - 4)  // strip .4dm
		If (OB Is defined($mapping_o; $oldName_t))
			$newName_t := String(OB Get($mapping_o; $oldName_t))
			$fileBody_t := Replace string($fileBody_t; "// Project Method: " + $oldName_t; "// Project Method: " + $newName_t; 1)
		End if

		// ── Compiler_ C_ declaration strip ───────────────────────────────────
		// If this is a Compiler_ file, remove any C_ declaration lines whose
		// first argument is a renamed method (i.e. now contains "OT " with a
		// space, produced by the substitution pass above).
		//
		// Pattern to detect: the line starts with optional whitespace, then
		// "C_" followed by uppercase letters, then ":C", then digits, then "(",
		// then the new method name beginning with "OT " -- which unambiguously
		// marks it as a renamed public method.
		//
		// Implementation: split on LF (or CR), test each line, rejoin.
		//
		$isCompiler_b := (Position("Compiler_"; $fileName_t) > 0)

		If ($isCompiler_b)
			$lines_ac := Split string($fileBody_t; Char(13))
			If ($lines_ac.length <= 1)
				// Try LF
				$lines_ac := Split string($fileBody_t; Char(10))
			End if

			$cleanedBody_t := ""
			$l_i := 0
			While ($l_i < $lines_ac.length)
				$line_t := String($lines_ac[$l_i])
				$keepLine_b := True

				// Detect C_ declaration for a renamed method.
				// After the substitution pass a renamed method in a C_ call looks like:
				//   C_LONGINT:C283(OT GetLong; $0; $1)
				// The distinguishing mark: "C_" near the start of the trimmed line,
				// and "OT " appearing as the first token inside the opening parenthesis.
				//
				// We check: Position("C_"; Trim($line_t)) = 1   AND
				//           the content after the "(" begins with "OT "
				//
				$cDeclPrefix_t := Trim($line_t)
				If (Position("C_"; $cDeclPrefix_t) = 1)
					// Find the opening parenthesis
					$parenPos_i := Position("("; $cDeclPrefix_t)
					If ($parenPos_i > 0)
						// Extract the token immediately following "("
						$newNameCheck_t := Substring($cDeclPrefix_t; $parenPos_i + 1; 3)
						If ($newNameCheck_t = "OT ")
							$keepLine_b := False
						End if
					End if
				End if

				If ($keepLine_b)
					If (Length($cleanedBody_t) > 0)
						$cleanedBody_t := $cleanedBody_t + Char(13)
					End if
					$cleanedBody_t := $cleanedBody_t + $line_t
				End if

				$l_i += 1
			End while

			$fileBody_t := $cleanedBody_t
		End if

		// Only rewrite if something actually changed
		If ($fileBody_t # $originalBody_t)
			TEXT TO DOCUMENT($filePath_t; $fileBody_t; "UTF-8")
			$pass1_count_i += 1
			APPEND TO ARRAY($log_at; "  [PASS 1a] Updated: " + $fileName_t)
		End if
	End if

	$i_i += 1
End while

// ═════════════════════════════════════════════════════════════════════════════
// PASS 1b — Update file CONTENTS (DatabaseMethods folder)
// Apply the same content substitutions to DatabaseMethods/*.4dm.
// These files call OTr_ methods by name but are never renamed themselves.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== PASS 1b: Updating file contents (DatabaseMethods) ===")

If (Test path name($dbMethodsFolder_t) = Is a folder)

	ARRAY TEXT($dbFiles_at; 0)
	DOCUMENT LIST($dbMethodsFolder_t; $dbFiles_at)

	$i_i := 1
	While ($i_i <= Size of array($dbFiles_at))
		$fileName_t := $dbFiles_at{$i_i}

		If (Position(".4dm"; $fileName_t) > 0)
			$filePath_t := $dbMethodsFolder_t + $fileName_t
			$fileBody_t := Document to text($filePath_t; "UTF-8")
			$originalBody_t := $fileBody_t

			$k_i := 0
			While ($k_i < $keys_ac.length)
				$oldName_t := $keys_ac[$k_i]
				$newName_t := String(OB Get($mapping_o; $oldName_t))
				$fileBody_t := Replace string($fileBody_t; $oldName_t; $newName_t; 0)
				$k_i += 1
			End while

			If ($fileBody_t # $originalBody_t)
				TEXT TO DOCUMENT($filePath_t; $fileBody_t; "UTF-8")
				$pass1_count_i += 1
				APPEND TO ARRAY($log_at; "  [PASS 1b] Updated: " + $fileName_t)
			End if
		End if

		$i_i += 1
	End while

Else
	APPEND TO ARRAY($log_at; "  [PASS 1b] DatabaseMethods folder not found -- skipped.")
	APPEND TO ARRAY($log_at; "  Path checked: " + $dbMethodsFolder_t)
End if

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
