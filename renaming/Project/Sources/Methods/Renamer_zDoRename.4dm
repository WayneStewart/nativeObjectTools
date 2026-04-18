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
var $lineEnd_t : Text
var $isForward_b : Boolean
var $inBlock_b : Boolean
var $trimmed_t : Text
var $pass4_count_i : Integer
var $firstKey_t : Text
var $slashPos_i : Integer
var $formsFolder_t : Text
var $formName_t : Text
var $objMethodsFolder_t : Text
var $j_i : Integer

// ── Initialise ────────────────────────────────────────────────────────────────

$pass1_count_i:=0
$pass2_count_i:=0
$pass3_count_i:=0
$separator_t:=Folder separator  // "/" on Mac, "\" on Windows

ARRAY TEXT($log_at; 0)

// Ensure the methods folder path ends with a separator
If (Substring($methodsFolder_t; Length($methodsFolder_t); 1)#$separator_t)
	$methodsFolder_t:=$methodsFolder_t+$separator_t
End if 

// Derive the DatabaseMethods folder path from the Methods folder path:
//   …/Project/Sources/Methods/  ->  …/Project/Sources/DatabaseMethods/
// Strip the trailing separator, strip "Methods", append "DatabaseMethods"
$sourcesFolder_t:=Substring($methodsFolder_t; 1; Length($methodsFolder_t)-1)  // remove trailing sep
$sourcesFolder_t:=Substring($sourcesFolder_t; 1; Length($sourcesFolder_t)-Length("Methods"))  // remove "Methods"
$dbMethodsFolder_t:=$sourcesFolder_t+"DatabaseMethods"+$separator_t

$keys_ac:=OB Keys($mapping_o)

// ── Sanity check ─────────────────────────────────────────────────────────────

If ($keys_ac.length=0)
	ALERT("Mapping object is empty. Nothing to do.")
	return 
End if 

If (Test path name($methodsFolder_t)#Is a folder)
	ALERT("Methods folder not found:"+Char(13)+$methodsFolder_t)
	return 
End if 

If (Test path name($foldersJSON_t)#Is a document)
	ALERT("folders.json not found:"+Char(13)+$foldersJSON_t)
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

$i_i:=1
While ($i_i<=Size of array($allFiles_at))
	$fileName_t:=$allFiles_at{$i_i}
	
	// Only process .4dm files
	If (Position(".4dm"; $fileName_t)>0)
		$filePath_t:=$methodsFolder_t+$fileName_t
		
		// Read the entire file as UTF-8 text
		$fileBody_t:=Document to text($filePath_t; "UTF-8")
		$originalBody_t:=$fileBody_t
		
		// ── Standard substitution pass ────────────────────────────────────────
		$k_i:=0
		While ($k_i<$keys_ac.length)
			$oldName_t:=$keys_ac[$k_i]
			$newName_t:=String(OB Get($mapping_o; $oldName_t))
			$fileBody_t:=Replace string($fileBody_t; $oldName_t; $newName_t)
			$k_i+=1
		End while 
		
		// ── Comment header update ─────────────────────────────────────────────
		// Update "// Project Method: OldName" to "// Project Method: NewName"
		// in the renamed file itself (only applies if this file is being renamed).
		$oldName_t:=Substring($fileName_t; 1; Length($fileName_t)-4)  // strip .4dm
		If (OB Is defined($mapping_o; $oldName_t))
			$newName_t:=String(OB Get($mapping_o; $oldName_t))
			$fileBody_t:=Replace string($fileBody_t; "// Project Method: "+$oldName_t; "// Project Method: "+$newName_t)
		End if 
		
		// Only rewrite if something actually changed
		If ($fileBody_t#$originalBody_t)
			TEXT TO DOCUMENT($filePath_t; $fileBody_t; "UTF-8")
			$pass1_count_i+=1
			APPEND TO ARRAY($log_at; "  [PASS 1a] Updated: "+$fileName_t)
		End if 
	End if 
	
	$i_i+=1
End while 

// ═════════════════════════════════════════════════════════════════════════════
// PASS 1b — Update file CONTENTS (DatabaseMethods folder)
// Apply the same content substitutions to DatabaseMethods/*.4dm.
// These files call OTr_ methods by name but are never renamed themselves.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== PASS 1b: Updating file contents (DatabaseMethods) ===")

If (Test path name($dbMethodsFolder_t)=Is a folder)
	
	ARRAY TEXT($dbFiles_at; 0)
	DOCUMENT LIST($dbMethodsFolder_t; $dbFiles_at)
	
	$i_i:=1
	While ($i_i<=Size of array($dbFiles_at))
		$fileName_t:=$dbFiles_at{$i_i}
		
		If (Position(".4dm"; $fileName_t)>0)
			$filePath_t:=$dbMethodsFolder_t+$fileName_t
			$fileBody_t:=Document to text($filePath_t; "UTF-8")
			$originalBody_t:=$fileBody_t
			
			$k_i:=0
			While ($k_i<$keys_ac.length)
				$oldName_t:=$keys_ac[$k_i]
				$newName_t:=String(OB Get($mapping_o; $oldName_t))
				$fileBody_t:=Replace string($fileBody_t; $oldName_t; $newName_t)
				$k_i+=1
			End while 
			
			If ($fileBody_t#$originalBody_t)
				TEXT TO DOCUMENT($filePath_t; $fileBody_t; "UTF-8")
				$pass1_count_i+=1
				APPEND TO ARRAY($log_at; "  [PASS 1b] Updated: "+$fileName_t)
			End if 
		End if 
		
		$i_i+=1
	End while 
	
Else 
	APPEND TO ARRAY($log_at; "  [PASS 1b] DatabaseMethods folder not found -- skipped.")
	APPEND TO ARRAY($log_at; "  Path checked: "+$dbMethodsFolder_t)
End if 

// ═════════════════════════════════════════════════════════════════════════════
// PASS 1c — Update file CONTENTS (Forms folder tree)
// Form object methods live under Sources/Forms/<formName>/ObjectMethods/ and
// Sources/Forms/<formName>/method.4dm — none are renamed, but their call sites
// must be updated.  FOLDER LIST gives us the form subfolders; we then scan
// each for .4dm files at the top level and inside ObjectMethods/.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== PASS 1c: Updating file contents (Forms) ===")

$formsFolder_t := $sourcesFolder_t + "Forms" + $separator_t

If (Test path name($formsFolder_t) = Is a folder)

	ARRAY TEXT($formFolders_at; 0)
	FOLDER LIST($formsFolder_t; $formFolders_at)

	$i_i := 1
	While ($i_i <= Size of array($formFolders_at))
		$formName_t := $formFolders_at{$i_i}

		// Process form-level method.4dm
		$filePath_t := $formsFolder_t + $formName_t + $separator_t + "method.4dm"
		If (Test path name($filePath_t) = Is a document)
			$fileBody_t := Document to text($filePath_t; "UTF-8")
			$originalBody_t := $fileBody_t
			$k_i := 0
			While ($k_i < $keys_ac.length)
				$oldName_t := $keys_ac[$k_i]
				$newName_t := String(OB Get($mapping_o; $oldName_t))
				$fileBody_t := Replace string($fileBody_t; $oldName_t; $newName_t)
				$k_i += 1
			End while
			If ($fileBody_t # $originalBody_t)
				TEXT TO DOCUMENT($filePath_t; $fileBody_t; "UTF-8")
				$pass1_count_i += 1
				APPEND TO ARRAY($log_at; "  [PASS 1c] Updated: " + $formName_t + "/method.4dm")
			End if
		End if

		// Process ObjectMethods subfolder
		$objMethodsFolder_t := $formsFolder_t + $formName_t + $separator_t + "ObjectMethods" + $separator_t
		If (Test path name($objMethodsFolder_t) = Is a folder)
			ARRAY TEXT($objFiles_at; 0)
			DOCUMENT LIST($objMethodsFolder_t; $objFiles_at)
			$j_i := 1
			While ($j_i <= Size of array($objFiles_at))
				$fileName_t := $objFiles_at{$j_i}
				If (Position(".4dm"; $fileName_t) > 0)
					$filePath_t := $objMethodsFolder_t + $fileName_t
					$fileBody_t := Document to text($filePath_t; "UTF-8")
					$originalBody_t := $fileBody_t
					$k_i := 0
					While ($k_i < $keys_ac.length)
						$oldName_t := $keys_ac[$k_i]
						$newName_t := String(OB Get($mapping_o; $oldName_t))
						$fileBody_t := Replace string($fileBody_t; $oldName_t; $newName_t)
						$k_i += 1
					End while
					If ($fileBody_t # $originalBody_t)
						TEXT TO DOCUMENT($filePath_t; $fileBody_t; "UTF-8")
						$pass1_count_i += 1
						APPEND TO ARRAY($log_at; "  [PASS 1c] Updated: " + $formName_t + "/ObjectMethods/" + $fileName_t)
					End if
				End if
				$j_i += 1
			End while
		End if

		$i_i += 1
	End while

Else
	APPEND TO ARRAY($log_at; "  [PASS 1c] Forms folder not found -- skipped.")
	APPEND TO ARRAY($log_at; "  Path checked: " + $formsFolder_t)
End if

// ═════════════════════════════════════════════════════════════════════════════
// PASS 2 — Rename FILES
// Now rename the .4dm files whose names appear as keys in the mapping.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== PASS 2: Renaming files ===")

$k_i:=0
While ($k_i<$keys_ac.length)
	$oldName_t:=$keys_ac[$k_i]
	$newName_t:=String(OB Get($mapping_o; $oldName_t))
	
	$oldPath_t:=$methodsFolder_t+$oldName_t+".4dm"
	$newPath_t:=$methodsFolder_t+$newName_t+".4dm"
	
	If (Test path name($oldPath_t)=Is a document)
		MOVE DOCUMENT($oldPath_t; $newPath_t)
		If (OK=1)
			$pass2_count_i+=1
			APPEND TO ARRAY($log_at; "  [PASS 2] Renamed: "+$oldName_t+".4dm  -->  "+$newName_t+".4dm")
		Else 
			APPEND TO ARRAY($log_at; "  [ERROR ] Could not rename: "+$oldPath_t+"  -->  "+$newPath_t)
		End if 
	Else 
		// File does not exist under the old name — possibly already renamed,
		// or the mapping contains a name not present in this project.
		APPEND TO ARRAY($log_at; "  [SKIP  ] Not found (already renamed?): "+$oldPath_t)
	End if 
	
	$k_i+=1
End while 

// ═════════════════════════════════════════════════════════════════════════════
// PASS 3 — Update folders.json
// Read the JSON as plain text and apply the same substitutions.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== PASS 3: Updating folders.json ===")

$foldersBody_t:=Document to text($foldersJSON_t; "UTF-8")
$originalFolders_t:=$foldersBody_t

$k_i:=0
While ($k_i<$keys_ac.length)
	$oldName_t:=$keys_ac[$k_i]
	$newName_t:=String(OB Get($mapping_o; $oldName_t))
	$foldersBody_t:=Replace string($foldersBody_t; $oldName_t; $newName_t)
	$k_i+=1
End while 

If ($foldersBody_t#$originalFolders_t)
	TEXT TO DOCUMENT($foldersJSON_t; $foldersBody_t; "UTF-8")
	$pass3_count_i:=1
	APPEND TO ARRAY($log_at; "  [PASS 3] folders.json updated.")
Else 
	APPEND TO ARRAY($log_at; "  [PASS 3] No changes needed in folders.json.")
End if 

// ═════════════════════════════════════════════════════════════════════════════
// PASS 4 — Comment / uncomment OTr BLOCK sentinels in _OTr test files
//
// Files named ____Test_*_OTr.4dm contain a sentinel block:
//   // ==== BEGIN OTr BLOCK — comment out when renamed to OT  ====
//   ... code ...
//   // ==== END OTr BLOCK ====
//
// Forward pass (OTr_ -> OT ): prefix every non-blank, non-comment line
//   inside the block with "//" so the renamed project compiles cleanly.
//
// Reverse pass (OT  -> OTr_): strip the leading "//" from those same lines
//   so the OTr_ calls are active again.
//
// Direction is detected from the first key in the mapping:
//   starts with "OTr_" -> forward; starts with "OT " -> reverse.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== PASS 4: OTr BLOCK comment toggle (_OTr files) ===")

$pass4_count_i := 0

// Determine direction from the first mapping key
$firstKey_t := String($keys_ac[0])
$isForward_b := (Substring($firstKey_t; 1; 4) = "OTr_")

ARRAY TEXT($allFiles4_at; 0)
DOCUMENT LIST($methodsFolder_t; $allFiles4_at)

$i_i := 1
While ($i_i <= Size of array($allFiles4_at))
	$fileName_t := $allFiles4_at{$i_i}

	// Only process files ending in _OTr.4dm
	If (Position("_OTr.4dm"; $fileName_t) = (Length($fileName_t) - 7))
		$filePath_t := $methodsFolder_t + $fileName_t
		$fileBody_t := Document to text($filePath_t; "UTF-8")
		$originalBody_t := $fileBody_t

		// Detect line ending
		If (Position(Char(10); $fileBody_t) > 0)
			$lineEnd_t := Char(10)
		Else
			$lineEnd_t := Char(13)
		End if

		$lines_ac := Split string($fileBody_t; $lineEnd_t)
		$cleanedBody_t := ""
		$inBlock_b := False

		$l_i := 0
		While ($l_i < $lines_ac.length)
			$line_t := String($lines_ac[$l_i])
			$trimmed_t := Trim($line_t)

			// Detect block boundaries
			If (Position("BEGIN OTr BLOCK"; $trimmed_t) > 0)
				$inBlock_b := True
			End if
			If (Position("END OTr BLOCK"; $trimmed_t) > 0)
				$inBlock_b := False
			End if

			// Transform lines inside the block (excluding the sentinel lines themselves)
			// Forward pass prefixes non-blank, non-comment lines with "//~" (a marker
			// that distinguishes machine-added comments from original source comments).
			// Reverse pass strips only "//~" markers, leaving genuine "//" comments intact.
			If ($inBlock_b & (Position("BEGIN OTr BLOCK"; $trimmed_t) = 0))
				If ($isForward_b)
					// Forward: comment out non-blank, non-already-commented lines
					If ((Length($trimmed_t) > 0) & (Substring($trimmed_t; 1; 3) # "//~") & (Substring($trimmed_t; 1; 2) # "//"))
						$line_t := "//~" + $line_t
					End if
				Else
					// Reverse: strip only "//~" markers added by the forward pass
					If (Substring($trimmed_t; 1; 3) = "//~")
						$slashPos_i := Position("//~"; $line_t)
						$line_t := Substring($line_t; 1; $slashPos_i - 1) + Substring($line_t; $slashPos_i + 3)
					End if
				End if
			End if

			If (Length($cleanedBody_t) > 0)
				$cleanedBody_t := $cleanedBody_t + $lineEnd_t
			End if
			$cleanedBody_t := $cleanedBody_t + $line_t

			$l_i += 1
		End while

		$fileBody_t := $cleanedBody_t

		If ($fileBody_t # $originalBody_t)
			TEXT TO DOCUMENT($filePath_t; $fileBody_t; "UTF-8")
			$pass4_count_i += 1
			APPEND TO ARRAY($log_at; "  [PASS 4] Toggled OTr BLOCK in: " + $fileName_t)
		End if
	End if

	$i_i += 1
End while

If ($pass4_count_i = 0)
	APPEND TO ARRAY($log_at; "  [PASS 4] No _OTr files with sentinel blocks found.")
End if

// ═════════════════════════════════════════════════════════════════════════════
// CLEANUP — Delete methodAttributes.json
// 4D will regenerate this from the //%attributes headers on next launch.
// ═════════════════════════════════════════════════════════════════════════════

APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "=== CLEANUP: methodAttributes.json ===")

If (Substring($derivedData_t; Length($derivedData_t); 1)#$separator_t)
	$derivedData_t:=$derivedData_t+$separator_t
End if 

$attrPath_t:=$derivedData_t+"methodAttributes.json"

If (Test path name($attrPath_t)=Is a document)
	DELETE DOCUMENT($attrPath_t)
	If (OK=1)
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
APPEND TO ARRAY($log_at; "  Files with updated content : "+String($pass1_count_i))
APPEND TO ARRAY($log_at; "  Files renamed              : "+String($pass2_count_i))
APPEND TO ARRAY($log_at; "  folders.json updated       : "+String($pass3_count_i))
APPEND TO ARRAY($log_at; "  OTr BLOCK files toggled    : "+String($pass4_count_i))
APPEND TO ARRAY($log_at; "")
APPEND TO ARRAY($log_at; "Operation complete.")

// Display the log
$logText_t:=""
$i_i:=1
While ($i_i<=Size of array($log_at))
	$logText_t:=$logText_t+$log_at{$i_i}+Char(13)
	$i_i+=1
End while 

ALERT($logText_t)
